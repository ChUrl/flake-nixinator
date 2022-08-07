{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.gaming;
  flatpak = config.module.flatpak;
in {
  imports = [ ];

  options.modules.gaming = {};

  config = mkIf cfg.enable {};
}