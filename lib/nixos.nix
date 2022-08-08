{ inputs, pkgs, lib, ... }:

let
  inherit (inputs) nixpkgs home-manager;

in rec {
  mkNixosConfig = { system, hostname, extraModules, homeManagerConfig }:
  nixpkgs.lib.nixosSystem {
    inherit system;

    # Make our inputs available to the configuration.nix (for importing modules)
    specialArgs = { inherit inputs; };

    modules = builtins.concatLists [
      [
        # Replace the pkgs to include overlays/unfree
        { nixpkgs.pkgs = pkgs; }

        # Main config file for all configs/hosts
        ./nixos/configuration.nix

        # Host specifig config file
        (import "./nixos/configuration-" + hostname + ".nix")
      ]
      extraModules
      [ homeManagerConfig ]
    ];
  };

  mkHomeManagerConfig = { username }:
  home-manager.nixosModules.home-manager
  {
    # Use systems pkgs, disables nixpkgs.* options in home.nix
    home-manager.useGlobalPkgs = true;

    # Enable installing packages through users.christoph.packages to /etc/profiles instead of ~/.nix-profile
    home-manager.useUserPackages = true;

    # User specific config file
    home-manager.users.username = import "./home/home-" + username + ".nix";

    # Include the inputs just in case they might be needed somewhere
    home-manager.extraSpecialArgs = { inherit inputs; };
  };
}
