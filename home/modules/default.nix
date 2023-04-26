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
    ./audio/default.nix
    ./emacs/default.nix
    ./email/default.nix
    ./firefox/default.nix
    ./fish/default.nix
    ./flatpak/default.nix
    ./gaming/default.nix
    ./gnome/default.nix
    ./hyprland/default.nix
    ./kitty/default.nix
    ./misc/default.nix
    ./neovim/default.nix
    ./nextcloud/default.nix
    ./plasma/default.nix
    ./ranger/default.nix
  ];
}
