{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  # comfyuiVersion = "cu128-slim-20260316";
  comfyuiVersion = "cu128-megapak-20260323";
in {
  virtualisation.oci-containers.containers = {
    comfyui = {
      image = "yanwk/comfyui-boot:${comfyuiVersion}";
      autoStart = false;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "8188:8188"
      ];

      volumes = let
        rootDir = "/home/christoph/Games/ComfyUI";
      in [
        "${rootDir}/storage:/root"
        "${rootDir}/storage-models/models:/root/ComfyUI/models"
        "${rootDir}/storage-models/hf-hub:/root/.cache/huggingface/hub"
        "${rootDir}/storage-models/torch-hub:/root/.cache/torch/hub"
        "${rootDir}/storage-user/input:/root/ComfyUI/input"
        "${rootDir}/storage-user/output:/root/ComfyUI/output"
        "${rootDir}/storage-user/workflows:/root/ComfyUI/user/default/workflows"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        # https://github.com/Comfy-Org/ComfyUI/blob/master/comfy/cli_args.py
        # --use-sage-attention # => OOM
        # --lowvram
        # --disable-pinned-memory
        # --cache-none
        # --reserve-vram 1 # (1 or 2) => Assume less vram is available to mitigate OOM due to wrong vram estimation
        # CLI_ARGS = "--lowvram --disable-pinned-memory --cache-none --reserve-vram 2";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
