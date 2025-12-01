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

    ../modules

    # General services
    ../services/adguard.nix
    ../services/nginx-proxy-manager.nix
    ../services/portainer.nix
    ../services/pulse.nix
    ../services/whats-up-docker.nix
  ];

  modules = {
    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;
        ipv6.enable = false;
      }
    ];

    network = {
      useNetworkManager = false;

      networks = {
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "ens18";
          ips = ["192.168.86.26/24"];
          routers = ["192.168.86.5"];
          nameservers = ["8.8.8.8"]; # NOTE: Use reliable DNS for servers instead of 127.0.0.1
          routable = true;
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
