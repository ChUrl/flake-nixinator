{
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (inputs) home-manager;
in {
  mkNixosConfig = {
    system ? "x86_64-linux",
    mylib,
    hostname,
    username ? "christoph",
    extraModules ? [],
  }:
    lib.nixosSystem {
      inherit system;

      # Make our inputs available to the configuration.nix (for importing modules)
      # specialArgs are propagated to all modules
      specialArgs = {inherit inputs hostname username mylib;};

      modules = builtins.concatLists [
        [
          # Replace the pkgs to include overlays/unfree
          {nixpkgs.pkgs = pkgs;}

          # Main config file for all configs/hosts
          ../system
        ]

        extraModules

        # I included the home config statically like this as I am the only user
        # I would have liked to make it more flexible (for multiple users on the same host)
        # but I failed because nix stopped autoinjecting the required arguments and I didn't
        # know how to handle that...
        [
          home-manager.nixosModules.home-manager
          {
            # extraSpecialArgs are propagated to all hm config modules
            home-manager.extraSpecialArgs = {inherit inputs hostname username mylib;};

            # Use systems pkgs, disables nixpkgs.* options in home.nix
            home-manager.useGlobalPkgs = true;

            # Enable installing packages through users.christoph.packages to /etc/profiles instead of ~/.nix-profile
            home-manager.useUserPackages = true;

            # User specific config file
            home-manager.users.${username}.imports = [../home/${username}];
          }
        ]
      ];
    };
}
