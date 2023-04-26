{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  ...
}: rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  services.xserver = {
    # Configure keymap in X11
    layout = "de";
    xkbVariant = "nodeadkeys";

    # Proprietary graphics drivers
    videoDrivers = ["intel"];
  };

  
  systemd.network = let
    eth-interface = "enp0s20u2";
    wireless-interface = "wlp3s0";
  in {
    enable = true;

    # LAN
    networks."50-tether" = {
      # name = "enp0s31f6"; # Network interface name?
      enable = true;

      # See man systemd.link, man systemd.netdev, man systemd.network
      matchConfig = {
        # This corresponds to the [MATCH] section
        Name = eth-interface; # Match ethernet interface
      };

      # See man systemd.network
      networkConfig = {
        # This corresponds to the [NETWORK] section
        DHCP = "yes";

        # TODO: What does this all do?
        # IPv6AcceptRA = true;
        # MulticastDNS = "yes"; # Needed?
        # LLMNR = "no"; # Needed?
        # LinkLocalAddressing = "no"; # Needed?
      };

      linkConfig = {
        # This corresponds to the [LINK] section
        # RequiredForOnline = "routable";
      };
    };
  };
}
