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
        name = "${color.font}";
        size = 12;
      };

      keybindings = {
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

        allow_remote_control = "yes"; # For nnn file preview
        listen_on = "unix:@mykitty";

        tab_bar_min_tabs = 1;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

        #
        # Color Theme
        #

        # The basic colors
        foreground = "#${color.hex.light.text}";
        background = "#${color.hex.light.base}";
        selection_foreground = "#${color.hex.light.base}";
        selection_background = "#${color.hex.light.rosewater}";

        # Cursor colors
        cursor = "#${color.hex.light.rosewater}";
        cursor_text_color = "#${color.hex.light.base}";

        # URL underline color when hovering with mouse
        url_color = "#${color.hex.light.rosewater}";

        # Kitty window border colors
        active_border_color = "#${color.hex.light.lavender}";
        inactive_border_color = "#${color.hex.light.overlay0}";
        bell_border_color = "#${color.hex.light.yellow}";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#${color.hex.dark.base}";
        active_tab_background = "#${color.hex.dark.lavender}";
        inactive_tab_foreground = "#${color.hex.dark.text}";
        inactive_tab_background = "#${color.hex.dark.crust}";
        tab_bar_background = "#${color.hex.light.base}";

        # Color for marks (marked text in the terminal)
        mark1_foreground = "#${color.hex.light.base}";
        mark1_background = "#${color.hex.light.lavender}";
        mark2_foreground = "#${color.hex.light.base}";
        mark2_background = "#${color.hex.light.mauve}";
        mark3_foreground = "#${color.hex.light.base}";
        mark3_background = "#${color.hex.light.sapphire}";

        # The 16 terminal colors
        # black
        color0 = "#${color.hex.light.subtext1}";
        color8 = "#${color.hex.light.subtext0}";

        # red
        color1 = "#${color.hex.light.red}";
        color9 = "#${color.hex.light.red}";

        # green
        color2 = "#${color.hex.light.green}";
        color10 = "#${color.hex.light.green}";

        # yellow
        color3 = "#${color.hex.light.yellow}";
        color11 = "#${color.hex.light.yellow}";

        # blue
        color4 = "#${color.hex.light.blue}";
        color12 = "#${color.hex.light.blue}";

        # magenta
        color5 = "#${color.hex.light.pink}";
        color13 = "#${color.hex.light.pink}";

        # cyan
        color6 = "#${color.hex.light.teal}";
        color14 = "#${color.hex.light.teal}";

        # white
        color7 = "#${color.hex.light.surface2}";
        color15 = "#${color.hex.light.surface1}";
      };
    };
  };
}
