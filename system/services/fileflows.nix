{
  config,
  lib,
  pkgs,
  ...
}: let
  version = "25.10";
in {
  virtualisation.oci-containers.containers = {
    fileflows = {
      image = "revenz/fileflows:${version}";
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
        "fileflows_temp:/temp"
        "fileflows_data:/app/Data"
        "fileflows_logs:/app/Logs"

        "/media/Movie:/media/movies"
        "/media/Show:/media/tvshows"
        "/media/MusicVideos:/media/musicvideos"

        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
