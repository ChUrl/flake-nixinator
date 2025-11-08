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

        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
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
