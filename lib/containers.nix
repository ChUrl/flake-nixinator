{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Standard DockerHub login used by all oci-container services.
  # Usage: login = mylib.containers.mkDockerLogin config;
  mkDockerLogin = config: {
    username = "christoph.urlacher@protonmail.com";
    passwordFile = "${config.sops.secrets.docker-password.path}";
  };
}
