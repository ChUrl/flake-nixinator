{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Import my own library functions.
  # Those are defined as functions returning sets of library functions,
  # so those functions have to be called when importing.
  nixos = import ./nixos.nix {inherit inputs pkgs lib;};
  modules = import ./modules.nix {inherit inputs pkgs lib;};
  networking = import ./networking.nix {inherit inputs pkgs lib;};
  rofi = import ./rofi.nix {inherit inputs pkgs lib;};
  generators = import ./generators.nix {inherit inputs pkgs lib;};
  color = import ./color.nix {inherit inputs pkgs lib;};
}
