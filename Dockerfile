FROM nvidia/cuda:12.4.1-cudnn9-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COMFYUI_PATH=/comfyui

ARG HF_TOKEN=""

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-pip python3.11-dev \
    git wget curl libgl1 libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.11 /usr/bin/python

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 \
    --index-url https://download.pytorch.org/whl/cu124

RUN git clone https://github.com/comfyanonymous/ComfyUI.git $COMFYUI_PATH && \
    pip install --no-cache-dir -r $COMFYUI_PATH/requirements.txt

RUN git clone https://github.com/rgthree/rgthree-comfyui.git $COMFYUI_PATH/custom_nodes/rgthree-comfy && \
    pip install --no-cache-dir -r $COMFYUI_PATH/custom_nodes/rgthree-comfy/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/glifxyz/comfyui-glifnodes.git $COMFYUI_PATH/custom_nodes/comfyui-glifnodes

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git $COMFYUI_PATH/custom_nodes/ComfyUI-Impact-Pack && \
    pip install --no-cache-dir -r $COMFYUI_PATH/custom_nodes/ComfyUI-Impact-Pack/requirements.txt 2>/dev/null || true && \
    python3 $COMFYUI_PATH/custom_nodes/ComfyUI-Impact-Pack/install.py 2>/dev/null || true

RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git $COMFYUI_PATH/custom_nodes/ComfyUI-Impact-Subpack

RUN git clone https://github.com/chrisgoringe/cg-use-everywhere.git $COMFYUI_PATH/custom_nodes/cg-use-everywhere

RUN git clone https://github.com/cubiq/ComfyUI_essentials.git $COMFYUI_PATH/custom_nodes/ComfyUI_essentials && \
    pip install --no-cache-dir -r $COMFYUI_PATH/custom_nodes/ComfyUI_essentials/requirements.txt 2>/dev/null || true

RUN git clone https://github.com/shiimizu/ComfyUI-NAG.git $COMFYUI_PATH/custom_nodes/ComfyUI-NAG

RUN mkdir -p $COMFYUI_PATH/models/loras/illustrious \
             $COMFYUI_PATH/models/checkpoints \
             $COMFYUI_PATH/models/upscale_models \
             $COMFYUI_PATH/models/ultralytics/bbox

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora.safetensors" \
    -O $COMFYUI_PATH/models/loras/dmd2_sdxl_4step_lora.safetensors

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/notkenski/upscalers/resolve/main/1xSkinContrast-High-SuperUltraCompact.pth" \
    -O $COMFYUI_PATH/models/upscale_models/1xSkinContrast-High-SuperUltraCompact.pth

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov8s.pt" \
    -O $COMFYUI_PATH/models/ultralytics/bbox/hand_yolov8s.pt

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth" \
    -O $COMFYUI_PATH/models/ultralytics/sam_vit_b_01ec64.pth

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
    -O $COMFYUI_PATH/models/ultralytics/bbox/face_yolov8m.pt

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    --header="Authorization: Bearer ${HF_TOKEN}" \
    "https://huggingface.co/fandyy24/lustifySDXLNSFW_endgame/resolve/main/lustifySDXLNSFW_endgame.safetensors" \
    -O $COMFYUI_PATH/models/checkpoints/lustify_endgame.safetensors

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth" \
    -O $COMFYUI_PATH/models/upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth

RUN wget -q --retry-connrefused --waitretry=10 --tries=5 \
    "https://huggingface.co/HUGGHan/VAE/resolve/main/4xNMKDSuperscale_4xNMKDSuperscale.pt" \
    -O $COMFYUI_PATH/models/upscale_models/4xNMKDSuperscale_4xNMKDSuperscale.pt

RUN pip install --no-cache-dir runpod requests
COPY handler.py /handler.py

CMD ["python", "-u", "/handler.py"]
