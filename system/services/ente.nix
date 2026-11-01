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
  postgresVersion = "15";

  domain = "local.chriphost.de";
  webHost = "duck.${domain}";
  apiHost = "duck-api.${domain}";
  albumsHost = "duck-albums.${domain}";
  s3Host = "duck-s3.${domain}";
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

  # Museum reads `ENTE_*` environment variables as its config source
  # (see configurations/local.yaml in the server image), so no
  # museum.yaml needs to be mounted into the container.
  sops.templates."ente-museum-env".content = ''
    ENTE_DB_HOST=ente-postgres
    ENTE_DB_PORT=5432
    ENTE_DB_NAME=ente_db
    ENTE_DB_USER=ente
    ENTE_DB_PASSWORD=${config.sops.placeholder."ente-db-password"}
    ENTE_DB_SSLMODE=disable

    ENTE_SMTP_HOST=mailpit
    ENTE_SMTP_PORT=1025

    ENTE_S3_ARE_LOCAL_BUCKETS=false
    ENTE_S3_USE_PATH_STYLE_URLS=true
    ENTE_S3_B2_EU_CEN_KEY=${config.sops.placeholder."ente-s3-user"}
    ENTE_S3_B2_EU_CEN_SECRET=${config.sops.placeholder."ente-s3-password"}
    ENTE_S3_B2_EU_CEN_ENDPOINT=${s3Host}
    ENTE_S3_B2_EU_CEN_REGION=eu-central-2
    ENTE_S3_B2_EU_CEN_BUCKET=b2-eu-cen

    ENTE_APPS_PUBLIC_ALBUMS=https://${albumsHost}

    ENTE_KEY_ENCRYPTION=${config.sops.placeholder."ente-key-encryption"}
    ENTE_KEY_HASH=${config.sops.placeholder."ente-key-hash"}
    ENTE_JWT_SECRET=${config.sops.placeholder."ente-jwt-secret"}
  '';

  virtualisation.oci-containers.containers = {
    ente-postgres = {
      image = "docker.io/library/postgres:${postgresVersion}";
      autoStart = true;
      environmentFiles = [config.sops.templates."ente-env".path];
      volumes = ["ente-postgres_data:/var/lib/postgresql/data"];
      networks = ["ente-internal"];
    };

    ente-minio = {
      image = "docker.io/pgsty/silo:${siloVersion}";
      autoStart = true;
      cmd = ["server" "/data" "--address" ":3200" "--console-address" ":3201"];
      environmentFiles = [config.sops.templates."ente-env".path];
      # Browser and desktop uploads go straight to this bucket, so CORS must
      # allow the web app, the albums app and the desktop app (ente://app).
      environment.MINIO_API_CORS_ALLOW_ORIGIN = "https://${webHost},https://${albumsHost},ente://app";
      volumes = ["ente-minio_data:/data"];
      ports = ["127.0.0.1:3013:3200"];
      networks = ["behind-nginx"];
    };

    ente-museum = {
      image = "ghcr.io/ente/server:${enteServerVersion}";
      autoStart = true;
      dependsOn = ["ente-postgres"];
      environmentFiles = [config.sops.templates."ente-museum-env".path];
      ports = ["127.0.0.1:3012:8080"];
      networks = ["ente-internal" "behind-nginx"];
    };

    ente-web = {
      image = "ghcr.io/ente/web:${enteWebVersion}";
      autoStart = true;
      environment.ENTE_API_ORIGIN = "https://${apiHost}";
      ports = [
        "127.0.0.1:3010:3000" # web
        "127.0.0.1:3011:3002" # albums
      ];
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

      # Docker initializes a fresh named volume empty, but museum expects the
      # bucket to already exist (example compose does this with `mc mb`).
      ente-minio-init = {
        wantedBy = ["multi-user.target"];
        requires = ["docker.service"];
        after = ["docker.service"];
        before = ["docker-ente-minio.service"];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.docker}/bin/docker run --rm \
            -v ente-minio_data:/data \
            docker.io/library/alpine:3.22 \
            sh -c 'mkdir -p /data/b2-eu-cen && chmod 0750 /data/b2-eu-cen'
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
