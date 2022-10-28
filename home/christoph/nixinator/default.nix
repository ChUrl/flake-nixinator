{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# Here goes the stuff that will only be enabled on the desktop

rec {
  imports = [
    ../../modules
  ];

  modules = {
    audio = {
      enable = true;

      carla.enable = false;
      bitwig.enable = true; # TODO: Check what happens when upgrade plan ends, do I need to pin the version then?
      tenacity.enable = true;

      faust.enable = true;
      bottles.enable = true;
      yabridge.enable = true;
      yabridge.autoSync = true;

      noisesuppression = {
         noisetorch.enable = true;
         noisetorch.autostart = true;
      };

      cardinal.enable = true;
      distrho.enable = true;
    };

    gaming = {
      enable = true;

      prism.enable = true;
      bottles.enable = true;
      discordChromium.enable = true;
      discordElectron.enable = true;

      steam = {
        enable = true;
        protonGE = true;
        gamescope = true;
        adwaita = true;
      };
    };
  };
}
