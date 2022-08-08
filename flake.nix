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
    # nixvim.url = "github:pta2002/nixvim";
    musnix.url = "github:musnix/musnix";
    devshell.url = "github:numtide/devshell";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the inputs@ pattern.
  # It gives a name to the ... ellipses.
  outputs = inputs @ { nixpkgs, home-manager, ... }:

    # With let you can define local variables
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.devshell.overlay
          inputs.nur.overlay
          inputs.emacs-overlay.overlay
        ];
      };

      # Add my additions to the nixpkgs lib
#      mylib = nixpkgs.lib.extend (self: super: { my = import ./lib { inherit pkgs inputs; lib = self; }; });
      mylib = import ./lib { inherit inputs pkgs; lib = nixpkgs.lib; };

    # The rec expression turns a basic set into a set where self-referencing is possible.
    # It is a shorthand for recursive and allows to use the values defined in this set from its own scope.
    in rec {
#      inherit lib;

      # Local shell for NixFlake directory
      devShells."${system}".default = import ./shell.nix { inherit pkgs; };

      # System configurations + HomeManager module
      # Accessible via 'nixos-rebuild'
      # TODO: Add some sort of lib function to deduplicate the configs (they are mostly the same except for the modules)
      nixosConfigurations = {

        # WIP using lib.my
        nixinator = mylib.nixos.mkNixosConfig {
          inherit system;

          hostname = "nixinator";
          extraModules = [ inputs.musnix.nixosModules.musnix ];
          homeConfigs = [ mylib.nixos.mkHomeConfig { username = "christoph"; } ];
        };

        # We give our configuration a name (the hostname) to choose a configuration when rebuilding.
        # This makes it easy to add different configurations later (e.g. for a laptop).
        # Usage: sudo nixos-rebuild switch --flake .#nixinator
#        nixinator = nixpkgs.lib.nixosSystem {
#          inherit system;
#
#          # Make our inputs available to the configuration.nix (for importing modules)
#          specialArgs = { inherit inputs; };
#
#          # >> Main NixOS configuration file <<
#          modules = [
#            { nixpkgs.pkgs = pkgs; }
#
#            # TODO: Access this over inputs in configuration-nixtop.nix
#            inputs.musnix.nixosModules.musnix
#
#            ./nixos/configuration.nix
#            ./nixos/configuration-nixinator.nix
#
#            # HomeManager
#            home-manager.nixosModules.home-manager
#            {
#              home-manager.useGlobalPkgs = true; # Use systems pkgs, disables nixpkgs.* options in home.nix
#              home-manager.useUserPackages = true; # Enable installing packages through users.christoph.packages to /etc/profiles instead of ~/.nix-profile
#              home-manager.users.christoph = import ./home/home-christoph.nix;
#            }
#          ];
#        };

#        nixtop = nixpkgs.lib.nixosSystem {
#          inherit system;
#
#          # Make our inputs available to the configuration.nix (for importing modules)
#          specialArgs = { inherit inputs; };
#
#          # >> Main NixOS configuration file <<
#          modules = [
#            { nixpkgs.pkgs = pkgs; }
#
#            ./nixos/configuration.nix
#            ./nixos/configuration-nixtop.nix
#
#            # HomeManager
#            home-manager.nixosModules.home-manager
#            {
#              home-manager.useGlobalPkgs = true; # Use systems pkgs, disables nixpkgs.* options in home.nix
#              home-manager.useUserPackages = true; # Enable installing packages through users.christoph.packages
#              home-manager.users.christoph = import ./home/home-christoph.nix;
#            }
#          ];
#        };
      };
    };
}
