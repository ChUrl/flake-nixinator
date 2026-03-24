{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  sonarrVersion = "4.0.16";
in {
  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "linuxserver/sonarr:${sonarrVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "8989:8989"
      ];

      volumes = [
        "/media/Show/.sabnzbd-complete:/media/downloads"
        "/media/Show:/media/shows"

        "sonarr_config:/config"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
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
