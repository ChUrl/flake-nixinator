{
  config,
  lib,
  pkgs,
  ...
}: let
  kiwixVersion = "3.8.1";
in {
  virtualisation.oci-containers.containers = {
    kiwix = {
      image = "ghcr.io/kiwix/kiwix-serve:${kiwixVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [
        # "8080:80"
      ];

      volumes = [
        # TODO: Add network location for .zim files
        "kiwix_data:/data"
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
