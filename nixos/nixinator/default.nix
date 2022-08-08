{ config, lib, pkgs, musnix, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixinator"; # Define your hostname.

  musnix = {
    enable = true;
    # musnix.soundcardPciId = ;
  };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # Proprietary graphics drivers
    videoDrivers = [ "nvidia" ];
  };
}
