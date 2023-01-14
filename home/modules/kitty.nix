{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.kitty;
  # cfgnv = config.modules.neovim;
in {

  options.modules.kitty = {
    enable = mkEnableOpt "Kitty";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        package = pkgs.victor-mono;
        name = "Victor Mono SemiBold";
        size = 12;
      };

      # TODO: Configure
      settings = {
        editor = "hx";
        scrollback_lines = 10000;
        window_padding_width = 0;
        # hide_window_decorations = "yes";

        # Light Theme
        # background = "#f7f7f7";
        # foreground = "#494542";
        # selection_background = "#a4a1a1";
        # selection_foreground = "#f7f7f7";
        # cursor = "#494542";
        # color0 = "#090200";
        # color1 = "#da2c20";
        # color2 = "#00a152";
        # color3 = "#ffcc00";
        # color4 = "#00a0e4";
        # color5 = "#a06994";
        # color6 = "#0077d9";
        # color7 = "#a4a1a1";
        # color8 = "#5b5754";
        # color9 = "#e8bacf";
        # color10 = "#3a3332";
        # color11 = "#494542";
        # color12 = "#7f7c7b";
        # color13 = "#d6d4d3";
        # color14 = "#ccab53";
        # color15 = "#d2b3ff";
      };

      keybindings = {
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
      };
    };
  };
}