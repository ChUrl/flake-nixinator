{ inputs, pkgs, lib, ... }:

{
  nixos = import ./nixos.nix { inherit inputs pkgs lib; };
  modules = import ./modules.nix { inherit inputs pkgs lib; };
}