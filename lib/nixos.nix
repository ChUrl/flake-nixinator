{
  inputs,
  pkgs,
  lib,
  ...
}: {
  mkNixosConfigWithHomeManagerModule = {
    system,
    mylib,
    hostname,
    username,
    extraModules ? [],
  }:
    lib.nixosSystem {
      inherit system;

      # Make our inputs available to the configuration.nix (for importing modules)
      # specialArgs are propagated to all modules
      specialArgs = {inherit inputs hostname mylib system username;};

      modules = builtins.concatLists [
        [
          # Replace the pkgs to include overlays/unfree
          {nixpkgs.pkgs = pkgs;}

          # Main config file for all configs/hosts
          ../system
        ]

        extraModules

        # HM is installed as a system module
        [
          inputs.home-manager.nixosModules.home-manager
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

  mkNixosSystemConfig = {
    system,
    mylib,
    hostname,
    extraModules ? [],
  }:
    lib.nixosSystem {
      inherit system;

      # Make our inputs available to the configuration.nix (for importing modules)
      # specialArgs are propagated to all modules
      specialArgs = {inherit inputs hostname mylib system;};

      modules = builtins.concatLists [
        [
          # Replace the pkgs to include overlays/unfree
          {nixpkgs.pkgs = pkgs;}

          # Main config file for all configs/hosts
          ../system
        ]

        extraModules
      ];
    };

  mkNixosHomeConfig = {
    system,
    mylib,
    username,
    hostname,
    extraModules ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      # HM propagates these to every module
      extraSpecialArgs = {inherit inputs system mylib username hostname;};

      modules = builtins.concatLists [
        [
          ../home/${username}
        ]

        extraModules
      ];
    };
}
