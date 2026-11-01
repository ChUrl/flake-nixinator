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
    ../services/heidi.nix
    ../services/formula10.nix
    ../services/formula11.nix
    ../services/formula12.nix
    # ../services/statespaces.nix

    # General services
    ../services/actual-budget.nix
    ../services/arcane-agent.nix
    # ../services/authelia.nix # Thinknix hosts authelia module
    ../services/bazarr.nix
    ../services/bento_pdf.nix
    ../services/ente.nix
    ../services/fileflows.nix
    ../services/gitea.nix
    ../services/immich.nix
    ../services/jellyfin.nix
    ../services/kiwix.nix
    ../services/kopia.nix
    ../services/mailpit.nix
    ../services/nextcloud.nix
    ../services/ntfy.nix
    ../services/nginx-proxy-manager.nix
    ../services/paperless.nix
    # ../services/plex.nix # Their monetization strategy is absolutely atrocious
    # ../services/portainer-agent.nix
    # ../services/pulse-agent-servenix.nix
    ../services/prowlarr.nix
    ../services/radarr.nix
    ../services/sabnzbd-movies.nix
    ../services/sabnzbd-shows.nix
    ../services/sonarr.nix
    # ../services/teamspeak.nix
    ../services/tinymediamanager.nix
    # ../services/whats-up-docker.nix
  ];

  networking.tempAddresses = "disabled";

  systemmodules = {
    caddy = {
      enable = true;

      # Dry run on alternate ports until the Nginx Proxy Manager is retired.
      httpPort = 9080;
      httpsPort = 9443;
      autoHttps = false;
      openFirewall = false;
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

      # NOTE: Streams: Ports have to be opened in the VPS firewall + VPS UFW and bound in the VPS Nginx compose file.

      allowedTCPPorts = [
        53 # DNS (Adguard Home)
        80 # HTTP (Nginx Proxy Manager)
        443 # HTTPS (Nginx Proxy Manager)

        222 # Gitea SSH
      ];

      allowedUDPPorts = [
        53 # DNS (Adguard Home)
      ];
    };

    # TODO: Fold those into the respective service files
    sops-nix.secrets.${username} = [
      "heidi-discord-token"
      "kopia-server-username"
      "kopia-server-password"
      "kopia-user-password"
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
  services = {
    caddy.virtualHosts = let
      # Reverse proxy vhosts for the containers hosted on servenix.
      # Thinknix terminates TLS and is the only client of this host: it forwards
      # requests over plain HTTP on the LAN, so no certificates are needed here.
      #
      # The upstreams are loopbacks, not container names, as caddy runs on
      # the host and cannot use docker's embedded DNS, so every container
      # publishes its port on 127.0.0.1 only.
      vhost = name: port: {
        "${name}.local.chriphost.de" = {
          # NOTE: The explicit http:// scheme is required. Without it Caddy
          #       treats the address as an HTTPS site and serves TLS on
          #       httpsPort instead of plain HTTP on httpPort.
          hostName = "http://${name}.local.chriphost.de";
          extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
        };
      };
    in
      lib.mergeAttrsList [
        (vhost "nextcloud" 8080)
        (vhost "immich" 2283)
        (vhost "paperless" 8000)
        (vhost "jellyfin" 8096)
        (vhost "gitea" 3000)
        (vhost "ntfy" 8042)

        # *arr stack
        (vhost "sonarr" 8989)
        (vhost "radarr" 7878)
        (vhost "prowlarr" 9696)
        (vhost "bazarr" 6767)
        (vhost "sabnzbd-movies" 8084)
        (vhost "sabnzbd-shows" 8085)

        # Media / documents
        (vhost "fileflows" 5000)
        (vhost "kiwix" 8081)
        (vhost "pdf" 8082)
        (vhost "kopia" 51515)
        (vhost "mailpit" 8025)
        (vhost "tmm" 4000)
        (vhost "budget" 5006)

        # Formula / pocketbase
        (vhost "f10" 55555)
        (vhost "f11" 5173)
        (vhost "f11pb" 8090)
        (vhost "f12" 5174)
        (vhost "f12pb" 8091)

        # ente
        (vhost "duck" 3010)
        (vhost "duck-albums" 3011)
        (vhost "duck-api" 3012)
        (vhost "duck-s3" 3013)
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
