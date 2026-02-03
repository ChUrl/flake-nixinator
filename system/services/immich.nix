{
  config,
  lib,
  pkgs,
  ...
}: let
  vectorchordVersion = "0.4.2";
  pgvectorsVersion = "0.2.0";
  immichVersion = "2.5.2";
in {
  virtualisation.oci-containers.containers = {
    immich-database = {
      # image = "ghcr.io/immich-app/postgres:15-vectorchord0.3.0-pgvectors0.2.0";
      image = "ghcr.io/immich-app/postgres:15-vectorchord${vectorchordVersion}-pgvectors${pgvectorsVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [
        # "5432:5432"
      ];

      volumes = [
        "immich-database_data:/var/lib/postgresql/data"
      ];

      environment = {
        POSTGRES_USER = "immich";
        POSTGRES_PASSWORD = "immich";
        POSTGRES_DB = "immich";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    immich-redis = {
      image = "redis";
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
        # "6379:6379"
      ];

      volumes = [];

      environment = {};

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    immich = {
      image = "ghcr.io/imagegenius/immich:${immichVersion}";
      autoStart = true;

      dependsOn = [
        "immich-database"
        "immich-redis"
      ];

      ports = [
        "2283:8080" # Bind for VPS
      ];

      volumes = [
        "immich_config:/config"
        "immich_data:/photos"
        "immich_machine-learning:/config/machine-learning"
        # "immich_imports:/import:ro"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        DB_HOSTNAME = "immich-database";
        DB_USERNAME = "immich";
        DB_PASSWORD = "immich";
        # DB_PORT = "5432";
        DB_DATABASE_NAME = "immich";

        REDIS_HOSTNAME = "immich-redis";
        # REDIS_PORT = "6379";
        # REDIS_PASSWORD = "";

        MACHINE_LEARNING_WORKERS = "1";
        MACHINE_LEARNING_WORKER_TIMEOUT = "120";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
