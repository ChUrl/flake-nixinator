{
  mylib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../modules
  ];

  modules = {
    systemd-networkd = {
      networks = {
        # This should override the default network 50-ether
        "10-ether-2_5G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp8s0";
          ip = ["192.168.86.50/24"];
          router = ["192.168.86.5"];
          nameserver = ["192.168.86.26"];
          routable = true;
        };
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {...};
      };

      allowedTCPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
      ];

      allowedUDPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
      ];

      wireguard-tunnels = {
        wg0-de-115 =
          mylib.networking.mkWireguardService
          "wg0-de-115"
          "proton-de-115.key"
          "9+CorlxrTsQR7qjIOVKsEkk8Z7UUS5WT3R1ccF7a0ic="
          "194.126.177.14";

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

  services.xserver = {
    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "altgr-intl";

    videoDrivers = ["nvidia"]; # NVIDIA
  };

  # This has been relocated here from the default config,
  # because it forces en-US keyboard layout.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        fcitx5-gtk
        libsForQt5.fcitx5-qt # QT5
        kdePackages.fcitx5-qt # QT6
        fcitx5-chinese-addons
        fcitx5-configtool # TODO: Remove this and set config through HomeManager
      ];
    };
  };
}
