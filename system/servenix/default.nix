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
    ../services/docker/ente.nix
    ../services/docker/fileflows.nix
    ../services/nixos/gitea.nix
    ../services/nixos/gitea-runner.nix
    ../services/docker/immich.nix
    ../services/nixos/jellyfin.nix
    ../services/nixos/kiwix.nix
    ../services/nixos/mailpit.nix
    ../services/docker/nextcloud.nix
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

  systemmodules = {
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

      paths = [
        "/var/lib/docker/volumes"
        "/var/backup"
      ];

      extraBackupArgs = [
        "--exclude-caches"
        "--cleanup-cache"

        # Don't copy live databases. Done in prepareCommand
        "--exclude=/var/lib/docker/volumes/gitea-db_data"
        "--exclude=/var/lib/docker/volumes/immich-database_data"
        "--exclude=/var/lib/docker/volumes/nextcloud-db_data"
        "--exclude=/var/lib/docker/volumes/paperless-postgres_data"
        "--exclude=/var/lib/docker/volumes/ente-postgres_data"
      ];

      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        "--keep-monthly 2"
      ];

      prepareCommand = ''
        ${pkgs.coreutils}/bin/mkdir -p /var/backup

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

        # Remaining container databases
        dump immich    immich-database     immich
        dump nextcloud nextcloud-db        nextcloud
        dump ente      ente-postgres       ente
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

      # The SSH port is opened by the ssh systemmodule and the Caddy ports
      # by the caddy systemmodule
      allowedTCPPorts = [
        222 # Gitea SSH (LAN clients)
      ];

      allowedUDPPorts = [];
    };

    # TODO: Fold those into the respective service files
    sops-nix.secrets.${username} = [
      "heidi-discord-token"
      "paperless-nextcloud-sync-password"
      "paperless-secret-key"
      "ntfy-auth-users"
      "ntfy-auth-tokens"
      "arcane-agent-key"
      "ente-db-password"
      "ente-s3-user"
      "ente-s3-password"
      "ente-key-encryption"
      "ente-key-hash"
      "ente-jwt-secret"
    ];
  };

  # List services that you want to enable:
  # Keep the nvidia device nodes (/dev/nvidia0, nvidiactl, …) present so the
  # jellyfin service can be granted access to them for NVENC.
  hardware.nvidia.nvidiaPersistenced = true;

  services = {
    caddy.virtualHosts = let
      # Reverse proxy vhosts for the containers hosted on servenix.
      # Thinknix terminates TLS and is the only client of this host: it forwards
      # requests over plain HTTP on the LAN, so no certificates are needed here.
      #
      # The upstreams are loopbacks, not container names, as caddy runs on
      # the host and cannot use docker's embedded DNS, so every container
      # publishes its port on 127.0.0.1 only.
      vhost = name: port: aliases: {
        "${name}.local.chriphost.de" = {
          # NOTE: The explicit http:// scheme is required. Without it Caddy
          #       treats the address as an HTTPS site and serves TLS on
          #       httpsPort instead of plain HTTP on httpPort.
          hostName = "http://${name}.local.chriphost.de";

          # The VPS forwards the public names to thinknix, which proxies them
          # here with the Host header preserved. Without these aliases Caddy
          # answers an empty 200 for them.
          serverAliases = map (alias: "http://${alias}") aliases;

          extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
        };
      };

      # Vhost without public aliases
      localVhost = name: port: vhost name port [];
    in
      lib.mergeAttrsList [
        (vhost "nextcloud" 8080 ["nextcloud.vps.chriphost.de"])
        (vhost "immich" 2283 ["immich.vps.chriphost.de"])
        (vhost "paperless" 8000 ["paperless.vps.chriphost.de"])
        (vhost "jellyfin" 8096 ["jellyfin.vps.chriphost.de" "jellyfin.vps.chriphost.gay"])
        (vhost "gitea" 3000 ["gitea.vps.chriphost.de"])
        (vhost "ntfy" 8042 ["ntfy.vps.chriphost.de"])

        # *arr stack
        (localVhost "sonarr" 8989)
        (localVhost "radarr" 7878)
        (localVhost "prowlarr" 9696)
        (localVhost "bazarr" 6767)
        (localVhost "sabnzbd-movies" 8084)
        (localVhost "sabnzbd-shows" 8085)

        # Media / documents
        (localVhost "fileflows" 5000)
        (localVhost "kiwix" 8081)
        (localVhost "pdf" 8082)
        (localVhost "mailpit" 8025)
        (localVhost "tmm" 4000)
        (localVhost "budget" 5006)

        # Formula / pocketbase
        (vhost "f10" 55555 ["f10.vps.chriphost.de"])
        (vhost "f11" 5173 ["f11.vps.chriphost.de" "f11.vps.chriphost.gay" "f11.chriphost.de"])
        (vhost "f11pb" 8090 ["f11pb.vps.chriphost.de"])
        (vhost "f12" 5174 ["f12.vps.chriphost.de" "f12.vps.chriphost.gay"])
        (vhost "f12pb" 8091 ["f12pb.vps.chriphost.de"])

        # ente
        (localVhost "duck" 3010)
        (localVhost "duck-albums" 3011)
        (localVhost "duck-api" 3012)
        (localVhost "duck-s3" 3013)

        # Catch-all: an unknown Host header gets a clear 404 instead of the
        # empty 200 Caddy returns otherwise, which looked like a blank page.
        {
          ":9080" = {
            extraConfig = ''respond "no vhost for this host" 404'';
          };
        }
      ];

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
