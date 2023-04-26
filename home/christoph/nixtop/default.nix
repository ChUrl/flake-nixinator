{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the laptop
rec {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
    };

    home.packages = with pkgs; [
    ];
  };
}
