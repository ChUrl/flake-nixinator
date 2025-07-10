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
          nameserver = "192.168.86.26"; # TODO: Add fallback 8.8.8.8
          autoconnect = true;
        };
        "10-ether-1G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 1G";
          interface = "enp5s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26"; # TODO: Add fallback 8.8.8.8
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

      wireguard-tunnels = {
        wg0-de-115 =
          mylib.networking.mkWireguardService
          "wg0-de-115"
          "proton-de-115.key"
          "9+CorlxrTsQR7qjIOVKsEkk8Z7UUS5WT3R1ccF7a0ic="
          "194.126.177.14";

        wg0-de-205 =
          mylib.networking.mkWireguardService
          "wg0-de-205"
          "proton-de-205.key"
          "MOLPnnM2MSq7s7KqAgpm+AWpmzFAtuE46qBFHeLg5Tk="
          "217.138.216.130";

        wg0-lu-16 =
          mylib.networking.mkWireguardService
          "wg0-lu-16"
          "proton-lu-16.key"
          "asu9KtQoZ3iKwELsDTgjPEiFNcD1XtgGgy3O4CZFg2w="
          "92.223.89.133";

        wg0-kh-8 =
          mylib.networking.mkWireguardService
          "wg0-kh-8"
          "proton-kh-8.key"
          "D4M0O60wCBf1nYWOmXRfK7IpgG7VBBwQLeWVFLIqFG4="
          "188.215.235.82";

        wg0-ch-70 =
          mylib.networking.mkWireguardService
          "wg0-ch-70"
          "proton-ch-70.key"
          "17I34jHOMcmI7LKBqxosTfLgwGjO5OKApLcRSPlyymM="
          "185.159.157.13";
      };
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
