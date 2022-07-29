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
  outputs = inputs@{ nixpkgs, home-manager, devshell, ... }:

    # With let you can define local variables
    let
      # We bring these functions into the scope for the outputs.
      inherit (builtins) attrValues; # TODO: What does this do
      # inherit (nixpkgs.lib) nixosSystem;
      # inherit (home-manager.lib) homeManagerConfiguration;

      # Disabled since HomeManager module inherits these in extraSpecialArgs
      # Add overlays from other flakes so we can use them from pkgs.
      overlays = {
        nur = inputs.nur.overlay;
        emacs = inputs.emacs-overlay.overlay;
      };

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ devshell.overlay ];
      };

      # The rec expression turns a basic set into a set where self-referencing is possible.
      # It is a shorthand for recursive and allows to use the values defined in this set from its own scope.
    in rec {

      devShells."x86_64-linux".default = pkgs.devshell.mkShell {
        name = "NixFlake Shell";

        packages = with pkgs; [
          jetbrains.clion
        ];

        commands = [
          {
            name = "ide";
            help = "Launch clion in this folder";
            command = "clion ./ &>/dev/null &";
          }
        ];
      };

      # System configurations + HomeManager module
      # Accessible via 'nixos-rebuild'
      nixosConfigurations = {
        # We give our configuration a name (the hostname) to choose a configuration when rebuilding.
        # This makes it easy to add different configurations later (e.g. for a laptop).
        # Usage: sudo nixos-rebuild switch --flake .#nixinator
        nixinator = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # >> Main NixOS configuration file <<
          modules = [
            inputs.musnix.nixosModules.musnix

            # TODO: Modularize
            ./nixos/configuration.nix
            ./nixos/configuration-nixinator.nix

            # TODO: Investigate this { ... } module syntax
            # Overlays
            {
              # Since HomeManager uses global pkgs we can set the overlays here
              nixpkgs.overlays = attrValues overlays;
            }

            # HomeManager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs =
                true; # Use systems pkgs, disables nixpkgs.* options in home.nix
              home-manager.useUserPackages =
                true; # Enable installing packages through users.christoph.packages
              home-manager.users.christoph = import ./home/home.nix;

              # Make our overlays available in home.nix
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];

          # Make our inputs available to the configuration.nix (for importing modules)
          specialArgs = { inherit inputs; };
        };

        nixtop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # >> Main NixOS configuration file <<
          modules = [
            # TODO: Modularize
            ./nixos/configuration.nix
            ./nixos/configuration-nixtop.nix

            # TODO: Investigate this { ... } module syntax
            # Overlays
            {
              # Since HomeManager uses global pkgs we can set the overlays here
              nixpkgs.overlays = attrValues overlays;
            }

            # HomeManager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs =
                true; # Use systems pkgs, disables nixpkgs.* options in home.nix
              home-manager.useUserPackages =
                true; # Enable installing packages through users.christoph.packages
              home-manager.users.christoph = import ./home/home.nix;

              # Make our overlays available in home.nix
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];

          # Make our inputs available to the configuration.nix (for importing modules)
          specialArgs = { inherit inputs; };
        };
      };
    };
}
