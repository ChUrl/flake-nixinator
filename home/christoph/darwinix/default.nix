{
  pkgs,
  nixosConfig,
  config,
  lib,
  mylib,
  username,
  inputs,
  ...
}: {
  config = {
    paths = rec {
      nixflake = "${config.home.homeDirectory}/NixFlake";
      dotfiles = "${nixflake}/config";
    };

    homemodules = {
      color = {
        scheme = "catppuccin-mocha";
        accent = "mauve";
        accentHl = "pink";
        accentDim = "lavender";
        accentText = "base";

        font = "MonoLisa Alt Script";
      };

      packages.enable = true;
      terminal.enable = true;
    };

    home = {
      inherit username;

      homeDirectory = "/Users/${config.home.username}";
      enableNixpkgsReleaseCheck = true;

      sessionVariables = {
        LANG = "en_US.UTF-8";
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        TERMINAL = "kitty";
      };

      # packages = with pkgs; []; # Configured in homemodules/packages

      stateVersion = "25.11";
    };

    programs = {};

    services = {};
  };
}
