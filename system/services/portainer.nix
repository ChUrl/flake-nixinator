{
  config,
  lib,
  pkgs,
  ...
}: {
  # virtualisation.oci-containers.containers.portainer = {
  #   image = "portainer/portainer-ce:latest";
  #   autoStart = true;

  #   dependsOn = [];

  #   ports = [
  #     # "8000:8000"
  #     # "9443:9443"
  #   ];

  #   volumes = [
  #     "portainer_config:/data"

  #     "/var/run/docker.sock:/var/run/docker.sock"
  #   ];

  #   environment = {};

  #   extraOptions = [
  #     "--net=behind-nginx"
  #   ];
  # };

  virtualisation.oci-containers.containers.portainer-agent = {
    image = "portainer/agent:latest";
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [];

    ports = [
      "9001:9001"
    ];

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "/var/lib/docker/volumes:/var/lib/docker/volumes"
    ];

    environment = {};

    extraOptions = [
      # This container needs to be accessible from another machine inside the LAN
      # "--net=behind-nginx"
    ];
  };
}
