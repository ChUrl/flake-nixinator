{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.portainer = {
    image = "portainer/portainer-ce:latest";
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
      # "8000:8000"
      # "9443:9443"
    ];

    volumes = [
      "portainer_config:/data"

      "/var/run/docker.sock:/var/run/docker.sock"
    ];

    environment = {};

    extraOptions = [
      "--net=behind-nginx"
    ];
  };
}
