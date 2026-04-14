{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  # comfyuiVersion = "cu128-slim-20260316";
  # comfyuiVersion = "cu128-megapak-20260413";
  # comfyuiVersion = "cu130-megapak-pt211-20260330";
  comfyuiVersion = "cu130-megapak-pt211-20260413";
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
        # cu128-slim / cu128-megapak
        # "${rootDir}/storage:/root"
        # "${rootDir}/storage-models/models:/root/ComfyUI/models"
        # "${rootDir}/storage-models/hf-hub:/root/.cache/huggingface/hub"
        # "${rootDir}/storage-models/torch-hub:/root/.cache/torch/hub"
        # "${rootDir}/storage-user/input:/root/ComfyUI/input"
        # "${rootDir}/storage-user/output:/root/ComfyUI/output"
        # "${rootDir}/storage-user/workflows:/root/ComfyUI/user/default/workflows"

        # cu130-megapak
        "${rootDir}/storage-cache/dot-cache:/root/.cache"
        "${rootDir}/storage-cache/dot-config:/root/.config"
        "${rootDir}/storage-nodes/dot-local:/root/.local"
        "${rootDir}/storage-nodes/comfy-extras:/root/ComfyUI/comfy_extras"
        "${rootDir}/storage-nodes/custom_nodes:/root/ComfyUI/custom_nodes"
        "${rootDir}/storage-models/models:/root/ComfyUI/models"
        "${rootDir}/storage-models/hf-hub:/root/.cache/huggingface/hub"
        "${rootDir}/storage-models/torch-hub:/root/.cache/torch/hub"
        "${rootDir}/storage-user/input:/root/ComfyUI/input"
        "${rootDir}/storage-user/output:/root/ComfyUI/output"
        "${rootDir}/storage-user/user-profile:/root/ComfyUI/user"
        "${rootDir}/storage-user/user-scripts:/root/user-scripts"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        # https://github.com/Comfy-Org/ComfyUI/blob/master/comfy/cli_args.py
        CLI_ARGS = lib.concatStringsSep " " [
          # "--cache-none" # Leads to single nodes being executed multiple times for each output connection :/
          "--lowvram"
          "--disable-smart-memory"
          "--disable-pinned-memory"
          "--disable-xformers"
          "--use-sage-attention" # Crashes
          # "--reserve-vram 1" # (1 or 2) => Assume less vram is available to mitigate OOM due to wrong vram estimation
        ];
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
