{ config, nixosConfig, lib, pkgs, mylib, ... }:

{
  imports = [
    ./audio.nix
    ./emacs.nix
    ./firefox.nix
    ./fish.nix
    ./flatpak.nix
    ./gaming.nix
    ./gnome.nix
    ./kitty.nix
    ./misc.nix
    ./neovim.nix
    ./nextcloud.nix
    ./ranger.nix
  ];
}
