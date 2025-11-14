{
  description = "ChUrl's NixOS config using Flakes";

  # This config is a Flake.
  # It depends on "inputs" that are passed as arguments to the "outputs" function.
  # The inputs' git revisions get locked in the flake.lock file, making the outputs deterministic.
  inputs = {
    # Just for shell.nix
    devshell.url = "github:numtide/devshell";

    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # NOTE: Update this after May and November
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Disk partitioning
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Opt-in state
    impermanence.url = "github:nix-community/impermanence";
    # impermanence.inputs.nixpkgs.follows = "nixpkgs";

    # Manage secrets with sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Secure boot
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # Nix User Repository (e.g. Firefox addons)
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Nix Package Search - nps
    nps.url = "github:OleMussmann/nps";
    nps.inputs.nixpkgs.follows = "nixpkgs";

    # Run unpatched binaries on NixOS
    nix-alien.url = "github:thiagokokada/nix-alien";
    # Don't follow nixpkgs:
    # https://github.com/thiagokokada/nix-alien#user-content-nixos-installation-with-flakes
    # nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    # Niri
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Quickshell
    quickshell.url = "github:quickshell-mirror/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";

    # Noctalia shell
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    noctalia.inputs.quickshell.follows = "quickshell";

    # Lol
    waifu-cursors.url = "github:kagurazakei/waifu-cursors";

    # Caelestia shell
    caelestia.url = "github:caelestia-dots/shell";
    caelestia.inputs.nixpkgs.follows = "nixpkgs";
    caelestia.inputs.quickshell.follows = "quickshell";
    # caelestia-cli.url = "github:caelestia-dots/cli";
    # caelestia-cli.inputs.nixpkgs.follows = "nixpkgs";

    # DankMaterialShell
    # dgop.url = "github:AvengeMedia/dgop";
    # dgop.inputs.nixpkgs.follows = "nixpkgs";
    # dms-cli.url = "github:AvengeMedia/danklinux";
    # dms-cli.inputs.nixpkgs.follows = "nixpkgs";
    # dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell";
    # dankMaterialShell.inputs.nixpkgs.follows = "nixpkgs";
    # dankMaterialShell.inputs.dgop.follows = "dgop";

    # Hyprland (use flake so plugins are not built from source)
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # HyprPlugins
    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";
    hypr-dynamic-cursors.url = "github:VirtCode/hypr-dynamic-cursors";
    hypr-dynamic-cursors.inputs.nixpkgs.follows = "nixpkgs";
    hypr-dynamic-cursors.inputs.hyprland.follows = "hyprland";
    hyprspace.url = "github:KZDKM/Hyprspace";
    # hyprspace.inputs.nixpkgs.follows = "nixpkgs";
    hyprspace.inputs.hyprland.follows = "hyprland";

    # NeoVim <3
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs nightly
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox theme
    textfox.url = "github:adriankarlen/textfox";
    textfox.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # nix-flatpak.inputs.nixpkgs.follows = "nixpkgs"; # nix-flatpak doesn't have this

    # Realtime audio
    # musnix.url = "github:musnix/musnix";
    # musnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the @ inputs pattern.
  # It gives the name "inputs" to the ... ellipses.
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Our configuration is buildable on the following system/platform.
    # Configs can support more than a single system simultaneously,
    # e.g. NixOS (linux) and MacOS (darwin) or Arm.
    system = "x86_64-linux";

    # We configure our global packages here.
    # Usually, "nixpkgs.legacyPackages.${system}" is used (and more efficient),
    # but because we want to change the nixpkgs configuration, we have to re-import it.
    pkgs = import nixpkgs {
      inherit system;

      config.allowUnfree = true;

      # Alternative to setting config.allowUnfree.
      # I read somewhere that this is more suitable when running HM standalone.
      config.allowUnfreePredicate = pkg: true;

      # Overlays define changes in the nixpkgs package set.
      # Final is nixpkgs with the overlay applied, prev is nixpkgs before applying the overlay:
      # final: prev: {
      #   firefox = prev.firefox.override { ... };
      #   myBrowser = final.firefox;
      # }
      overlays = let
        # Maintain additional stable pkgs.
        # This is supposed to provide a backup for packages in case they
        # stop building on the unstable branch.
        # It should otherwise not be mixed with this configuration,
        # so don't even pass it to the modules.
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
          config.allowUnfreePredicate = pkg: true;
        };
      in [
        inputs.devshell.overlays.default
        inputs.nur.overlays.default
        inputs.niri.overlays.niri
        # inputs.emacs-overlay.overlay

        # All my own overlays (derivations + modifications)
        (import ./overlays {inherit inputs nixpkgs pkgs-stable;})
      ];
    };

    # My own library functions are imported here.
    # They are made available to the system and HM configs by inheriting mylib.
    mylib = import ./lib {
      # Equal to "inputs = inputs;" and "pkgs = pkgs;".
      # The right values come from the outer scope, because the names match
      # in the inner and outer scope, we can use "inherit" instead.
      # This is required because the lib/ module expects those as arguments.
      inherit inputs pkgs;

      # Equal to "lib = nixpkgs.lib;".
      # This is required because mylib also uses the default nixpkgs lib.
      inherit (nixpkgs) lib;
    };

    # NOTE: Keep public keys here so they're easy to rotate

    publicKeys.christoph = {
      # /home/christoph/.ssh/id_ed25519.pub
      ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAoJac+GdGtzblCMA0lBfMdSR6aQ4YyovrNglCFGIny christoph.urlacher@protonmail.com";

      # /home/christoph/.secrets/age/age.pub
      age = "age14ph8vrj657e7s35d60xehzuq46t9zd6pzcm6pw4jragzrvf6xs9s77usnm";
    };

    # Extra NixOS system modules for all hosts.
    # HM modules are passed through home/modules/default.nix instead.
    commonModules = [
      inputs.sops-nix.nixosModules.sops
      inputs.impermanence.nixosModules.impermanence
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
  in {
    # Local shell for NixFlake directory
    devShells.${system}.default = import ./shell.nix {inherit pkgs;};

    # We give each configuration a (host)name to choose a configuration when rebuilding.
    # This makes it easy to add different configurations (e.g. for a laptop).
    # Usage: sudo nixos-rebuild switch --flake .#nixinator
    # Usage: sudo nixos-rebuild switch --flake .#nixtop
    nixosConfigurations = {
      # These configurations include HM as a NixOS module. This has a few benefits:
      # - The system config is available from within the HM config,
      #   passed as nixosConfig input to each HM module
      # - This seems to be required for opt-in persistence
      # - The HM config can be rebuilt separately from the system,
      #   without generating a new boot entry
      # Downsides:
      # - The nixd HM options completion doesn't seem to work
      # - The system needs to be rebuilt with every HM config change
      nixinator = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib publicKeys;
        hostname = "nixinator";
        username = "christoph";
        headless = false;
        extraModules =
          [
            inputs.disko.nixosModules.disko
            inputs.niri.nixosModules.niri # This also imports the HM module
          ]
          ++ commonModules;
      };
      nixtop = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib publicKeys;
        hostname = "nixtop";
        username = "christoph";
        headless = false;
        extraModules =
          [
            inputs.niri.nixosModules.niri
          ]
          ++ commonModules;
      };
      servenix = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib publicKeys;
        hostname = "servenix";
        username = "christoph";
        headless = true;
        extraModules =
          []
          ++ commonModules;
      };
      thinknix = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib publicKeys;
        hostname = "thinknix";
        username = "christoph";
        headless = true;
        extraModules =
          []
          ++ commonModules;
      };

      # These configurations don't include HM.
      # When using those, HM has to be installed separately in homeConfigurations.
      # nixinator = mylib.nixos.mkNixosSystemConfig {
      #   inherit system mylib;
      #   hostname = "nixinator";
      #   extraModules = [];
      # };
      # nixtop = mylib.nixos.mkNixosSystemConfig {
      #   inherit system mylib;
      #   hostname = "nixtop";
      #   extraModules = [];
      # };
    };

    # The home configuration can be rebuilt separately:
    # Usage: home-manager switch --flake .#christoph@nixinator
    # Usage: home-manager switch --flake .#christoph@nixtop
    # homeConfigurations = {
    #   "christoph@nixinator" = mylib.nixos.mkNixosHomeConfig {
    #     inherit system mylib;
    #     username = "christoph";
    #     hostname = "nixinator";
    #     extraModules = [];
    #   };
    #   "christoph@nixtop" = mylib.nixos.mkNixosHomeConfig {
    #     inherit system mylib;
    #     username = "christoph";
    #     hostname = "nixtop";
    #     extraModules = [];
    #   };
    # };
  };
}
