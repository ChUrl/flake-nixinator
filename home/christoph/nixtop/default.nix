{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the laptop
rec {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        # kb-layout = "de";
        # kb-variant = "nodeadkeys";
        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = {
          "eDP-1" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "eDP-1" = [1 2 3 4 5 6 7 8 9];
        };
      };
    };

    home.packages = with pkgs; [
    ];
  };
}
