{
  inputs,
  hostname,
  lib,
  mylib,
  config,
  pkgs,
  system,
  username,
  headless,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # My own services
    ../services/docker/heidi.nix
    ../services/docker/formula10.nix
    ../services/docker/formula11.nix
    ../services/docker/formula12.nix

    # General services
    ../services/nixos/actual.nix
    (import ../services/docker/arcane-agent.nix {
      tokenSecret = "arcane-agent-key";
      network = "behind-nginx";
      backupsPath = "/media/Arcane";
    })
    ../services/docker/bazarr.nix
    ../services/docker/bento_pdf.nix
    ../services/nixos/ente-db.nix
    ../services/docker/ente.nix
    ../services/docker/fileflows.nix
    ../services/nixos/gitea.nix
    ../services/nixos/gitea-runner.nix
    ../services/nixos/immich.nix
    ../services/nixos/jellyfin.nix
    ../services/nixos/kiwix.nix
    ../services/nixos/mailpit.nix
    ../services/nixos/nextcloud.nix
    ../services/nixos/ntfy.nix
    ../services/nixos/paperless.nix
    ../services/docker/prowlarr.nix
    ../services/docker/radarr.nix
    ../services/docker/sabnzbd-movies.nix
    ../services/docker/sabnzbd-shows.nix
    ../services/docker/sonarr.nix
    ../services/docker/tinymediamanager.nix
  ];

  networking.tempAddresses = "disabled";

  # PostgreSQL 14 (the default for this stateVersion) is EOL and the container
  # databases we are migrating come from 15/16. 17 has vectorchord + pgvector
  # and keeps the data dir at /var/lib/postgresql/17, so the old cluster stays
  # untouched as a rollback.
  services.postgresql = {
    package = pkgs.postgresql_17;

    # The shared instance now serves gitea, paperless, immich and nextcloud.
    # 256MB (the default) is too small: Nextcloud's admin check reported an
    # 87% buffer cache hit ratio.
    settings = {
      shared_buffers = "4GB";
      effective_cache_size = "12GB";
    };
  };

  systemmodules = {
    remote-build.enable = true;

    caddy = {
      enable = true;

      # Thinknix terminates TLS and forwards plain HTTP here.
      # The port stays non-standard, so neither host depends on the
      # other's cutover.
      httpPort = 9080;
      httpsPort = null;
      autoHttps = false;
      openFirewall = true;
    };

    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;

        ipv6.enable = true;
        ipv6.subnet = "fd00:1::/64";
        # ipv6.gateway = "fd00::5";
      }
    ];

    restic = {
      enable = true;

      # The services declare their own state directories
      # (systemmodules.restic.servicePaths). Only what restic produces itself is
      # listed here.
      paths = [
        # Live databases are dumped in prepareCommand instead
        "/var/backup"
      ];

      extraBackupArgs = [
        "--exclude-caches"
        "--cleanup-cache"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];

      prepareCommand = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/backup

        # Left in case we need to backup databases from docker in the future
        dump() {
          name="$1"
          container="$2"
          user="$3"

          if ${config.virtualisation.docker.package}/bin/docker exec "$container" \
               pg_dumpall -U "$user" > "/var/backup/$name.sql.tmp" 2>/dev/null; then
            ${pkgs.coreutils}/bin/mv "/var/backup/$name.sql.tmp" "/var/backup/$name.sql"
          else
            ${pkgs.coreutils}/bin/rm -f "/var/backup/$name.sql.tmp"
            echo "WARNING: dump of $name failed" >&2
          fi
        }

        # Native services on the shared PostgreSQL instance
        ${pkgs.util-linux}/bin/runuser -u postgres -- \
          ${config.services.postgresql.finalPackage}/bin/pg_dumpall \
          > /var/backup/postgres.sql.tmp \
          && ${pkgs.coreutils}/bin/mv /var/backup/postgres.sql.tmp /var/backup/postgres.sql
      '';

      # Cleanup the prepare
      cleanupCommand = "${pkgs.coreutils}/bin/rm -rf /var/backup/*";
    };

    network = {
      useNetworkManager = false;
      networks = {
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "ens18";
          ips = ["192.168.86.25/24"];
          routers = ["192.168.86.5"]; # Don't add IPv6 gateway, rely on router advertisement instead
          nameservers = ["8.8.8.8" "8.8.4.4" "2001:4860:4860:8888" "2001:4860:4860:8844"]; # NOTE: Use reliable DNS for servers instead of 192.168.86.26
          routable = true;
          privacy = "no";
          extraAddresses = ["fd00::19/64"]; # IPv6 ULA — declared without creating a route
        };
      };

      # NOTE: Streams: Ports have to be opened in the VPS firewall +
      #       VPS UFW and bound in the VPS Nginx compose file.

      # The SSH port is opened by the ssh systemmodule, the Caddy ports by the
      # caddy systemmodule and the service ports (e.g. gitea's SSH port) by the
      # service modules
      allowedTCPPorts = [];

      allowedUDPPorts = [];
    };
  };

  # List services that you want to enable:
  # Keep the nvidia device nodes (/dev/nvidia0, nvidiactl, …) present so the
  # jellyfin service can be granted access to them for NVENC.
  hardware.nvidia.nvidiaPersistenced = true;

  services = {
    # Every service declares its own vhost (systemmodules.caddy.vhosts).
    # Thinknix terminates TLS and is the only client of this host: it forwards
    # requests over plain HTTP on the LAN, so no certificates are needed here.
    caddy.virtualHosts = {
      # Catch-all: an unknown Host header gets a clear 404 instead of the
      # empty 200 Caddy returns otherwise, which looked like a blank page.
      ":9080" = {
        extraConfig = ''respond "no vhost for this host" 404'';
      };
    };

    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "altgr-intl";
      videoDrivers = ["nvidia"];
    };

    qemuGuest.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
