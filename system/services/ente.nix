{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  # GHCR only has `latest` or commit SHAs, so we use a SHA that exists on
  # ghcr.io/ente/server and ghcr.io/ente/web (both).
  enteServerVersion = "20fb6316bd98b1af613ef771c684d5cd46fbf371"; # 2026-10-15
  enteWebVersion = "4a3e62d47796abadf61c2717a6eb7022bbcbd072"; # 2026-10-28
  siloVersion = "RELEASE.2026-10-26T00-00-00Z";

  domain = "local.chriphost.de";
  webHost = "duck.${domain}";
  apiHost = "duck-api.${domain}";
  albumsHost = "duck-albums.${domain}";
  s3Host = "duck-s3.${domain}";

  dataDir = "/var/lib/ente";
in {
  # NOTE: Init the secrets with
  # openssl rand -base64 32                    # ente-key-encryption (32 bytes, std b64)
  # openssl rand -base64 64                    # ente-key-hash (64 bytes, std b64)
  # openssl rand -base64 32 | tr '+/' '-_'     # ente-jwt-secret (URL-safe, keep padding)
  # openssl rand -hex 16                       # ente-db-password
  # openssl rand -hex 8                        # ente-s3-user
  # openssl rand -hex 24                       # ente-s3-password

  # postgres + minio read this
  sops.templates."ente-env".content = ''
    POSTGRES_USER=ente
    POSTGRES_DB=ente_db
    POSTGRES_PASSWORD=${config.sops.placeholder."ente-db-password"}
    MINIO_ROOT_USER=${config.sops.placeholder."ente-s3-user"}
    MINIO_ROOT_PASSWORD=${config.sops.placeholder."ente-s3-password"}
  '';

  # This replaces server/config/museum.yaml. Don't put these in the Nix store!
  sops.templates."ente-museum-yaml".content = ''
    db:
      host: ente-postgres
      port: 5432
      name: ente_db
      user: ente
      password: "${config.sops.placeholder."ente-db-password"}"
      sslmode: disable

    s3:
      # HTTPS via nginx => must be false, and MinIO needs path-style URLs.
      are_local_buckets: false
      use_path_style_urls: true
      b2-eu-cen:
        key: "${config.sops.placeholder."ente-s3-user"}"
        secret: "${config.sops.placeholder."ente-s3-password"}"
        endpoint: ${s3Host}
        region: eu-central-2
        bucket: b2-eu-cen

    apps:
      public-albums: https://${albumsHost}

    key:
      encryption: "${config.sops.placeholder."ente-key-encryption"}"
      hash: "${config.sops.placeholder."ente-key-hash"}"

    jwt:
      secret: "${config.sops.placeholder."ente-jwt-secret"}"
  '';

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/postgres 0700 root root -"
    "d ${dataDir}/minio 0750 root root -"
    # replaces the compose `post_start: mc mb`
    "d ${dataDir}/minio/b2-eu-cen 0750 root root -"
  ];

  virtualisation.oci-containers.containers = {
    ente-postgres = {
      image = "docker.io/library/postgres:15";
      autoStart = true;
      environmentFiles = [config.sops.templates."ente-env".path];
      volumes = ["${dataDir}/postgres:/var/lib/postgresql/data"];
      networks = ["ente-internal"];
    };

    ente-minio = {
      image = "docker.io/pgsty/silo:${siloVersion}";
      autoStart = true;
      cmd = ["server" "/data" "--address" ":3200" "--console-address" ":3201"];
      environmentFiles = [config.sops.templates."ente-env".path];
      # Browser uploads go straight to this bucket, so CORS must allow the web app.
      environment.MINIO_API_CORS_ALLOW_ORIGIN = "https://${webHost},https://${albumsHost}";
      volumes = ["${dataDir}/minio:/data"];
      networks = ["behind-nginx"];
    };

    ente-museum = {
      image = "ghcr.io/ente/server:${enteServerVersion}";
      autoStart = true;
      dependsOn = ["ente-postgres"];
      volumes = [
        "${config.sops.templates."ente-museum-yaml".path}:/museum.yaml:ro"
      ];
      networks = ["ente-internal" "behind-nginx"];
    };

    ente-web = {
      image = "ghcr.io/ente/web:${enteWebVersion}";
      autoStart = true;
      environment.ENTE_API_ORIGIN = "https://${apiHost}";
      networks = ["behind-nginx"];
    };
  };

  systemd.services =
    {
      # oci-containers doesn't create networks, so do it before the containers.
      ente-network = {
        wantedBy = ["multi-user.target"];
        requires = ["docker.service"];
        after = ["docker.service"];
        before = ["docker-ente-postgres.service" "docker-ente-minio.service"];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.docker}/bin/docker network inspect ente-internal >/dev/null 2>&1 ||
            ${pkgs.docker}/bin/docker network create ente-internal
        '';
      };
    }
    // lib.genAttrs
    ["docker-ente-postgres" "docker-ente-minio" "docker-ente-museum" "docker-ente-web"]
    (_: {
      # The museum panics if Postgres isn't accepting connections yet, so the
      # module's unit is Restart=on-failure, just make sure systemd doesn't
      # rate-limit it.
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig.RestartSec = "10s";
    });
}
