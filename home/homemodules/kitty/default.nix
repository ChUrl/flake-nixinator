# TODO: Expose some settings
{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) kitty color;
in {
  options.modules.kitty = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf kitty.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;

      font = {
        name = "${config.modules.color.font}";
        size = 12;
      };

      keybindings = {
        "kitty_mod" = "ctrl+shift";
        "kitty_mod+enter" = "launch --cwd=current";
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
        "kitty_mod+l" = "next_layout";
      };

      settings = {
        editor = config.home.sessionVariables.EDITOR;
        scrollback_lines = 10000;
        window_padding_width = 10; # Looks stupid with editors if bg doesn't match
        # hide_window_decorations = "yes";
        enabled_layouts = "grid,vertical,horizontal";

        allow_remote_control = "yes"; # For nnn file preview or nvim scrollback
        listen_on = "unix:@mykitty";

        tab_bar_min_tabs = 2; # Don't show a single tab
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        #
        # Color Theme
        #

        # The basic colors
        background = color.hexS.base;
        foreground = color.hexS.text;
        selection_foreground = color.hexS.base;
        selection_background = color.hexS.rosewater;

        # Cursor colors
        cursor = color.hexS.rosewater;
        cursor_text_color = color.hexS.base;

        # URL underline color when hovering with mouse
        url_color = color.hexS.rosewater;

        # Kitty window border colors
        active_border_color = color.hexS.lavender;
        inactive_border_color = color.hexS.overlay0;
        bell_border_color = color.hexS.yellow;

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = color.hexS.base;
        active_tab_background = color.hexS.lavender;
        inactive_tab_foreground = color.hexS.text;
        inactive_tab_background = color.hexS.crust;
        tab_bar_background = color.hexS.base;

        # Color for marks (marked text in the terminal)
        mark1_foreground = color.hexS.base;
        mark1_background = color.hexS.lavender;
        mark2_foreground = color.hexS.base;
        mark2_background = color.hexS.mauve;
        mark3_foreground = color.hexS.base;
        mark3_background = color.hexS.sapphire;

        # The 16 terminal colors
        # black
        color0 = color.hexS.subtext1;
        color8 = color.hexS.subtext0;

        # red
        color1 = color.hexS.red;
        color9 = color.hexS.red;

        # green
        color2 = color.hexS.green;
        color10 = color.hexS.green;

        # yellow
        color3 = color.hexS.yellow;
        color11 = color.hexS.yellow;

        # blue
        color4 = color.hexS.blue;
        color12 = color.hexS.blue;

        # magenta
        color5 = color.hexS.pink;
        color13 = color.hexS.pink;

        # cyan
        color6 = color.hexS.teal;
        color14 = color.hexS.teal;

        # white
        color7 = color.hexS.surface2;
        color15 = color.hexS.surface1;
      };
    };
  };
}
