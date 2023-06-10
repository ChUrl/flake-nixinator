# TODO: Expose some settings
{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.kitty;
  # cfgnv = config.modules.neovim;
in {
  options.modules.kitty = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;

      font = {
        # package = pkgs.victor-mono;
        name = "JetBrainsMono Nerd Font Mono";
        size = 12;
      };

      keybindings = {
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
        "kitty_mod+l" = "next_layout";
      };

      settings = {
        editor = "hx";
        scrollback_lines = 10000;
        window_padding_width = 10; # Looks stupid with helix if bg doesn't match
        # hide_window_decorations = "yes";
        enabled_layouts = "grid,vertical,horizontal";

        allow_remote_control = "yes"; # For nnn file preview
        listen_on = "unix:@mykitty";

        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        #
        # Catppuccin Light Theme
        #

        # The basic colors
        foreground = "#4C4F69";
        background = "#EFF1F5";
        selection_foreground = "#EFF1F5";
        selection_background = "#DC8A78";

        # Cursor colors
        cursor = "#DC8A78";
        cursor_text_color = "#EFF1F5";

        # URL underline color when hovering with mouse
        url_color = "#DC8A78";

        # Kitty window border colors
        active_border_color = "#7287FD";
        inactive_border_color = "#9CA0B0";
        bell_border_color = "#DF8E1D";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#EFF1F5";
        active_tab_background = "#8839EF";
        inactive_tab_foreground = "#4C4F69";
        inactive_tab_background = "#9CA0B0";
        tab_bar_background = "#BCC0CC";

        # Colors for marks (marked text in the terminal)
        mark1_foreground = "#EFF1F5";
        mark1_background = "#7287fD";
        mark2_foreground = "#EFF1F5";
        mark2_background = "#8839EF";
        mark3_foreground = "#EFF1F5";
        mark3_background = "#209FB5";

        # The 16 terminal colors
        # black
        color0 = "#5C5F77";
        color8 = "#6C6F85";

        # red
        color1 = "#D20F39";
        color9 = "#D20F39";

        # green
        color2 = "#40A02B";
        color10 = "#40A02B";

        # yellow
        color3 = "#DF8E1D";
        color11 = "#DF8E1D";

        # blue
        color4 = "#1E66F5";
        color12 = "#1E66F5";

        # magenta
        color5 = "#EA76CB";
        color13 = "#EA76CB";

        # cyan
        color6 = "#179299";
        color14 = "#179299";

        # white
        color7 = "#ACB0BE";
        color15 = "#BCC0CC";
      };
    };
  };
}
