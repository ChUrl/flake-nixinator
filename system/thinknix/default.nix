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
    ../services/whats-up-docker.nix
    ../services/wireguard.nix
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
          nameservers = ["127.0.0.1" "8.8.8.8"];
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
  };

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
