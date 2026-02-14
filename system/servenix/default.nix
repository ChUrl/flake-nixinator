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
    ../services/statespaces.nix

    # General services
    ../services/authelia.nix
    ../services/bazarr.nix
    ../services/box.nix
    ../services/fileflows.nix
    ../services/gitea.nix
    ../services/immich.nix
    ../services/jellyfin.nix
    ../services/kiwix.nix
    ../services/kopia.nix
    ../services/nextcloud.nix
    ../services/nginx-proxy-manager.nix
    ../services/paperless.nix
    # ../services/plex.nix # Their monetization strategy is absolutely atrocious
    ../services/portainer-agent.nix
    ../services/pulse-agent-servenix.nix
    ../services/prowlarr.nix
    ../services/radarr.nix
    ../services/sabnzbd-movies.nix
    ../services/sabnzbd-shows.nix
    ../services/sonarr.nix
    ../services/teamspeak.nix
    ../services/tinymediamanager.nix
    ../services/whats-up-docker.nix
  ];

  systemmodules = {
    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;

        # We have 4 IPv6 prefixes, one is used for LAN, one is used for ThinkNix behind-nginx docker network (for DNS).
        # Questionable if we should enable it here aswell...
        ipv6.enable = false;
        # ipv6.gateway = "fd00::5";
        # ipv6.subnet = "2001:7d8:8023:a00a::/64";
      }
    ];

    network = {
      useNetworkManager = false;

      networks = {
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
        #   interface = "ens18";
        #   ips = ["192.168.86.25/24" "fd00::19/64"];
        #   routers = ["192.168.86.5" "fd00::5"];
        #   nameservers = ["8.8.8.8" "2001:4860:4860::8888"]; # NOTE: Use reliable DNS for servers instead of 192.168.86.26
        #   routable = true;
        # };

        # TODO: mylib.networking.mkStaticSystemdNetwork needs improvement to accomodate for this
        "10-ether-1G" = rec {
          enable = true;

          # See man systemd.link, man systemd.netdev, man systemd.network
          matchConfig = {
            # This corresponds to the [MATCH] section
            Name = "ens18"; # Match ethernet interface
          };

          # Static IP + DNS + Gateway
          address = ["192.168.86.25/24"];
          gateway = ["192.168.86.5"]; # Don't add IPv6 gateway, rely on router advertisement instead
          dns = ["8.8.8.8" "8.8.4.4" "2001:4860:4860:8888" "2001:4860:4860:8844"];
          routes = builtins.map (r: {Gateway = r;}) gateway;

          # See man systemd.network
          networkConfig = {
            # This corresponds to the [NETWORK] section
            DHCP = "no";

            IPv6AcceptRA = "yes"; # Accept Router Advertisements
            # MulticastDNS = "no";
            # LLMNR = "no";
            # LinkLocalAddressing = "ipv6";
          };

          addresses = [
            {
              # Don't add this to address, we don't want to create any routes with this
              Address = "fd00::19/64";
            }
          ];

          linkConfig = {
            # This corresponds to the [LINK] section
            RequiredForOnline = "routable";
          };
        };
      };

      # NOTE: Streams: Ports have to be opened in the VPS firewall + VPS UFW and bound in the VPS Nginx compose file.

      allowedTCPPorts = [
        53 # DNS (Adguard Home)
        67 # DHCP
        80 # HTTP (Nginx Proxy Manager)
        443 # HTTPS (Nginx Proxy Manager)

        3000 # Gitea (runner needs to reach local gitea instance)

        30033 # Teamspeak
        10080 # Teamspeak
      ];

      allowedUDPPorts = [
        53 # DNS (Adguard Home)
        67 # DHCP
        80 # HTTP (Nginx Proxy Manager)
        443 # HTTPS (Nginx Proxy Manager)

        3000 # Gitea (runner needs to reach local gitea instance)

        5520 # HyTale

        30033 # Teamspeak
        9987 # Teamspeak
      ];
    };

    sops-nix.secrets.${username} = [
      "heidi-discord-token"
      "kopia-server-username"
      "kopia-server-password"
      "kopia-user-password"
      "paperless-nextcloud-sync-password"
    ];
  };

  # List services that you want to enable:
  services = {
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
