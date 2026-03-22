{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) bat color;
in {
  options.homemodules.bat = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf bat.enable {
    programs.bat = {
      enable = true;

      themes = {
        catppuccin-latte = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-latte.tmTheme";
        };
      };

      config = {
        theme = "catppuccin-latte";
      };
    };
  };
}
