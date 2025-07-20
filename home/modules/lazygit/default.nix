{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) lazygit color;
in {
  options.modules.lazygit = import ./options.nix {inherit lib mylib;};

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
            optionsTextColor = [color.hexS.accentDim];
            selectedLineBgColor = [color.hexS.accentDim];
            selectedRangeBgColor = [color.hexS.accentDim];
            cherryPickedCommitBgColor = ["#179299"];
            cherryPickedCommitFgColor = ["#1e66f5"];
            unstagedChangeColor = ["red"];
          };
        };
      };
    };
  };
}
