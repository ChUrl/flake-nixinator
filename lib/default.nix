{ inputs, pkgs, lib, ... }:

rec {
  nixos = import ./nixos.nix { inherit inputs pkgs lib; };
}