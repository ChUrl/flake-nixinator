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
    ../services/docker/cadvisor.nix
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

  services.postgresql = {
    package = pkgs.postgresql_17;

    # The shared instance now serves gitea, paperless, immich and nextcloud.
    # 256MB (the default) is too small: Nextcloud's admin check reported an
    # 87% buffer cache hit ratio.
    settings = {
      shared_buffers = "4GB";
      effective_cache_size = "12GB";

      # Stock autovacuum (naptime 60s, vacuum_scale_factor 0.2, cost_limit 200)
      # cannot keep up with the oc_filecache churn of a sync that touches
      # hundreds of thousands of files: Nextcloud's admin check reported 158k
      # dead tuples on a single table.
      autovacuum_naptime = "30s";
      autovacuum_vacuum_scale_factor = "0.02";
      autovacuum_analyze_scale_factor = "0.01";
      autovacuum_vacuum_cost_limit = "2000";
      autovacuum_work_mem = "256MB";

      # Autovacuum, VACUUM and index builds on a table this large.
      maintenance_work_mem = "512MB";

      # The data disk is an SSD; the 4.0 default makes the planner prefer
      # sequential scans over the indexes used by the filecache lookups.
      random_page_cost = "1.1";
      effective_io_concurrency = "200";

      # Nextcloud issues a lot of small sorts and joins; 4MB is tight.
      work_mem = "16MB";

      # Fewer forced checkpoints while a bulk sync is writing, which otherwise
      # shows up as stalls in the middle of an upload.
      max_wal_size = "4GB";
      checkpoint_completion_target = "0.9";
    };
  };

  systemmodules = {
    remote-build.enable = true;

    monitoring-agent.listenAddress = "127.0.0.1";

    monitoring = {
      enable = true;

      # node_exporter targets. PVE/PVF need `prometheus-node-exporter`
      # installed on the Debian host; nixinator is a desktop and is excluded
      # from the "host down" alert.
      nodes = {
        servenix = "127.0.0.1:9100";
        thinknix = "192.168.86.26:9100";
        nixinator = "192.168.86.50:9100";
        vps = "10.10.10.1:9100";
        pve = "192.168.86.4:9100";
        pvf = "192.168.86.13:9100";
      };

      # Polled through prometheus-pve-exporter (API token, not SSH). Both
      # nodes belong to the same cluster ("clusterio"), so one token created
      # with `pveum` on either node authenticates against both.
      proxmoxTargets = ["192.168.86.4" "192.168.86.13"];

      # Keep the growing TSDB off the root filesystem (the `ssd` mount in
      # hardware-configuration.nix). Bind-mounted over the service's state
      # directory, and owned by the `prometheus` user.
      prometheusDataDir = "/home/christoph/ssd/prometheus";

      # End-to-end checks. The public names exercise VPS -> WireGuard ->
      # thinknix -> servenix; Grafana itself is checked locally because
      # servenix uses public DNS and cannot resolve *.local.chriphost.gay.
      probes = {
        status = {url = "https://status.vps.chriphost.gay";};
        gitea = {url = "https://gitea.vps.chriphost.gay";};
        immich = {url = "https://immich.vps.chriphost.gay";};
        jellyfin = {url = "https://jellyfin.vps.chriphost.gay";};
        nextcloud = {url = "https://nextcloud.vps.chriphost.gay";};
        paperless = {url = "https://paperless.vps.chriphost.gay";};
        ntfy = {url = "https://ntfy.vps.chriphost.gay";};
        f10 = {url = "https://f10.vps.chriphost.gay";};
        f11 = {url = "https://f11.vps.chriphost.gay";};
        f12 = {url = "https://f12.vps.chriphost.gay";};
        f11pb = {url = "https://f11pb.vps.chriphost.gay/api/health";};
        f12pb = {url = "https://f12pb.vps.chriphost.gay/api/health";};
        grafana = {url = "http://127.0.0.1:3030/api/health";};
      };
    };

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
