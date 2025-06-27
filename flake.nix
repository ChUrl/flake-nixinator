{
  description = "ChUrl's NixOS config using Flakes";

  # This config is a Flake.
  # It depends on "inputs" that are passed as arguments to the "outputs" function.
  # The inputs' git revisions get locked in the flake.lock file, making the outputs deterministic.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NeoVim <3
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Nix User Repository (e.g. Firefox addons)
    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Ags for widgets (this was a terrible idea)
    ags.url = "github:Aylur/ags";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprpanel
    hyprpanel.url = "github:jas-singhfsu/hyprpanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";

    # Nix Package Search - nps
    nps.url = "github:OleMussmann/nps";
    nps.inputs.nixpkgs.follows = "nixpkgs";

    # Declarative Flatpak
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-flatpak.inputs.nixpkgs.follows = "nixpkgs";

    # Creates an environment containing required libraries for an executable
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-alien.inputs.nixpkgs.follows = "nixpkgs";

    # Emacs nightly
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: Move away from devshell, as it breaks e.g. C++/Rust library propagation
    #       and doesn't provide any benefits for me
    devshell.url = "github:numtide/devshell";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the @ inputs pattern.
  # It gives the name "inputs" to the ... ellipses.
  outputs = {nixpkgs, ...} @ inputs: let
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
      overlays = [
        inputs.devshell.overlays.default
        inputs.nur.overlays.default
        inputs.emacs-overlay.overlay

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
  in {
    # Local shell for NixFlake directory
    devShells."${system}".default = import ./shell.nix {inherit pkgs;};

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
        inherit system mylib;
        hostname = "nixinator";
        username = "christoph";
        extraModules = [];
      };
      nixtop = mylib.nixos.mkNixosConfigWithHomeManagerModule {
        inherit system mylib;
        hostname = "nixtop";
        username = "christoph";
        extraModules = [];
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
