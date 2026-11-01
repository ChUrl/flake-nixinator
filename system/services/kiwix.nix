{
  config,
  lib,
  pkgs,
  ...
}: let
  kiwixVersion = "3.8.2";
in {
  virtualisation.oci-containers.containers = {
    kiwix = {
      image = "ghcr.io/kiwix/kiwix-serve:${kiwixVersion}";
      autoStart = true;

      dependsOn = [];

      ports = ["127.0.0.1:8081:8080"];

      volumes = [
        "/home/christoph/ssd/kiwix:/data"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      cmd = ["*.zim"];

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
