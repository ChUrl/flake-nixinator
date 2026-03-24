{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  prowlarrVersion = "2.1.5";
in {
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr:${prowlarrVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "9696:9696"
      ];

      volumes = [
        "prowlarr_config:/config"
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
