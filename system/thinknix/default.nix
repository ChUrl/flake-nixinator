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

    # General services
    ../services/adguard.nix
    ../services/nginx-proxy-manager.nix
    ../services/portainer.nix
    ../services/pulse.nix
    ../services/pulse-agent-thinknix.nix
    ../services/whats-up-docker.nix
  ];

  systemmodules = {
    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;

        ipv6.enable = true;
        # ipv6.gateway = "fd00::5";

        # We have to put an actual prefix from the ISP here.
        # OPNSense: Interfaces > Overview > WAN > Details > Dynamic IPv6 Prefix Received.
        # With /64, we don't have a prefix to spare for docker.
        # Glasfaser Ruhr gives us /62, meaning 4 prefixes.
        # The first one is used for the main LAN, so use the second one for docker.
        # This also requires a route in OPNSense that specifies ThinkNix as the gateway to this subnet.
        ipv6.subnet = "2001:7d8:8023:a009::/64";
      }
    ];

    network = {
      useNetworkManager = false;

      networks = {
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
        #   interface = "ens18";
        #   ips = ["192.168.86.26/24" "fd00::1a/64"];
        #   routers = ["192.168.86.5" "fd00::5"];
        #   nameservers = ["8.8.8.8" "2001:4860:4860::8888"]; # NOTE: Use reliable DNS for servers instead of 127.0.0.1
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
          address = ["192.168.86.26/24"];
          gateway = ["192.168.86.5"]; # Don't add "fd00::5", rely on router advertisement instead
          dns = ["8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
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
              Address = "fd00::1a/64"; # IPv6 Unique-Local Address (ULA)
            }
          ];

          linkConfig = {
            # This corresponds to the [LINK] section
            RequiredForOnline = "routable";
          };
        };
      };

      allowedTCPPorts = [
        53 # DNS
        80 # HTTP
      ];
      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
      ];
    };

    sops-nix.secrets.${username} = [
      # "wireguard-vps-private-key"
    ];
  };

  # networking.wireguard.interfaces."vps-wg-client" = {
  #   ips = ["10.10.10.2/32"];
  #   privateKeyFile = "${config.sops.secrets.wireguard-vps-private-key.path}";

  #   # Create the depending network namespace
  #   # preSetup = ''
  #   #   ${pkgs.iproute2}/bin/ip netns add ${name}
  #   # '';

  #   # postSetup = ''
  #   #   ${pkgs.iptables}/bin/iptables -A FORWARD -i vps-wg-client -j ACCEPT
  #   #   ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
  #   # '';
  #   # postShutdown = ''
  #   #   ${pkgs.iptables}/bin/iptables -D FORWARD -i vps-wg-client -j ACCEPT
  #   #   ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o ens18 -j MASQUERADE
  #   # '';
  #   postSetup = ''
  #     ${pkgs.iptables} -A FORWARD -i wg0-client -j ACCEPT
  #     ${pkgs.iptables} -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  #   '';
  #   postShutdown = ''
  #     ${pkgs.iptables} -D FORWARD -i wg0-client -j ACCEPT
  #     ${pkgs.iptables} -t nat -D POSTROUTING -o eth0 -j MASQUERADE
  #   '';

  #   peers = [
  #     {
  #       name = "chriphost-vps";
  #       publicKey = "w/U8p9fizw0jk8PFaMZXV1N49Ws+q6mUHzNFYtoDTS8=";
  #       endpoint = "212.227.233.241:51820";
  #       allowedIPs = [
  #         "10.10.10.0/24"
  #       ];

  #       # Keep this connection alive so the server can always reach us
  #       persistentKeepalive = 25;
  #     }
  #   ];
  # };

  services = {
    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "altgr-intl";
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
