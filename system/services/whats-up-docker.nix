{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.whats-up-docker = {
    image = "getwud/wud:latest";
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [
      # "pihole"
    ];

    ports = [
      # "3001:3000"
    ];

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
    ];

    environment = {};

    extraOptions = [
      "--net=behind-nginx"
    ];
  };
}
