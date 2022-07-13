{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-laptop.nix
  ];

  networking.hostName = "nixtop"; # Define your hostname.

  services.xserver = {
    # Configure keymap in X11
    layout = "de";
    xkbVariant = "nodeadkeys";

    # Proprietary graphics drivers
    videoDrivers = [ "intel" ];
  };
}
