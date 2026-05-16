FROM runpod/worker-comfyui:5.8.4-base

ARG HF_TOKEN=""

RUN comfy node install --exit-on-fail rgthree-comfy --mode remote || \
    git clone https://github.com/rgthree/rgthree-comfyui /root/comfy/ComfyUI/custom_nodes/rgthree-comfy
RUN comfy node install --exit-on-fail comfyui-glifnodes || \
    git clone https://github.com/glifxyz/comfyui-glifnodes /root/comfy/ComfyUI/custom_nodes/comfyui-glifnodes
RUN comfy node install --exit-on-fail comfyui-impact-pack || \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack /root/comfy/ComfyUI/custom_nodes/ComfyUI-Impact-Pack
RUN comfy node install --exit-on-fail comfyui-impact-subpack || \
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack /root/comfy/ComfyUI/custom_nodes/ComfyUI-Impact-Subpack
RUN comfy node install --exit-on-fail cg-use-everywhere || \
    git clone https://github.com/chrisgoringe/cg-use-everywhere /root/comfy/ComfyUI/custom_nodes/cg-use-everywhere
RUN comfy node install --exit-on-fail comfyui_essentials || \
    git clone https://github.com/cubiq/ComfyUI_essentials /root/comfy/ComfyUI/custom_nodes/ComfyUI_essentials
RUN comfy node install --exit-on-fail comfyui-nag || \
    git clone https://github.com/shiimizu/ComfyUI-NAG /root/comfy/ComfyUI/custom_nodes/ComfyUI-NAG

RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora.safetensors' --relative-path models/loras --filename 'dmd2_sdxl_4step_lora.safetensors' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/notkenski/upscalers/resolve/main/1xSkinContrast-High-SuperUltraCompact.pth' --relative-path models/upscale_models --filename '1xSkinContrast-High-SuperUltraCompact.pth' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov8s.pt' --relative-path models/ultralytics --filename 'bbox/hand_yolov8s.pt' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do comfy model download --url 'https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth' --relative-path models/ultralytics --filename 'sam_vit_b_01ec64.pth' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt' --relative-path models/ultralytics --filename 'bbox/face_yolov8m.pt' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/fandyy24/lustifySDXLNSFW_endgame/resolve/main/lustifySDXLNSFW_endgame.safetensors' --relative-path models/checkpoints --filename 'lustify_endgame.safetensors' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth' --relative-path models/upscale_models --filename '1x-ITF-SkinDiffDetail-Lite-v1.pth' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/HUGGHan/VAE/resolve/main/4xNMKDSuperscale_4xNMKDSuperscale.pt' --relative-path models/upscale_models --filename '4xNMKDSuperscale_4xNMKDSuperscale.pt' && break; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && sleep $SLEEP; done
