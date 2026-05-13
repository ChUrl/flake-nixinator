{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) zed color;
in {
  options.homemodules.zed = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf zed.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      mutableUserKeymaps = false;
      mutableUserSettings = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      extensions = [
        "catppuccin"
        "catppuccin-icons"
        "dockerfile"
        "docker-compose"

        # "html"
        # "make"
        # "nix"
        "just"
        "perl"
        "assembly"
        "wat"
      ];

      themes = {};
      userDebug = [];

      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            ctrl-shift-t = "workspace::NewTerminal";
          };
        }
      ];

      userSettings = {
        buffer_font_family = config.homemodules.color.font;
        terminal.font_family = config.homemodules.color.font;
        theme = "Catppuccin Mocha";
        icon_theme = "Catppuccin Mocha";
        ui_font_size = 16;
        buffer_font_size = 14;

        project_panel.dock = "left";
        outline_panel.dock = "left";
        collaboration_panel.dock = "left";
        git_panel.dock = "left";
        agent.dock = "right";

        disable_ai = true;
        auto_signature_help = true;

        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        vim_mode = true;
        whick_key = {
          enabled = true;
          delay_ms = 10;
        };
      };

      userTasks = [];
    };
  };
}
