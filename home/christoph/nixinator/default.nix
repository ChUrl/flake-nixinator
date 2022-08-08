{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

rec {
  imports = [
    ../../../modules
  ];

  modules.audio = {
    enable = true;

    carla.enable = true;
    bitwig.enable = false;
    bottles.enable = true;
    yabridge.enable = true;
    yabridge.autoSync = true;

    extraPackages = with pkgs; [ audacity vcv-rack ];
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
