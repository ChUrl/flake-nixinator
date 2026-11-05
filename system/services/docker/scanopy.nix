{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  # Pin the release; upstream's compose file uses :latest.
  scanopyVersion = "v0.19.6";
in {
  systemmodules.caddy.vhosts.scanopy = {port = 60072;};

  # Database is dumped by restic
  systemmodules.restic.servicePaths = [
    "/var/lib/scanopy"
    "/var/lib/scanopy-daemon"
  ];

  sops.secrets."scanopy-db-password" = {};

  sops.templates."scanopy.env" = {
    mode = "0400";
    content = ''
      SCANOPY_DATABASE_URL=postgresql://scanopy:${config.sops.placeholder."scanopy-db-password"}@host.docker.internal:5432/scanopy
    '';
  };

  # The shared PostgreSQL instance also serves scanopy, same pattern as
  # ente-db.nix: the container reaches it over TCP through the docker bridge.
  services.postgresql = {
    enableTCPIP = true;

    ensureDatabases = ["scanopy"];

    ensureUsers = [
      {
        name = "scanopy";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          # SCRAM-SHA-256 verifier for sops `scanopy-db-password`
          password = "SCRAM-SHA-256$4096:rei5zU8hESalo5DZIkQ9qw==$SOKQAQTPCRyWOWydVuo0r5ylB3TGkfaBZHblsHEYiaU=:ahkGRBnNU4klJAfNp42Ejq83BwFjs0E2TYEW0Da0rF4=";
        };
      }
    ];

    authentication = ''
      host all scanopy 172.16.0.0/12 scram-sha-256
    '';
  };

  # server (container) -> integrated daemon (host network) on 60073
  networking.firewall.extraInputRules = ''
    iifname "br-*" tcp dport 60073 accept
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/scanopy 0755 root root -"
    "d /var/lib/scanopy-daemon 0755 root root -"
  ];

  virtualisation.oci-containers.containers = {
    scanopy-server = {
      image = "ghcr.io/scanopy/scanopy/server:${scanopyVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      ports = [
        # Caddy is the only client
        "127.0.0.1:60072:60072"
      ];

      volumes = [
        "/var/lib/scanopy:/data"
      ];

      environmentFiles = [
        config.sops.templates."scanopy.env".path
      ];

      environment = {
        # Used in invite and password-reset links; LAN name, not the public one
        SCANOPY_PUBLIC_URL = "https://scanopy.local.chriphost.gay";

        # thinknix terminates TLS
        SCANOPY_USE_SECURE_SESSION_COOKIES = "true";

        # The image keeps the UI outside the binary; without this the server
        # starts API-only and every UI route returns 404.
        SCANOPY_WEB_EXTERNAL_PATH = "/app/static";

        # The integrated daemon runs on the host, not in this docker network
        SCANOPY_INTEGRATED_DAEMON_URL = "http://host.docker.internal:60073";

        # NOTE: Do not set SCANOPY_CLIENT_IP_SOURCE. The integrated daemon talks
        #       to the server without the proxy header, so every one of its
        #       requests would be answered with HTTP 500.

        # NOTE: Enable this after the first account has been registered:
        SCANOPY_DISABLE_REGISTRATION = "true";

        TZ = "Europe/Berlin";
      };

      extraOptions = [
        "--net=behind-nginx"
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

    scanopy-daemon = {
      image = "ghcr.io/scanopy/scanopy/daemon:${scanopyVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      volumes = [
        "/var/lib/scanopy-daemon:/root/.config/scanopy/daemon"

        # Docker discovery
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        SCANOPY_SERVER_URL = "http://127.0.0.1:60072";
        SCANOPY_LOG_LEVEL = "info";

        # Without this the daemon also scans the docker bridges (172.17.0.0/16
        # and 172.18.0.0/16), which would be two /16 full port scans. Container
        # networks still show up through the docker socket below.
        SCANOPY_INTERFACES = "ens18";

        TZ = "Europe/Berlin";
      };

      extraOptions = [
        # ARP has to happen on the real L2 segment; privileged for the raw
        # sockets (same reason as cadvisor).
        "--net=host"
        "--privileged"
      ];
    };
  };
}
