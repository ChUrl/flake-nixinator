{ config, nixosConfig, lib, pkgs, mylib, ... }:

{
  imports = [
    ./audio.nix
    ./emacs.nix
    ./firefox.nix
    ./flatpak.nix
    ./gaming.nix
    ./kitty.nix
    ./misc.nix
    ./neovim.nix
    ./nextcloud.nix
  ];
}
