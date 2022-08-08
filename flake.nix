# The curly braces denote a set of keys and values.
{
  description = "ChUrl's very bad and basic Nix config using Flakes";

  # This config is a Flake.
  # It needs inputs that are passed as arguments to the output.
  # These are the dependencies of the Flake.
  # The git revisions get locked in flake.lock to make the outputs deterministic.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other Flakes
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nur.url = "github:nix-community/NUR";
    musnix.url = "github:musnix/musnix";
    devshell.url = "github:numtide/devshell";
    # nixvim.url = "github:pta2002/nixvim";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the inputs@ pattern.
  # It gives a name to the ... ellipses.
  outputs = inputs @ { nixpkgs, home-manager, ... }:

    # With let you can define local variables
    let
      system = "x86_64-linux";

      # Set overlays + unfree globally
      pkgs = import nixpkgs {
        inherit system;

        config.allowUnfree = true;
        overlays = [
          inputs.devshell.overlay
          inputs.nur.overlay
          inputs.emacs-overlay.overlay
        ];
      };

      mylib = import ./lib { inherit inputs pkgs; lib = nixpkgs.lib; };

    # The rec expression turns a basic set into a set where self-referencing is possible.
    # It is a shorthand for recursive and allows to use the values defined in this set from its own scope.
    in rec {

      # Local shell for NixFlake directory
      devShells."${system}".default = import ./shell.nix { inherit pkgs; };

      # System configurations + HomeManager module
      # Accessible via 'nixos-rebuild'
      nixosConfigurations = {

        # We give our configuration a name (the hostname) to choose a configuration when rebuilding.
        # This makes it easy to add different configurations later (e.g. for a laptop).
        # Usage: sudo nixos-rebuild switch --flake .#nixinator
        nixinator = mylib.nixos.mkNixosConfig {
          inherit system mylib;

          hostname = "nixinator";
          username = "christoph";
          extraModules = [ inputs.musnix.nixosModules.musnix ];
        };

        nixtop = mylib.nixos.mkNixosConfig {
          inherit system mylib;

          hostname = "nixtop";
          username = "christoph";
        };
      };
    };
}
