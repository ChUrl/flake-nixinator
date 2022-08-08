{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

rec {
  imports = [
    ../../../modules
  ];

  modules.audio = {
    enable = true;

    # TODO: Remove the config link when disabled
    carla.enable = true;
    bitwig.enable = false;
    yabridge.enable = true;
    yabridge.autoSync = true;

    extraPackages = with pkgs; [ audacity vcv-rack ];
  };

  modules.gaming = {};
}
