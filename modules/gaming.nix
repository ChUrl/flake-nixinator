{ config, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.gaming;
  flatpak = config.modules.flatpak;
in {
  imports = [ ];

  options.modules.gaming = {};

  config = mkIf cfg.enable {};
}