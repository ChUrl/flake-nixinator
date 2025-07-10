{
  mylib,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../modules
  ];

  modules = {
    network = {
      useNetworkManager = true;

      # Systemd-networkd configs
      networks = {
        # This should override the default network 50-ether
        "10-ether-2_5G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp8s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = true;
        };
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp5s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = false;
        };
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {...};
      };

      # NetworkManager profiles
      profiles = {
        "10-ether-2_5G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 2.5G";
          interface = "enp8s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26"; # TODO: Add fallback 8.8.8.8 (create imperatively then use nm2nix)
          autoconnect = true;
        };
        "10-ether-1G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 1G";
          interface = "enp5s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26"; # TODO: Add fallback 8.8.8.8 (create imperatively then use nm2nix)
          autoconnect = false;
        };
      };

      allowedTCPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];

      allowedUDPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
  };

  programs = {
    ausweisapp = {
      enable = true;
      openFirewall = true; # Directly set port in firewall
    };
  };

  services = {
    xserver = {
      # Configure keymap in X11
      xkb.layout = "us";
      xkb.variant = "altgr-intl";

      videoDrivers = ["nvidia"]; # NVIDIA
    };
  };

  # The current system was installed on 22.05, do not change.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
