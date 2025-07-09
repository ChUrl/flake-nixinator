{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.TEMPLATE = {
    image = "TEMPLATE";
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [];

    ports = [];

    volumes = [];

    environment = {
      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Berlin";
      # NVIDIA_VISIBLE_DEVICES = "all";
      # NVIDIA_DRIVER_CAPABILITIES = "all";
    };

    extraOptions = [
      # "--gpus=all"
      "--net=behind-nginx"
    ];
  };
}
