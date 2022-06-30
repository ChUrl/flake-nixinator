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
    emacs-overlay.url  = "github:nix-community/emacs-overlay";
    nur.url = "github:nix-community/NUR";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the inputs@ pattern.
  # It gives a name to the ... ellipses.
  outputs = inputs @ { nixpkgs, home-manager, emacs-overlay, nur, ... }:
  # With let you can define local variables
  let
    # We bring these functions into the scope for the outputs.
    inherit (builtins) attrValues; # TODO: What does this do
    inherit (nixpkgs.lib) nixosSystem;
    inherit (home-manager.lib) homeManagerConfiguration;
  in
  # The rec expression turns a basic set into a set where self-referencing is possible.
  # It is a shorthand for recursive and allows to use the values defined in this set from its own scope.
  rec {
    # Add overlays from other flakes so we can use them from pkgs.
    overlays = {
      nur = nur.overlay;
      emacs = emacs-overlay.overlay;
    };

    # System configurations
    # Accessible via 'nixos-rebuild'
    nixosConfigurations = {
      # We give our configuration a name (the hostname) to choose a configuration when rebuilding.
      # This makes it easy to add different configurations later (e.g. for a laptop).
      # Usage: sudo nixos-rebuild switch --flake .#nixinator
      nixinator = nixosSystem {
        system = "x86_64-linux";

        # >> Main NixOS configuration file <<
        modules = [
	  # TODO: Modularize
	  ./nixos/configuration.nix

	  # Add the overlays
	  { nixpkgs.overlays = attrValues overlays; }
	];

        # Make our inputs available to the config (for importing modules)
        specialArgs = { inherit inputs; };
      };
    };

    # Home configurations
    # Accessible via 'home-manager'
    homeConfigurations = {
      # We give our configuration a name (the user + hostname).
      # This makes it easy to add configurations for different users/PCs.
      # Usage: home-manager switch --flake .#christoph@nixinator
      "christoph@nixinator" = homeManagerConfiguration rec {
        pkgs = nixpkgs.legacyPackages."x86_64-linux"; # HomeManager needs this since 22.11 release

        modules = [
	  # >> Main HomeManager configuration file <<
          ./home/home.nix

          {
            home = rec {
              username = "christoph";
              homeDirectory = "/home/${username}";
              stateVersion = "22.05";
            };

	    # Add the overlays
	    # TODO: This is wrong, I need to figure out nur when I try out gamescope
	    # nixpkgs.overlays = attrValues overlays;
          }
        ];

        # Make our inputs available to the config (for importing modules)
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
