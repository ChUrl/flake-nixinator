{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  arcaneVersion = "v2.3.0";
in {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."arcane_secrets.env".content = ''
    ENCRYPTION_KEY=${config.sops.placeholder.arcane-encryption-key}
    JWT_SECRET=${config.sops.placeholder.arcane-jwt-secret}
  '';

  virtualisation.oci-containers.containers = {
    arcane = {
      image = "ghcr.io/getarcaneapp/manager:${arcaneVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "3552:3552"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"

        "arcane_data:/app/data"
        "/media/synology-syncthing:/backups"
      ];

      environment = {
        APP_URL = "https://arcane.local.chriphost.de";

        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      environmentFiles = [
        config.sops.templates."arcane_secrets.env".path
      ];

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
