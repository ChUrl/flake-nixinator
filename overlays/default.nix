{ nixpkgs, ... }:

let
  # Taken from https://github.com/Misterio77/nix-config/blob/main/overlay/default.nix
  additions = final: prev: import ../derivations { pkgs = final; };

in
  nixpkgs.lib.composeManyExtensions [ additions ]