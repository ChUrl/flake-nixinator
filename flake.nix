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

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Manage secrets with agenix
    # agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Manage secrets with sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Nix User Repository (e.g. Firefox addons)
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Nix Package Search - nps
    nps.url = "github:OleMussmann/nps";
    nps.inputs.nixpkgs.follows = "nixpkgs";

    # Run unpatched binaries on NixOS
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    # NeoVim <3
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs nightly
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # nix-flatpak.inputs.nixpkgs.follows = "nixpkgs"; # nix-flatpak doesn't have this

    # HyprPlugins
    # hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    # hyprland-plugins.inputs.nixpkgs.follows = "nixpkgs";
    # hypr-dynamic-cursors.url = "github:VirtCode/hypr-dynamic-cursors";
    # hypr-dynamic-cursors.inputs.nixpkgs.follows = "nixpkgs";

    # Realtime audio
    # musnix.url = "github:musnix/musnix";
    # musnix.inputs.nixpkgs.follows = "nixpkgs";

    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";

    # Ags for widgets (this was a terrible idea)
    # ags.url = "github:Aylur/ags";
    # ags.inputs.nixpkgs.follows = "nixpkgs";

    # Spicetify
    # spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    # spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Pinned versions
    # v4l2loopback-pinned.url = "github:nixos/nixpkgs/4684fd6b0c01e4b7d99027a34c93c2e09ecafee2";
    # unityhub-pinned.url = "github:huantianad/nixpkgs/9542b0bc7701e173a10e6977e57bbba68bb3051f";
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
      overlays = [
        inputs.devshell.overlays.default
        inputs.nur.overlays.default
        inputs.nix-topology.overlays.default
        # inputs.emacs-overlay.overlay

        # Overriding specific packages from a different nixpkgs (e.g. a pull request)
        # can be done like this. Note that this creates an additional nixpkgs instance.
        # https://github.com/NixOS/nixpkgs/issues/418451
        # (final: prev: {
        #   unityhub_pinned_3_13 = import inputs.unityhub-pinned {
        #     config.allowUnfree = true;
        #     localSystem = {inherit (prev) system;};
        #   };
        # })

        # All my own overlays
        (import ./overlays {inherit nixpkgs inputs;})
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
      ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAoJac+GdGtzblCMA0lBfMdSR6aQ4YyovrNglCFGIny christoph.urlacher@protonmail.com";
    };

    # Extra NixOS system modules for all hosts.
    # HM modules are passed through home/modules/default.nix instead.
    commonModules = [
      # inputs.agenix.nixosModules.default
      inputs.sops-nix.nixosModules.sops

      # TODO: inputs.nix-topology.nixosModules.default
    ];
  in {
    # Local shell for NixFlake directory
    devShells."${system}".default = import ./shell.nix {inherit pkgs;};

    # TODO: Add my homelab configs into this flake, then add a topology config for each host
    # Output that generates a system topology diagram
    # topology = import inputs.nix-topology {
    #   inherit pkgs; # Only this package set must include nix-topology.overlays.default
    #   modules = [
    #     # Your own file to define global topology. Works in principle like a nixos module but uses different options.
    #     # ./topology.nix
    #     # Inline module to inform topology of your existing NixOS hosts.
    #     {nixosConfigurations = self.nixosConfigurations;}
    #   ];
    # };

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
          []
          ++ commonModules;
      };
      nixtop = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib publicKeys;
        hostname = "nixtop";
        username = "christoph";
        headless = false;
        extraModules =
          []
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
