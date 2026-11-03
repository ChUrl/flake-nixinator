{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  sonarrVersion = "4.0.20";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.sonarr = {port = 8989;};

  virtualisation.oci-containers.containers = {
    sonarr = {
      image = "linuxserver/sonarr:${sonarrVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = ["127.0.0.1:8989:8989"];

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
