{
  self,
  lib,
  mylib,
  pkgs,
  username,
  config,
  inputs,
  publicKeys,
  ...
}: {
  nix = {
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

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
}
