{
  config,
  lib,
  pkgs,
  ...
}: let
  sabnzbdVersion = "4.5.5";
in {
  virtualisation.oci-containers.containers = {
    sabnzbd = {
      image = "linuxserver/sabnzbd:${sabnzbdVersion}";
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
        # "8080:8080"
      ];

      volumes = [
        "/media/Movie/0-MakeMKV:/media/movies"
        "/media/Show/0-MakeMKV:/media/shows"

        "sabnzbd_config:/config"
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
