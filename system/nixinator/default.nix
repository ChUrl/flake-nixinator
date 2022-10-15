{ inputs, config, lib, mylib, pkgs, ... }:

rec {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    inputs.musnix.nixosModules.musnix
  ];

  # Low latency audio
  musnix = {
    enable = true;
    # musnix.soundcardPciId = ;
  };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # Proprietary graphics drivers, yay :(
    # videoDrivers = [ "nvidia" ]; # NVIDIA
    videoDrivers = [ "amdgpu" ];
  };
}
