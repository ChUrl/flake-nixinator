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

    inputs.musnix.nixosModules.musnix
  ];

  modules = {
    containers = {
      enable = true;

      homeassistant.enable = false;
      jellyfin.enable = true;
      fileflows.enable = false;
      sonarr.enable = true;
      radarr.enable = true;
      hydra.enable = true;
      sabnzbd.enable = true;
    };
  };

  # Low latency audio
  musnix = {
    enable = true;
    # musnix.soundcardPciId = ;
  };

  services.xserver = {
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "altgr-intl";

    # videoDrivers = [ "nvidia" ]; # NVIDIA
    videoDrivers = ["amdgpu"];
  };
}
