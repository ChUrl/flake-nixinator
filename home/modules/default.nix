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
    ./audio.nix
    ./emacs.nix
    ./email.nix
    ./firefox.nix
    ./fish.nix
    ./flatpak.nix
    ./gaming.nix
    ./gnome.nix
    ./hyprland.nix
    ./kitty.nix
    ./misc.nix
    ./neovim.nix
    ./nextcloud.nix
    ./plasma.nix
    ./ranger.nix
  ];
}
