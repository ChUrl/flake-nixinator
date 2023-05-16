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
    eth-interface = "enp*";
    wireless-interface = "wlp*";
  in {
    enable = true;

    # LAN
    networks."50-ether" = {
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
      };

      linkConfig = {
        # This corresponds to the [LINK] section
        # RequiredForOnline = "routable";
      };
    };
  };
}
