{ config, lib, pkgs, mylib, ... }:

{
  imports = [
    ./audio.nix
    ./emacs.nix
    ./flatpak.nix
    ./gaming.nix
  ];
}
