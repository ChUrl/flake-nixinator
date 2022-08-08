{ inputs, pkgs, lib, ... }:

let
  inherit (inputs) nixpkgs home-manager;

in rec {
  mkNixosConfig = { system, hostname, extraModules, homeConfigs }:
  nixpkgs.lib.nixosSystem {
    inherit system;

    # Make our inputs available to the configuration.nix (for importing modules)
    specialArgs = { inherit inputs; };

    modules = builtins.concatLists [
      [
        # Replace the pkgs to include overlays/unfree
        { nixpkgs.pkgs = pkgs; }

        # Main config file for all configs/hosts
        ../nixos/configuration.nix

        # Host specifig config file
        ../nixos/${hostname}
      ]

      extraModules

      # Make a user home for every config supplied
      (builtins.map home-manager.nixosModules.home-manager homeConfigs)
    ];
  };

  # Only returns the set that has to be passed to home-manager.nixosModules.home-manager
  # because then nix is able to automatically inject the dependencies
  mkHomeConfig = { username }:
  {
    # Include the inputs just in case they might be needed somewhere
    home-manager.extraSpecialArgs = { inherit inputs; };

    # Use systems pkgs, disables nixpkgs.* options in home.nix
    home-manager.useGlobalPkgs = true;

    # Enable installing packages through users.christoph.packages to /etc/profiles instead of ~/.nix-profile
    home-manager.useUserPackages = true;

    # User specific config file
    # TODO: Do this for a list of users
    home-manager.users.${username}.imports = [ ../home/${username} ]; # Is marked as error but correct (I think)
  };
}
