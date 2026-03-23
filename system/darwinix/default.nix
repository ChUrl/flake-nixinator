{
  self,
  lib,
  mylib,
  pkgs,
  username,
  config,
  inputs,
  publicKeys,
  hostname,
  ...
}: {
  nix = {
    enable = true;

    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';

    settings.trusted-users = ["root" "${username}"];

    gc.automatic = false;
    gc.options = "--delete-older-than 5d";
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    registry = lib.mapAttrs' (n: v: lib.nameValuePair n {flake = v;}) inputs;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "home-manager=${inputs.home-manager.outPath}"
    ];
  };

  networking = {
    hostName = "${hostname}";
    localHostName = "${hostname}";
    computerName = "${hostname}";

    applicationFirewall = {
      enable = true;
      enableStealthMode = false;
      allowSigned = true;
      allowSignedApp = true;
      blockAllIncoming = false;
    };

    knownNetworkServices = [
      "Wi-Fi"
      "Thunderbold Bridge"
    ];

    dns = [
      "192.168.86.26"
      "8.8.8.8"
      "8.8.4.4"
    ];

    # wg-quick = {};
  };

  power = {
    # restartAfterFreeze = false;
    # restartAfterPowerFailure = false;

    sleep = {
      computer = 10; # 10 minutes until sleep
      display = 5;
      harddisk = 5;
    };
  };

  system = {
    primaryUser = "${username}";

    # TODO:
    defaults = {
      # dock = {};

      trackpad = {
        ActuateDetents = true; # Haptic feedback
        ActuationStrength = 1;
        Clicking = true; # Tap to click
        Dragging = true; # Double tap to drag
        TrackpadRightClick = true;
        TrackpadPinch = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      swapLeftCtrlAndFn = false;
      swapLeftCommandAndLeftAlt = false;
    };
  };

  users.users.${username} = {
    isHidden = false;
    description = "Christoph";
    home = "/Users/${username}";
    createHome = false;

    # NOTE: Not set if the user already exists on darwin, so use chsh for the root user
    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      publicKeys.${username}.ssh
    ];

    # packages = with pkgs; [];
  };

  environment.shells = with pkgs; [pkgs.fish];

  environment.systemPackages = with pkgs; [
    alejandra
    neovim
    wget
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    monolisa
  ];

  programs = {
    fish.enable = true;
  };

  services = {
    # For another time maybe
    # sketchybar = {};
    # skhd = {};
    # yabai = {};
  };

  # NOTE: Not installed automatically
  homebrew = {
    enable = true;
    enableFishIntegration = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall unlisted casks and associated files on rebuild
      upgrade = true;
    };

    brews = [];

    casks = [
      "alt-tab"
      "discord"
      "iina"
      "nextcloud"
      "obsidian"
      "protonvpn"
    ];
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
