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
        "kitty_mod" = "ctrl+shift";
        "kitty_mod+enter" = "launch --cwd=current";
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
        "kitty_mod+l" = "next_layout";
      };

      settings = let
        light = color.hex.light;
        dark = color.hex.dark;
      in {
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
        background = "#${light.base}";
        foreground = "#${light.text}";
        selection_foreground = "#${light.base}";
        selection_background = "#${light.rosewater}";

        # Cursor colors
        cursor = "#${light.rosewater}";
        cursor_text_color = "#${light.base}";

        # URL underline color when hovering with mouse
        url_color = "#${light.rosewater}";

        # Kitty window border colors
        active_border_color = "#${light.lavender}";
        inactive_border_color = "#${light.overlay0}";
        bell_border_color = "#${light.yellow}";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#${dark.base}";
        active_tab_background = "#${dark.lavender}";
        inactive_tab_foreground = "#${dark.text}";
        inactive_tab_background = "#${dark.crust}";
        tab_bar_background = "#${light.base}";

        # Color for marks (marked text in the terminal)
        mark1_foreground = "#${light.base}";
        mark1_background = "#${light.lavender}";
        mark2_foreground = "#${light.base}";
        mark2_background = "#${light.mauve}";
        mark3_foreground = "#${light.base}";
        mark3_background = "#${light.sapphire}";

        # The 16 terminal colors
        # black
        color0 = "#${light.subtext1}";
        color8 = "#${light.subtext0}";

        # red
        color1 = "#${light.red}";
        color9 = "#${light.red}";

        # green
        color2 = "#${light.green}";
        color10 = "#${light.green}";

        # yellow
        color3 = "#${light.yellow}";
        color11 = "#${light.yellow}";

        # blue
        color4 = "#${light.blue}";
        color12 = "#${light.blue}";

        # magenta
        color5 = "#${light.pink}";
        color13 = "#${light.pink}";

        # cyan
        color6 = "#${light.teal}";
        color14 = "#${light.teal}";

        # white
        color7 = "#${light.surface2}";
        color15 = "#${light.surface1}";
      };
    };
  };
}
