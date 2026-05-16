"""RunPod serverless handler for ComfyUI (CUDA 12.4 base)."""
import base64
import json
import os
import subprocess
import time
import uuid

import requests
import runpod

COMFYUI_PATH = os.environ.get("COMFYUI_PATH", "/comfyui")
HOST = "127.0.0.1"
PORT = 8188
API = f"http://{HOST}:{PORT}"

_comfy_proc = None


def _start_comfy():
    global _comfy_proc
    if _comfy_proc and _comfy_proc.poll() is None:
        return
    print("Starting ComfyUI...", flush=True)
    _comfy_proc = subprocess.Popen(
        ["python", "main.py", "--listen", HOST, "--port", str(PORT), "--disable-auto-launch"],
        cwd=COMFYUI_PATH,
    )
    # Wait until ready
    for _ in range(60):
        try:
            if requests.get(f"{API}/system_stats", timeout=3).status_code == 200:
                print("ComfyUI ready.", flush=True)
                return
        except Exception:
            pass
        time.sleep(2)
    raise RuntimeError("ComfyUI failed to start")


def _queue(workflow: dict) -> str:
    client_id = str(uuid.uuid4())
    r = requests.post(f"{API}/prompt", json={"prompt": workflow, "client_id": client_id}, timeout=30)
    r.raise_for_status()
    return r.json()["prompt_id"]


def _collect(prompt_id: str, timeout: int = 600) -> list[bytes]:
    deadline = time.time() + timeout
    while time.time() < deadline:
        r = requests.get(f"{API}/history/{prompt_id}", timeout=10)
        r.raise_for_status()
        history = r.json()
        if prompt_id in history:
            images = []
            for node_out in history[prompt_id].get("outputs", {}).values():
                for img in node_out.get("images", []):
                    params = {"filename": img["filename"], "type": img.get("type", "output")}
                    if img.get("subfolder"):
                        params["subfolder"] = img["subfolder"]
                    resp = requests.get(f"{API}/view", params=params, timeout=30)
                    resp.raise_for_status()
                    images.append(resp.content)
            if images:
                return images
        time.sleep(2)
    raise TimeoutError(f"Timed out waiting for prompt {prompt_id}")


def handler(job: dict) -> dict:
    _start_comfy()

    inp = job.get("input", {})
    workflow = inp.get("workflow")
    if not workflow:
        return {"error": "No workflow provided"}

    # Upload input images if any
    for img in inp.get("images", []):
        name = img["name"]
        data = img["image"]
        raw = base64.b64decode(data.split(",", 1)[-1] if "," in data else data)
        dest = os.path.join(COMFYUI_PATH, "input", name)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with open(dest, "wb") as f:
            f.write(raw)

    prompt_id = _queue(workflow)
    print(f"Queued {prompt_id}", flush=True)

    image_bytes = _collect(prompt_id)
    print(f"Got {len(image_bytes)} image(s)", flush=True)

    return {
        "images": [
            {"data": base64.b64encode(b).decode(), "type": "png"}
            for b in image_bytes
        ]
    }


runpod.serverless.start({"handler": handler})
