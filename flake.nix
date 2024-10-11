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

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NeoVim
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    # Other
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    nix-alien.url = "github:thiagokokada/nix-alien";
    devshell.url = "github:numtide/devshell";
    nur.url = "github:nix-community/NUR"; # Nix User Repository
    firefox-gnome-theme.url = "github:rafaelmardojai/firefox-gnome-theme";
    firefox-gnome-theme.flake = false;

    # Disabled
    # adwaita-for-steam.url = "github:tkashkin/Adwaita-for-Steam";
    # adwaita-for-steam.flake = false;
    # plasma-manager.url = "github:pjones/plasma-manager";
    # plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    # plasma-manager.inputs.home-manager.follows = "home-manager";
    # musnix.url = "github:musnix/musnix";
    # nixified-ai.url = "github:nixified-ai/flake";
    # nixos-conf-editor.url = "github:vlinkz/nixos-conf-editor";
    # nix-matlab.url = "gitlab:doronbehar/nix-matlab";
  };

  # Outputs is a function that takes the inputs as arguments.
  # To handle extra arguments we use the @ inputs pattern.
  # It gives the name "inputs" to the ... ellipses.
  outputs = {
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # TODO: Use those to generate configs
    hostnames = ["nixinator" "nixtop"];
    usernames = ["christoph"];

    # Set overlays + unfree globally
    pkgs = import nixpkgs {
      inherit system;

      # config.allowUnfree = true;
      config.allowUnfreePredicate = pkg: true;

      overlays = [
        inputs.devshell.overlays.default
        inputs.nur.overlay
        inputs.emacs-overlay.overlay

        # All my own overlays
        (import ./overlays {inherit nixpkgs inputs;})
      ];
    };

    # I don't know how to extend the nixpkgs.lib directly so just propagate mylib to the config modules as argument
    mylib = import ./lib {
      inherit inputs pkgs;

      # Equal to "lib = nixpkgs.lib;". This is required, because mylib also uses the nixpkgs lib.
      inherit (nixpkgs) lib;
    };
  in {
    # Local shell for NixFlake directory
    devShells."${system}".default = import ./shell.nix {inherit pkgs;};

    # We give each configuration a name (the hostname) to choose a configuration when rebuilding.
    # This makes it easy to add different configurations (e.g. for a laptop).
    # Usage: sudo nixos-rebuild switch --flake .#nixinator
    # Usage: sudo nixos-rebuild switch --flake .#nixtop
    nixosConfigurations = {
      # TODO: This should probably run using mapAttrs over the hostnames list...
      nixinator = mylib.nixos.mkNixosSystemConfig {
        inherit system mylib;
        hostname = "nixinator";
        extraModules = [];
      };
      nixtop = mylib.nixos.mkNixosSystemConfig {
        inherit system mylib;
        hostname = "nixtop";
        extraModules = [];
      };
    };

    # The home configuration can be rebuilt separately:
    # Usage: home-manager switch --flake .#christoph@nixinator
    # Usage: home-manager switch --flake .#christoph@nixtop
    homeConfigurations = {
      # TODO: This should probably run using mapAttrs and cartesianProduct over the hostnames and usernames lists...
      "christoph@nixinator" = mylib.nixos.mkNixosHomeConfig {
        inherit system mylib;
        username = "christoph";
        hostname = "nixinator";
        extraModules = [];
      };
      "christoph@nixtop" = mylib.nixos.mkNixosHomeConfig {
        inherit system mylib;
        username = "christoph";
        hostname = "nixtop";
        extraModules = [];
      };
    };
  };
}
