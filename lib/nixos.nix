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
    publicKeys,
    extraModules ? [],
    headless ? false,
  }:
    lib.nixosSystem {
      inherit system;

      # Values in "specialArgs" are propagated to all system modules.
      specialArgs = {
        inherit inputs system hostname mylib username publicKeys headless;
      };

      modules = builtins.concatLists [
        [
          # Replace the default "pkgs" with my configured version
          # to allow installation of unfree software and my own overlays.
          {nixpkgs.pkgs = pkgs;}

          # Import the toplevel system configuration module.
          ../system
          ../system/cachix.nix

          # Host specific configuration
          ../system/${hostname}

          # Import all of my custom system modules
          ../system/systemmodules
        ]

        extraModules

        # HM is installed as a system module when using mkNixosConfigWithHomeManagerModule.
        [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              # Values in "extraSpecialArgs" are propagated to all HM modules.
              extraSpecialArgs = {
                inherit inputs system hostname mylib username publicKeys headless;
              };

              # Use the "pkgs" from the system configuration.
              # This disables "nixpkgs.*" options in HM modules.
              useGlobalPkgs = true;

              # Packages in "users.${username}.packages" will be installed
              # to /etc/profiles instead of ~/.nix-profile.
              useUserPackages = true;

              users.${username}.imports = [
                # Import the user-specific HM toplevel module.
                # It will be merged with the main config (like all different modules).
                # Settings regarding a specific host (e.g. desktop or laptop)
                # should only be made in the host-specific config.
                ../home/${username}

                # Host specific configuration
                ../home/${username}/${hostname}
              ];

              sharedModules = [
                # Import all of my custom HM modules.
                # Putting them into sharedModules enables correct nixd completions.
                ../home/homemodules
              ];
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
