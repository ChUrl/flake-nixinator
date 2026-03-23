{
  config,
  lib,
  pkgs,
  ...
}: let
  # comfyuiVersion = "cu128-slim-20260316";
  comfyuiVersion = "cu128-megapak-pt29-20260221";
in {
  virtualisation.oci-containers.containers = {
    comfyui = {
      image = "yanwk/comfyui-boot:${comfyuiVersion}";
      autoStart = false;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

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
        # --use-sage-attention
        # --lowvram
        # --disable-pinned-memory
        # --cache-none
        CLI_ARGS = "--use-sage-attention";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
