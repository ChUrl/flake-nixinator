{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# Here goes the stuff that will only be enabled on the laptop

rec {
  imports = [
    ../../../modules
  ];

  # TODO: Validate that this doesn't install too much
  modules.gaming = {
    enable = true;
    discordChromium.enable = true;
  };

  modules.audio = {
    enable = true;
    noisetorch = {
      enable = true;
      autostart = true;
    };
  };
}