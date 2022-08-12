{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# Here goes the stuff that will only be enabled on the desktop

rec {
  imports = [
    ../../modules
  ];

  modules = {
    audio = {
      enable = true;

      carla.enable = true;
      bitwig.enable = true;
      tenacity.enable = true;

      faust.enable = true;
      bottles.enable = true;
      yabridge.enable = true;
      yabridge.autoSync = true;

      noisesuppression = {
         noisetorch.enable = true;
         noisetorch.autostart = true;
      };

      vcvrack.enable = true;
      # vital.enable = true;
      distrho.enable = true;
    };

    gaming = {
      enable = true;

      polymc.enable = true;
      bottles.enable = true;
      discordChromium.enable = true;

      steam = {
        enable = true;
        protonGE = true;
        gamescope = true;
        adwaita = true;
      };
    };
  };
}
