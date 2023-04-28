{
  inputs,
  config,
  nixosConfig,
  lib,
  pkgs,
  mylib,
  ...
}: {
  imports = [
    ./audio
    ./emacs
    ./email
    ./firefox
    ./fish
    ./flatpak
    ./gaming
    ./gnome
    ./hyprland
    ./kitty
    ./misc
    ./neovim
    ./nextcloud
    ./nzbget
    ./plasma
    ./ranger
  ];
}
