{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  headless,
  ...
}: let
  inherit (config.homemodules) terminal color;
in {
  options.homemodules.terminal = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf terminal.enable {
    homemodules = {
      bat.enable = true;
      btop.enable = true;
      fastfetch.enable = true;
      fish.enable = true;

      git = {
        enable = true;

        userName = "Christoph Urlacher";
        userEmail = "christoph.urlacher@protonmail.com";
        signCommits = true;
      };

      kitty.enable = true;
      lazygit.enable = true;

      neovim = {
        enable = true;
        alias = true;
        neovide = !headless;
      };

      ssh.enable = true;
      tmux.enable = true;
      yazi.enable = true;
    };
  };
}
