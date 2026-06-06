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
      enableMcpIntegration = true;
      mutableUserKeymaps = false;
      mutableUserSettings = false;
      mutableUserTasks = false;
      mutableUserDebug = false;

      extensions = [
        "catppuccin"
        "catppuccin-icons"
        "comment"
        "git-firefly"

        "nix"
        "perl"
        "fish"
        "lua"
        "toml"
        "csharp"
        "java"
        "latex"
        "typst"
        "haskell"
        "glsl"
        "mermaid"
        "clojure"
        "verilog"
        "qml"
        "plantuml"
        "graphviz"

        "dockerfile"
        "docker-compose"

        "html"
        "xml"
        "scss"
        "rainbow-csv"
        "sql"
        "svelte"
        "svelte-mcp"
        "jinja2"

        "just"
        "make"
        "neocmake"
        "assembly"
        "wat"
        "linkerscript"
        "r"
      ];

      themes = {};
      userDebug = [];

      # TODO: Add neovim keymaps
      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            "ctrl-/" = "terminal_panel::Toggle";
          };
        }
        {
          context = "Editor";
          unbind = {
            "ctrl-/" = [
              "editor::ToggleComments"
              {
                advance_downwards = false;
              }
            ];
          };
        }
        {
          context = "(vim_mode == normal || vim_mode == visual) && !menu";
          bindings = {
            "ctrl-c" = "editor::ToggleComments";
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
        git_panel = {
          dock = "left";
          tree_view = true;
        };

        # TODO: Doesn't work, although perlnavigator advertises Perl::Tidy autoformatting...
        languages = {
          Perl = {
            formatter = "language_server";
          };
        };

        auto_signature_help = true;
        lsp = {
          nil = {
            initialization_options = {
              formatting = {
                # command = null;
                command = ["${pkgs.alejandra}/bin/alejandra"];
              };
            };
          };
          nixd = {
            initialization_options = {
              formatting = {
                command = ["${pkgs.alejandra}/bin/alejandra"];
              };
            };
          };
          # No idea how to configure the formatter
          # perlnavigator-server = let
          #   # TODO: Duplicated in neovim/default.nix. Need Perl module.
          #   perl = pkgs.perl.withPackages (p:
          #     with p; [
          #       PLS
          #       PerlCritic
          #       PerlTidy
          #       NetOpenSSH
          #       DateTime
          #       DBI
          #       DBDMariaDB
          #       CursesUI
          #       TextCSV_XS
          #     ]);
          # in {
          #   initialization_options = {
          #     "perlnavigator.perlPath" = "${perl}/bin";
          #     "perlnavigator.includePaths" = ["${perl}/lib/perl5"];
          #   };
          # };
        };

        disable_ai = false;
        agent = {
          dock = "right";
          sidebar_side = "right";
        };
        agent_servers = {
          claude-acp = {
            type = "registry";
          };
          codex-acp = {
            type = "registry";
          };
          mistral-vibe = {
            type = "registry";
          };
          gemini = {
            type = "registry";
          };
        };

        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        vim_mode = true;
        which_key = {
          enabled = true;
          delay_ms = 10;
        };
      };

      userTasks = [];
    };
  };
}
