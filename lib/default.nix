{ inputs, pkgs, lib, ... }:

{
  nixos = import ./nixos.nix { inherit inputs pkgs lib; };
}