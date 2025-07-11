{
  config,
  lib,
  pkgs,
  ...
}: let
  kopiaVersion = "0.20.1";
in {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."kopia_secrets.env".content = ''
    KOPIA_PASSWORD=${config.sops.placeholder.kopia-user-password}
    KOPIA_SERVER_USERNAME=${config.sops.placeholder.kopia-server-username}
    KOPIA_SERVER_PASSWORD=${config.sops.placeholder.kopia-server-password}
  '';

  virtualisation.oci-containers.containers = {
    kopia = {
      image = "kopia/kopia:${kopiaVersion}";
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
        # "51515:51515"
      ];

      volumes = [
        "kopia_config:/app/config"
        "kopia_cache:/app/cache"
        "kopia_logs:/app/logs"
        "kopia_temp:/tmp"

        # Repository, where snapshots are stored (incrementally)
        "/media/synology-syncthing:/repository"

        # Folders that are backed up
        # "adguard_config:/data/adguard_config:ro" # ThinkNix
        # "adguard_work:/data/adguard_work:ro" # ThinkNix

        "authelia_config:/data/authelia_config:ro"

        "formula10_cache:/data/formula10_cache:ro"
        "formula10_data:/data/formula10_data:ro"

        "formula11_pb_data:/data/formula11_pb_data:ro"

        "gitea-db_data:/data/gitea-db_data:ro"
        "gitea-runner_config:/data/gitea-runner_config:ro"
        "gitea-runner_data:/data/gitea-runner_data:ro"
        "gitea_data:/data/gitea_data:ro"

        "heidi_config:/data/heidi_config:ro"

        "immich-database_data:/data/immich-database_data:ro"
        "immich_config:/data/immich_config:ro"
        "immich_data:/data/immich_data:ro"
        "immich_machine-learning:/data/immich_machine-learning:ro"

        "jellyfin_config:/data/jellyfin_config:ro"

        "nextcloud-db_data:/data/nextcloud-db_data:ro"
        "nextcloud_data:/data/nextcloud_data:ro"

        "nginx_config:/data/nginx_config:ro"
        "nginx_letsencrypt:/data/nginx_letsencrypt:ro"
        "nginx_snippets:/data/nginx_snippets:ro"

        "paperless-postgres_data:/data/paperless-postgres_data:ro"
        "paperless_data:/data/paperless_data:ro"

        # "portainer_config:/data/portainer_config:ro"
      ];

      environment = {
        TZ = "Europe/Berlin";
        USER = "christoph";
      };

      environmentFiles = [
        config.sops.templates."kopia_secrets.env".path
      ];

      entrypoint = "/bin/kopia";

      cmd = [
        "server"
        "start"
        "--disable-csrf-token-checks"
        "--insecure"
        "--address=0.0.0.0:51515"
      ];

      extraOptions = [
        "--privileged"
        "--device=/dev/fuse:/dev/fuse:rwm"
        "--cap-add=SYS_ADMIN"
        "--net=behind-nginx"
      ];
    };
  };
}
