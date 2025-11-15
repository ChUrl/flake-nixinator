{
  config,
  lib,
  pkgs,
  ...
}: let
  prowlarrVersion = "2.1.5";
in {
  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr:${prowlarrVersion}";
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
        # "9696:9696"
      ];

      volumes = [
        "prowlarr_config:/config"
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
