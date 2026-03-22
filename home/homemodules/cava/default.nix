{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) cava color;
in {
  options.homemodules.cava = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cava.enable {
    programs.cava = {
      enable = true;

      settings = {
        general = {
          framerate = 60; # default 60
          autosens = 1; # default 1
          sensitivity = 100; # default 100
          lower_cutoff_freq = 50; # not passed to cava if not provided
          higher_cutoff_freq = 10000; # not passed to cava if not provided
        };

        smoothing = {
          noise_reduction = 77; # default 77
          monstercat = false; # default false
          waves = false; # default false
        };

        color = {
          # https://github.com/catppuccin/cava/blob/main/themes/latte-transparent.cava
          gradient = 1;

          gradient_color_1 = "'${color.hexS.teal}'";
          gradient_color_2 = "'${color.hexS.sky}'";
          gradient_color_3 = "'${color.hexS.sapphire}'";
          gradient_color_4 = "'${color.hexS.blue}'";
          gradient_color_5 = "'${color.hexS.mauve}'";
          gradient_color_6 = "'${color.hexS.pink}'";
          gradient_color_7 = "'${color.hexS.maroon}'";
          gradient_color_8 = "'${color.hexS.red}'";
        };
      };
    };
  };
}
