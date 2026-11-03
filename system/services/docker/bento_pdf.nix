{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  bentoVersion = "2.8.10";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.pdf = {port = 8082;};

  virtualisation.oci-containers.containers = {
    bento = {
      image = "ghcr.io/alam00000/bentopdf-simple:${bentoVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = ["127.0.0.1:8082:8080"];

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
