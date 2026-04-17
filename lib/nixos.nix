{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Common nix daemon settings shared between NixOS and nix-darwin.
  # Darwin additionally needs nix.enable = true.
  mkCommonNixSettings = username: {
    enable = true;
    package = pkgs.nixVersions.stable;

    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';

    settings = {
      trusted-users = ["root" username];
      auto-optimise-store = true;

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://comfyui.cachix.org"
        # "https://ai.cachix.org"
        # "https://app.cachix.org/cache/nixos-rocm"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
        # "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        # "nixos-rocm.cachix.org-1:VEpsf7pRIijjd8csKjFNBGzkBqOmw8H9PRmgAq14LnE="
      ];
    };

    gc = {
      automatic = false;
      options = "--delete-older-than 5d";
    };

    optimise = {
      automatic = true;
    };

    registry = lib.mapAttrs' (n: v: lib.nameValuePair n {flake = v;}) inputs;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "home-manager=${inputs.home-manager.outPath}"
    ];
  };

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

  mkDarwinConfigWithHomeManagerModule = {
    system,
    mylib,
    hostname,
    username,
    publicKeys,
    extraModules ? [],
    headless ? false,
  }:
    inputs.nix-darwin.lib.darwinSystem {
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

          # Host specific configuration
          ../system/${hostname}

          # Import all of my custom system modules
          ../system/systemmodules/darwin.nix
        ]

        extraModules

        # HM is installed as a system module when using mkNixosConfigWithHomeManagerModule.
        [
          inputs.home-manager.darwinModules.home-manager
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
                # Host specific configuration
                ../home/${username}/${hostname}
              ];

              sharedModules = [
                # Import all of my custom HM modules.
                # Putting them into sharedModules enables correct nixd completions.
                ../home/homemodules/darwin.nix
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
