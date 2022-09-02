{ inputs, nixpkgs, ... }:

let
  # Taken from https://github.com/Misterio77/nix-config/blob/main/overlay/default.nix
  # By specifying this we can just add our derivation to derivations/default.nix and it will land here
  additions = final: prev: import ../derivations { inherit inputs; pkgs = final; };

  modifications = final: prev: {
    # dconf-editor-wrapped = import ./dconf-editor.nix { inherit final prev; }; # Only kept as an example, has nothing to do with current dconf-editor-wrapped derivation
    # Use dconf-editor.nix: { final, prev }: final.<package>.overrideAttrs (oldAttrs: { ... }) or sth similar
  };

in
  # TODO: I have absolutely no clue what happens here lol
  # Basically we need some sort of list of all overlays that can be imported from the flake
  # in the overlays = [ ... ] section of the pkgs = import nixpkgs { ... } configuration
  # Somehow this library function turns additions/modifications into that
  nixpkgs.lib.composeManyExtensions [ additions modifications ]