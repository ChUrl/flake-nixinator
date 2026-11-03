{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  arcaneVersion = "v2.17.0";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.arcane = {port = 3552;};

  sops.secrets."arcane-encryption-key" = {};

  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."arcane_secrets.env".content = ''
    ENCRYPTION_KEY=${config.sops.placeholder.arcane-encryption-key}
  '';

  virtualisation.oci-containers.containers = {
    arcane = {
      image = "ghcr.io/getarcaneapp/manager:${arcaneVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "3552:3552"
        "127.0.0.1:3552:3552"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"

        "arcane_data:/app/data"
        "/media/Arcane:/backups"
      ];

      environment = {
        APP_URL = "https://arcane.local.chriphost.gay";

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
