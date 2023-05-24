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
    ../modules
  ];

  services.xserver = {
    # Configure keymap in X11
    layout = "de";
    xkbVariant = "nodeadkeys";

    # Proprietary graphics drivers
    videoDrivers = ["intel"];
  };
}
