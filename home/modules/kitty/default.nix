# TODO: Expose some settings
{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) kitty;
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

      settings = let
        color = config.modules.color.hex.dark;
      in {
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
        background = "#${color.base}";
        foreground = "#${color.text}";
        selection_foreground = "#${color.base}";
        selection_background = "#${color.rosewater}";

        # Cursor colors
        cursor = "#${color.rosewater}";
        cursor_text_color = "#${color.base}";

        # URL underline color when hovering with mouse
        url_color = "#${color.rosewater}";

        # Kitty window border colors
        active_border_color = "#${color.lavender}";
        inactive_border_color = "#${color.overlay0}";
        bell_border_color = "#${color.yellow}";

        # OS Window titlebar colors
        wayland_titlebar_color = "system";
        macos_titlebar_color = "system";

        # Tab bar colors
        active_tab_foreground = "#${color.base}";
        active_tab_background = "#${color.lavender}";
        inactive_tab_foreground = "#${color.text}";
        inactive_tab_background = "#${color.crust}";
        tab_bar_background = "#${color.base}";

        # Color for marks (marked text in the terminal)
        mark1_foreground = "#${color.base}";
        mark1_background = "#${color.lavender}";
        mark2_foreground = "#${color.base}";
        mark2_background = "#${color.mauve}";
        mark3_foreground = "#${color.base}";
        mark3_background = "#${color.sapphire}";

        # The 16 terminal colors
        # black
        color0 = "#${color.subtext1}";
        color8 = "#${color.subtext0}";

        # red
        color1 = "#${color.red}";
        color9 = "#${color.red}";

        # green
        color2 = "#${color.green}";
        color10 = "#${color.green}";

        # yellow
        color3 = "#${color.yellow}";
        color11 = "#${color.yellow}";

        # blue
        color4 = "#${color.blue}";
        color12 = "#${color.blue}";

        # magenta
        color5 = "#${color.pink}";
        color13 = "#${color.pink}";

        # cyan
        color6 = "#${color.teal}";
        color14 = "#${color.teal}";

        # white
        color7 = "#${color.surface2}";
        color15 = "#${color.surface1}";
      };
    };
  };
}
