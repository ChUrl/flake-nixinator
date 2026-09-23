{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  bentoVersion = "2.8.8";
in {
  virtualisation.oci-containers.containers = {
    bento = {
      image = "ghcr.io/alam00000/bentopdf-simple:${bentoVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "3000:8080"
      ];

      volumes = [];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
