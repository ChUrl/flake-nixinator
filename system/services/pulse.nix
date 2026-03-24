{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  pulseVersion = "4.35.0";
in {
  virtualisation.oci-containers.containers = {
    pulse = {
      image = "rcourtman/pulse:${pulseVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "7655:7655"
      ];

      volumes = [
        "pulse_data:/data"
      ];

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
