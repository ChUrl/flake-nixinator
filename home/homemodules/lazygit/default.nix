{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) lazygit color;
in {
  options.homemodules.lazygit = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf lazygit.enable {
    programs.lazygit = {
      enable = true;
      settings = {
        notARepository = "quit";
        timeFormat = "2022-12-31";
        shortTimeFormat = "23:49";
        border = "rounded";
        update.method = "never";

        git = {
          overrideGpg = true; # Allow editing past signed commits
          branchLogCmd = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n'";
          parseEmoji = true;
        };

        gui = {
          nerdFontsVersion = "3"; # Show icons

          theme = {
            lightTheme = false;

            activeBorderColor = [color.hexS.accent "bold"];
            inactiveBorderColor = [color.hexS.overlay0];

            defaultFgColor = [color.hexS.text];
            optionsTextColor = [color.hexS.accentDim];

            # Because we can't set the fucking foregrounds for this, use a dark color
            selectedLineBgColor = [color.hexS.surface0];
            selectedRangeBgColor = [color.hexS.surface0];

            cherryPickedCommitBgColor = [color.hexS.green];
            cherryPickedCommitFgColor = [color.hexS.blue];

            unstagedChangeColor = [color.hexS.red];
          };
        };
      };
    };
  };
}
