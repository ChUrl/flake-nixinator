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
        default-bg = "#${color.hex.bg}";
        default-fg = "#${color.hex.text}";

        highlight-color = "rgba(${color.rgbS.accent}, 0.5)";
        highlight-fg = "rgba(${color.rgbS.accentText}, 0.5)";
        highlight-active-color = "rgba(${color.rgbS.accentHL}, 0.5)";

        statusbar-bg = "#${color.hex.accent}";
        statusbar-fg = "#${color.hex.accentText}";

        inputbar-bg = statusbar-bg;
        inputbar-fg = statusbar-fg;

        completion-bg = "#${color.hex.bg}";
        completion-fg = default-fg;
        completion-highlight-bg = statusbar-bg;
        completion-highlight-fg = statusbar-fg;
        completion-group-bg = completion-bg;
        completion-group-fg = completion-fg;

        notification-bg = completion-bg;
        notification-fg = default-fg;
        notification-warning-bg = notification-bg;
        notification-warning-fg = "#${color.hex.peach}";
        notification-error-bg = notification-bg;
        notification-error-fg = "#${color.hex.red}";

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
