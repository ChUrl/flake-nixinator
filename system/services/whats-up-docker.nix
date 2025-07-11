{
  config,
  lib,
  pkgs,
  ...
}: let
  wudVersion = "8.1.1";
in {
  virtualisation.oci-containers.containers = {
    whats-up-docker = {
      image = "getwud/wud:${wudVersion}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
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
  };
}
