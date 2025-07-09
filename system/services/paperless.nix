{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.paperless-redis = {
    image = "redis:7";
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [];

    ports = [];

    volumes = [
      "paperless-redis_data:/data"
    ];

    environment = {};

    extraOptions = [
      "--net=behind-nginx"
    ];
  };

  virtualisation.oci-containers.containers.paperless-postgres = {
    image = "postgres:15";
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [];

    ports = [];

    volumes = [
      "paperless-postgres_data:/var/lib/postgresql/data"
    ];

    environment = {
      POSTGRES_DB = "paperless";
      POSTGRES_USER = "paperless";
      POSTGRES_PASSWORD = "paperless";
    };

    extraOptions = [
      "--net=behind-nginx"
    ];
  };

  virtualisation.oci-containers.containers.paperless = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    autoStart = true;

    # login = {
    #   # Uses DockerHub by default
    #   # registry = "";
    #
    #   # DockerHub Credentials
    #   username = "christoph.urlacher@protonmail.com";
    #   passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    # };

    dependsOn = [
      "paperless-redis"
      "paperless-postgres"
    ];

    ports = [
      "8000:8000"
    ];

    volumes = [
      "paperless_data:/usr/src/paperless/data"
      "/media/paperless-media:/usr/src/paperless/media"
      "/media/paperless-export:/usr/src/paperless/export"
      "/media/paperless-consume:/usr/src/paperless/consume"
    ];

    environment = {
      PAPERLESS_REDIS = "redis://paperless-redis:6379";
      PAPERLESS_DBHOST = "paperless-postgres";

      # PAPERLESS_ADMIN_USER = "root";
      # PAPERLESS_ADMIN_PASSWORD = "admin";

      PAPERLESS_URL = "https://*.chriphost.de";
      # PAPERLESS_CSRF_TRUSTED_ORIGINS = "[https://paperless.local.chriphost.de,https://paperless.vps.chriphost.de]";
      # PAPERLESS_ALLOWED_HOSTS = "[https://paperless.local.chriphost.de,https://paperless.vps.chriphost.de]";
      # PAPERLESS_CORS_ALLOWED_HOSTS = "[https://paperless.local.chriphost.de,https://paperless.vps.chriphost.de]";
    };

    extraOptions = [
      # "--gpus=all"
      "--net=behind-nginx"
    ];
  };
}
