{ config, lib, pkgs, home, ... }:

pkgs.makeDesktopItem {
  name = "carla-guitar";
  exec =
    "PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${home.homeDirectory}/Documents/Carla/GuitarDefault.carxp";
  genericName = "Guitar Amp Simulation";
  categories = [ "Music" "Audio" ];
  desktopName = "Carla Guitar Amp";
}
