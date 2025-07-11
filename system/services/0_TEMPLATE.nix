{
  config,
  lib,
  pkgs,
  ...
}: {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."TEMPLATE_secrets.env".content = ''
    SECRET=${config.sops.placeholder.SECRET}
  '';

  virtualisation.oci-containers.containers.TEMPLATE = {
    image = "TEMPLATE";
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

    volumes = [];

    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Berlin";
    };

    environmentFiles = [
      config.sops.templates."TEMPLATE_secrets.env".path
    ];

    extraOptions = [
      # "--privileged"
      # "--device=nvidia.com/gpu=all"
      "--net=behind-nginx"
    ];
  };
}
