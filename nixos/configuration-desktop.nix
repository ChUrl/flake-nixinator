{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration-desktop.nix
  ];

  networking.hostName = "nixinator"; # Define your hostname.

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # Proprietary graphics drivers
    videoDrivers = [ "nvidia" ];
  };
}
