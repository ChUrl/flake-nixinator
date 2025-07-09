{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.portainer-agent = {
    image = "portainer/agent:latest";
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
