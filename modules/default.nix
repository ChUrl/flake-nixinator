{ config, nixosConfig, lib, pkgs, mylib, ... }:

{
  imports = [
    ./audio.nix
    ./emacs.nix
    ./firefox.nix
    ./flatpak.nix
    ./gaming.nix
    ./misc.nix
    ./nextcloud.nix
  ];
}
