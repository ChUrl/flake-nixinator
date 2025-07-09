{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia:latest";
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
      # "9091:9091"
    ];

    volumes = [
      "authelia_config:/config"
    ];

    environment = {
      TZ = "Europe/Berlin";
    };

    extraOptions = [
      "--net=behind-nginx"
    ];
  };
}
