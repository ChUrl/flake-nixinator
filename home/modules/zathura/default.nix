{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) zathura color;
in {
  options.modules.zathura = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf zathura.enable {
    programs.zathura = {
      enable = true;

      options = rec {
        n-completion-items = 10;
        font = "${color.font} 11";
        guioptions = "s"; # s - statusbar, c - command line
        database = "sqlite";
        adjust-open = "best-fit";
        recolor-keephue = true;
        statusbar-basename = true;
        statusbar-home-tilde = true;
        window-title-basename = statusbar-basename;
        window-title-home-tilde = statusbar-home-tilde;

        # Colorscheme
        default-bg = "#${color.hex.light.base}";
        default-fg = "#${color.hex.light.text}";

        highlight-color = "rgba(${color.rgbString.dark.lavender}, 0.5)";
        highlight-fg = "rgba(${color.rgbString.dark.green}, 0.5)";
        highlight-active-color = "rgba(${color.rgbString.dark.pink}, 0.5)";

        statusbar-bg = "#${color.hex.dark.lavender}";
        statusbar-fg = default-fg;

        inputbar-bg = statusbar-bg;
        inputbar-fg = statusbar-fg;

        completion-bg = "#${color.hex.light.surface0}";
        completion-fg = default-fg;
        completion-highlight-bg = statusbar-bg;
        completion-highlight-fg = completion-fg;
        completion-group-bg = completion-bg;
        completion-group-fg = completion-fg;

        notification-bg = completion-bg;
        notification-fg = default-fg;
        notification-warning-bg = notification-bg;
        notification-warning-fg = "#${color.hex.light.peach}";
        notification-error-bg = notification-bg;
        notification-error-fg = "#${color.hex.light.red}";

        recolor-lightcolor = default-bg;
        recolor-darkcolor = default-fg;

        index-bg = default-bg;
        index-fg = default-fg;
        index-active-bg = completion-highlight-bg;
        index-active-fg = completion-highlight-fg;

        render-loading-bg = default-bg;
        render-loading-fg = default-fg;
      };
    };
  };
}
