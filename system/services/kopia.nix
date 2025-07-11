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

      volumes = let
        # TODO: Setup on ThinkNix: adguard_config, adguard_work, portainer_config
        backup = [
          "authelia_config"
          "formula10_cache"
          "formula10_data"
          "formula11_pb_data"
          "gitea-db_data"
          "gitea_data"
          "gitea-runner_config"
          "gitea-runner_data"
          "heidi_config"
          "immich-database_data"
          "immich_config"
          "immich_data"
          "immich_machine-learning"
          "jellyfin_config"
          "nextcloud-db_data"
          "nextcloud_data"
          "nginx_config"
          "nginx_letsencrypt"
          "nginx_snippets"
          "paperless-postgres_data"
          "paperless_data"
        ];

        mkVolume = name: "${name}:/data/${name}:ro";
      in
        [
          "kopia_config:/app/config"
          "kopia_cache:/app/cache"
          "kopia_logs:/app/logs"
          "kopia_temp:/tmp"

          # Repository where snapshots are stored (incrementally)
          "/media/synology-syncthing:/repository"
        ]
        # Folders that are backed up
        ++ builtins.map mkVolume backup;

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
