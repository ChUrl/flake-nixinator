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
    headless ? false,
  }:
    lib.nixosSystem {
      inherit system;

      # Values in "specialArgs" are propagated to all system modules.
      specialArgs = {inherit inputs hostname mylib system username headless;};

      modules = builtins.concatLists [
        [
          # Replace the default "pkgs" with my configured version
          # to allow installation of unfree software and my own overlays.
          {nixpkgs.pkgs = pkgs;}

          # Import the toplevel system configuration module.
          ../system
        ]

        extraModules

        # HM is installed as a system module when using mkNixosConfigWithHomeManagerModule.
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              # Values in "extraSpecialArgs" are propagated to all HM modules.
              extraSpecialArgs = {inherit inputs system hostname username mylib headless;};

              # Use the "pkgs" from the system configuration.
              # This disables "nixpkgs.*" options in HM modules.
              useGlobalPkgs = true;

              # Packages in "users.${username}.packages" will be installed
              # to /etc/profiles instead of ~/.nix-profile.
              useUserPackages = true;

              # Import the user-specific HM toplevel module.
              users.${username}.imports = [../home/${username}];
            };
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

      # Values in "specialArgs" are propagated to all system modules.
      specialArgs = {inherit inputs hostname mylib system;};

      modules = builtins.concatLists [
        [
          # Replace the default "pkgs" with my configured version
          # to allow installation of unfree software and my own overlays.
          {nixpkgs.pkgs = pkgs;}

          # Import the toplevel system configuration module.
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

      # Values in "extraSpecialArgs" are propagated to all HM modules.
      extraSpecialArgs = {inherit inputs system mylib username hostname;};

      modules = builtins.concatLists [
        [
          # Import the user-specific HM toplevel module.
          ../home/${username}
        ]

        extraModules
      ];
    };
}
