# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  # Comment out if you wish to disable unfree packages for your system
  nixpkgs.config.allowUnfree = true;

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    delta.enable = true;
    userEmail = "christoph.urlacher@protonmail.com";
    userName = "ChUrl";
  };
  programs.neovim.enable = true;
  programs.firefox.enable = true;

  # Add stuff for your user as you see fit:
  # home.packages = with pkgs; [ steam ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
