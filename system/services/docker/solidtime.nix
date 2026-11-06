{
  mylib,
  config,
  ...
}: let
  solidtimeVersion = "0.22.1";
  gotenbergVersion = "8";

  # Shared by app, queue and scheduler
  solidtimeEnv = {
    APP_NAME = "solidtime";
    APP_ENV = "production";
    APP_DEBUG = "false";

    # Caddy terminates TLS and forwards plain HTTP; without APP_FORCE_HTTPS the
    # app would build http:// links and send session cookies insecurely.
    APP_URL = "https://time.local.chriphost.gay";
    APP_FORCE_HTTPS = "true";

    # No self-service signup (`on`/`invite-only`/`off`). The first user is
    # created with `docker exec solidtime php artisan admin:user:create ...`.
    APP_ENABLE_REGISTRATION = "off";

    # Caddy runs on the host, so it shows up as the docker bridge gateway
    # (172.16.0.0/12 covers all bridges), not as 127.0.0.1.
    TRUSTED_PROXIES = "172.16.0.0/12";

    # Shared PostgreSQL instance (see services.postgresql below)
    DB_CONNECTION = "pgsql";
    DB_HOST = "host.docker.internal";
    DB_PORT = "5432";
    DB_DATABASE = "solidtime";
    DB_USERNAME = "solidtime";
    DB_SSL_MODE = "prefer";

    # Reminders etc. are handled by the worker container
    QUEUE_CONNECTION = "database";
    CACHE_DRIVER = "database";

    FILESYSTEM_DISK = "local";
    PUBLIC_FILESYSTEM_DISK = "public";

    GOTENBERG_URL = "http://gotenberg:3000";

    # No SMTP on servenix; outgoing mails land in the container log
    MAIL_MAILER = "log";

    LOG_CHANNEL = "stderr";
    LOG_LEVEL = "info";

    TZ = "Europe/Berlin";
  };

  solidtimeCommon = {
    image = "solidtime/solidtime:${solidtimeVersion}";
    autoStart = true;

    login = mylib.containers.mkDockerLogin config;

    volumes = [
      # Sessions/files/compiled views, shared by all three containers.
      # Backed up with /var/lib/docker/volumes by systemmodules/docker.
      "solidtime_storage:/var/www/html/storage"
    ];

    environmentFiles = [
      config.sops.templates."solidtime.env".path
    ];

    extraOptions = [
      "--net=behind-nginx"
      "--add-host=host.docker.internal:host-gateway"
    ];
  };
in {
  # Served by systemmodules/caddy (LAN only, no public alias)
  systemmodules.caddy.vhosts.time = {port = 8095;};

  sops.secrets = {
    "solidtime-app-key" = {};
    "solidtime-passport-private-key" = {};
    "solidtime-passport-public-key" = {};
    "solidtime-db-password" = {};
  };

  # PASSPORT_* are single-line PEMs with literal `\n` escapes — exactly the
  # format `docker run --rm solidtime/solidtime:<tag> php artisan
  # self-host:generate-keys` prints — dotenv expands them back to newlines.
  sops.templates."solidtime.env" = {
    mode = "0400";

    content = ''
      APP_KEY=${config.sops.placeholder."solidtime-app-key"}
      PASSPORT_PRIVATE_KEY="${config.sops.placeholder."solidtime-passport-private-key"}"
      PASSPORT_PUBLIC_KEY="${config.sops.placeholder."solidtime-passport-public-key"}"
      DB_PASSWORD=${config.sops.placeholder."solidtime-db-password"}
      SUPER_ADMINS=christoph.urlacher@protonmail.com
    '';
  };

  # Reuses the shared PostgreSQL instance (same pattern as ente-db.nix and
  # scanopy.nix): containers cannot use the unix socket, so the role gets a
  # SCRAM verifier and the DB is reached over TCP through the docker bridge.
  services.postgresql = {
    enableTCPIP = true;

    ensureDatabases = ["solidtime"];

    ensureUsers = [
      {
        name = "solidtime";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          # SCRAM-SHA-256 verifier for sops `solidtime-db-password`
          password = "SCRAM-SHA-256$4096:aotiJnPs70NhDX2Zy29m2Q==$SPeZyUewbZP++1oIEaKulaEQll6jb8BAAuHjprI+Gpo=:bb9UlmJQI9o2eFjzzz3sCe7b48dJEIKVi7fTcYcpVAA=";
        };
      }
    ];

    authentication = ''
      host all solidtime 172.16.0.0/12 scram-sha-256
    '';
  };

  # Containers cannot authenticate over the unix socket, so they need TCP.
  # ente-db.nix already contributes this rule; repeated here so this service
  # does not silently depend on ente being enabled.
  networking.firewall.extraInputRules = ''
    iifname "br-*" tcp dport 5432 accept
  '';

  # NOTE: The repo's networking module detects port collisions between all
  #       declared listeners; 8095 is free on servenix (8080-8084 are taken).
  virtualisation.oci-containers.containers = {
    solidtime = {
      inherit (solidtimeCommon) image autoStart login volumes environmentFiles extraOptions;

      ports = [
        # Caddy is the only client
        "127.0.0.1:8095:8000"
      ];

      environment =
        solidtimeEnv
        // {
          CONTAINER_MODE = "http";

          # Runs `php artisan migrate --isolated --force` on start. Only the app
          # container gets this; their three migrations would race otherwise.
          AUTO_DB_MIGRATE = "true";
        };
    };

    solidtime-queue = {
      inherit (solidtimeCommon) image autoStart login volumes environmentFiles extraOptions;

      dependsOn = ["solidtime"];

      environment =
        solidtimeEnv
        // {
          CONTAINER_MODE = "worker";
          WORKER_COMMAND = "php /var/www/html/artisan queue:work";
        };
    };

    solidtime-scheduler = {
      inherit (solidtimeCommon) image autoStart login volumes environmentFiles extraOptions;

      dependsOn = ["solidtime"];

      environment =
        solidtimeEnv
        // {
          CONTAINER_MODE = "scheduler";
        };
    };

    gotenberg = {
      image = "gotenberg/gotenberg:${gotenbergVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
