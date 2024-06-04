# The curly braces denote a set of keys and values.
{
  description = "ChUrl's very bad and basic Nix config using Flakes";

  # This config is a Flake.
  # It needs inputs that are passed as arguments to the output.
  # These are the dependencies of the Flake.
  # The git revisions get locked in flake.lock to make the outputs deterministic.
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Other Flakes
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nur.url = "github:nix-community/NUR";
    devshell.url = "github:numtide/devshell";
    nixvim.url = "github:nix-community/nixvim";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    nix-alien.url = "github:thiagokokada/nix-alien";
    # musnix.url = "github:musnix/musnix";
    # nixified-ai.url = "github:nixified-ai/flake";
    # nixos-conf-editor.url = "github:vlinkz/nixos-conf-editor";
    # nix-matlab.url = "gitlab:doronbehar/nix-matlab";

    # plasma-manager.url = "github:pjones/plasma-manager";
    # plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.inputs.home-manager.follows = "home-manager";

    firefox-gnome-theme.url = "github:rafaelmardojai/firefox-gnome-theme";
    firefox-gnome-theme.flake = false;

    # adwaita-for-steam.url = "github:tkashkin/Adwaita-for-Steam";
    # adwaita-for-steam.flake = false;
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the inputs@ pattern.
  # It gives a name to the ... ellipses.
  outputs = inputs @ {
    nixpkgs,
    # home-manager,
    # hyprland,
    ...
  }:
  # With let you can define local variables
  let
    system = "x86_64-linux";

    # I don't know how to extend the nixpkgs.lib directly so just propagate mylib to the config modules as argument
    mylib = import ./lib {
      inherit inputs pkgs;
      inherit (nixpkgs) lib; # Equal to "lib = nixpkgs.lib;"
    };

    # Set overlays + unfree globally
    pkgs = import nixpkgs {
      inherit system;

      config.allowUnfree = true;

      # NOTE: Obsidian 1.5.3 depends on an unsupported Electron version. As long as Obsidian isn't updated, allow this version.
      config.permittedInsecurePackages = pkgs.lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";

      # NOTE: Probably shouldn't enable CUDA globally, but in the environment flakes where it is needed?
      #       Would it even work here? Since the flake imports its own nixpkgs...
      # config.cudaSupport = true;

      overlays = [
        inputs.devshell.overlays.default
        inputs.nur.overlay
        inputs.emacs-overlay.overlay
        # inputs.hyprpaper.overlays.default
        # inputs.hyprpicker.overlays.default

        # All my own overlays
        (import ./overlays {inherit nixpkgs inputs mylib;})
      ];
    };
    # The rec expression turns a basic set into a set where self-referencing is possible.
    # It is a shorthand for recursive and allows to use the values defined in this set from its own scope.
  in {
    # Local shell for NixFlake directory
    devShells."${system}".default = import ./shell.nix {inherit pkgs;};

    # System configurations + HomeManager module
    # Accessible via 'nixos-rebuild'
    nixosConfigurations = {
      # We give our configuration a name (the hostname) to choose a configuration when rebuilding.
      # This makes it easy to add different configurations (e.g. for a laptop).
      # Usage: sudo nixos-rebuild switch --flake .#nixinator
      nixinator = mylib.nixos.mkNixosConfig {
        inherit system mylib;

        hostname = "nixinator";
        username = "christoph";

        extraModules = [
        ];
      };

      # Usage: sudo nixos-rebuild switch --flake .#nixtop
      nixtop = mylib.nixos.mkNixosConfig {
        inherit system mylib;

        hostname = "nixtop";
        username = "christoph";

        extraModules = [
        ];
      };
    };
  };
}
