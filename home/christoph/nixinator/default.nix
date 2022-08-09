{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# Here goes the stuff that will only be enabled on the desktop

rec {
  imports = [
    ../../../modules
  ];

  modules.audio = {
    enable = true;

    carla.enable = true;
    bitwig.enable = true;
    tenacity.enable = true;

    faust.enable = true;
    bottles.enable = true;
    yabridge.enable = true;
    yabridge.autoSync = true;

    vcvrack.enable = true;
    vital.enable = true;
  };

  modules.gaming = {
    enable = true;

    discordChromium.enable = true;
    polymc.enable = true;
    bottles.enable = true;

    noisetorch = {
      enable = true;
      autostart = true;
    };

    steam = {
      enable = true;
      protonGE = true;
      gamescope = true;
    };
  };
}
