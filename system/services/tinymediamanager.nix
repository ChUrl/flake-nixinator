{
  config,
  lib,
  pkgs,
  ...
}: let
  version = "5.2.3";
in {
  virtualisation.oci-containers.containers = {
    tinymediamanager = {
      image = "tinymediamanager/tinymediamanager:${version}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [];

      ports = [];

      volumes = [
        "tinymediamanager_data:/data"

        "/media/Show:/media/tvshows"
        "/media/Movie:/media/movies"
        "/media/MusicVideos:/media/musicvideos"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        USER_ID = "1000";
        GROUP_ID = "1000";
        ALLOW_DIRECT_VNC = "true";
        LC_ALL = "en_US.UTF-8"; # force UTF8
        LANG = "en_US.UTF-8"; # force UTF8
        PASSWORD = "<password>";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
