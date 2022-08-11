{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.ranger;
in {

  options.modules.ranger = {
    enable = mkEnableOpt "Ranger";
  };

  # TODO: Ranger configuration

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ranger
      ueberzug
      ffmpegthumbnailer
      atool
      p7zip
      zip
      unzip
      unrar
      libarchive
      exiftool
      mediainfo
    ];
  };
}
