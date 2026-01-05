{
  config,
  lib,
  pkgs,
  ...
}: let
  fileflowsVersion = "25.10";
in {
  virtualisation.oci-containers.containers = {
    fileflows-node = {
      image = "revenz/fileflows:${fileflowsVersion}";
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
        "/home/christoph/Movies:/media/movies"
        "/home/christoph/Shows:/media/tvshows"
        "/home/christoph/MusicVideos:/media/musicvideos"

        "fileflows_temp:/temp"

        "/var/run/docker.sock:/var/run/docker.socl:ro"
      ];

      hostname = "Nixinator";

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";

        FFNODE = "1";
        ServerUrl = "https://fileflows.local.chriphost.de";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
