{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  radarrVersion = "5.28.0";
in {
  virtualisation.oci-containers.containers = {
    radarr = {
      image = "linuxserver/radarr:${radarrVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "7878:7878"
      ];

      volumes = [
        "/media/Movie/.sabnzbd-complete:/media/downloads"
        "/media/Movie:/media/movies"

        "radarr_config:/config"
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
