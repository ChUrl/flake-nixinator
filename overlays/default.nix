{ inputs, nixpkgs, ... }:

let
  # Taken from https://github.com/Misterio77/nix-config/blob/main/overlay/default.nix
  # By specifying this we can just add our derivation to derivations/default.nix and it will land here
  additions = final: prev: import ../derivations { inherit inputs; pkgs = final; };

in
  # TODO: I have absolutely no clue what happens here lol
  # Basically we need some sort of list of all overlays that can be imported from the flake
  # in the overlays = [ ... ] section of the pkgs = import nixpkgs { ... } configuration
  # Somehow this library function turns additions into that
  nixpkgs.lib.composeManyExtensions [ additions ]