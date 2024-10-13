# TODO: Expose some settings
{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.kitty;
  color = config.modules.color;
  # cfgnv = config.modules.neovim;
in {
  options.modules.kitty = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
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
        foreground = "#${color.light.text}";
        background = "#${color.light.base}";
        selection_foreground = "#${color.light.base}";
        selection_background = "#${color.light.rosewater}";

        # Cursor colors
        cursor = "#${color.light.rosewater}";
        cursor_text_color = "#${color.light.base}";

        # URL underline color when hovering with mouse
        url_color = "#${color.light.rosewater}";

        # Kitty window border colors
        active_border_color = "#${color.light.lavender}";
        inactive_border_color = "#${color.light.overlay0}";
        bell_border_color = "#${color.light.yellow}";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#${color.dark.base}";
        active_tab_background = "#${color.dark.lavender}";
        inactive_tab_foreground = "#${color.dark.text}";
        inactive_tab_background = "#${color.dark.crust}";
        tab_bar_background = "#${color.light.base}";

        # Color for marks (marked text in the terminal)
        mark1_foreground = "#${color.light.base}";
        mark1_background = "#${color.light.lavender}";
        mark2_foreground = "#${color.light.base}";
        mark2_background = "#${color.light.mauve}";
        mark3_foreground = "#${color.light.base}";
        mark3_background = "#${color.light.sapphire}";

        # The 16 terminal colors
        # black
        color0 = "#${color.light.subtext1}";
        color8 = "#${color.light.subtext0}";

        # red
        color1 = "#${color.light.red}";
        color9 = "#${color.light.red}";

        # green
        color2 = "#${color.light.green}";
        color10 = "#${color.light.green}";

        # yellow
        color3 = "#${color.light.yellow}";
        color11 = "#${color.light.yellow}";

        # blue
        color4 = "#${color.light.blue}";
        color12 = "#${color.light.blue}";

        # magenta
        color5 = "#${color.light.pink}";
        color13 = "#${color.light.pink}";

        # cyan
        color6 = "#${color.light.teal}";
        color14 = "#${color.light.teal}";

        # white
        color7 = "#${color.light.surface2}";
        color15 = "#${color.light.surface1}";
      };
    };
  };
}
