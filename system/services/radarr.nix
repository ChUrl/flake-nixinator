{
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

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

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
