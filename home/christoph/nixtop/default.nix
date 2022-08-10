{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# Here goes the stuff that will only be enabled on the laptop

rec {
  imports = [
    ../../../modules
  ];

  modules = {
    # TODO: Validate that this doesn't install too much
    gaming = {
      enable = true;
      discordChromium.enable = true;
    };

    audio = {
      enable = true;
      noisesuppression = {
        noisetorch.enable = true;
        noisetorch.autostart = true;
      };
    };
  };
}