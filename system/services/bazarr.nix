{
  config,
  lib,
  pkgs,
  ...
}: let
  bazarrVersion = "1.5.3";
in {
  virtualisation.oci-containers.containers = {
    bazarr = {
      image = "linuxserver/bazarr:${bazarrVersion}";
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
        # "6767:6766"
      ];

      volumes = [
        "/media/Movie:/media/movies"
        "/media/Show:/media/shows"

        "bazarr_config:/config"
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
