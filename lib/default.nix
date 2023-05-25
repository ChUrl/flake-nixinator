{
  inputs,
  pkgs,
  lib,
  ...
}: {
  nixos = import ./nixos.nix {inherit inputs pkgs lib;};
  modules = import ./modules.nix {inherit inputs pkgs lib;};
  networking = import ./networking.nix {inherit inputs pkgs lib;};
  virtualisation = import ./virtualisation.nix {inherit inputs pkgs lib;};
  rofi = import ./rofi.nix {inherit inputs pkgs lib;};
}
