{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) yazi color;
in {
  options.modules.yazi = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf yazi.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      shellWrapperName = "y";

      plugins = {
        inherit (pkgs.yaziPlugins) chmod diff full-border git lazygit mount ouch rsync starship sudo; # smart-paste
      };

      initLua = ''
        -- Load plugins
        require("full-border"):setup()
        require("starship"):setup()
        require("git"):setup()

        -- Show symlink in status bar
        Status:children_add(function(self)
          local h = self._current.hovered
          if h and h.link_to then
            return " -> " .. tostring(h.link_to)
          else
            return ""
          end
        end, 3300, Status.LEFT)

        -- Show user:group in status bar
        Status:children_add(function()
          local h = cx.active.current.hovered
          if not h or ya.target_family() ~= "unix" then
            return ""
          end

          return ui.Line {
            ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
            ":",
            ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
            " ",
          }
        end, 500, Status.RIGHT)
      '';

      # https://yazi-rs.github.io/docs/configuration/yazi
      # "$n": The n-th selected file (1...n)
      # "$@": All selected files
      # "$0": The hovered file
      settings = {
        mgr = {
          show_hidden = false;
        };

        # Associate mimetypes with edit/open/play actions
        # open = {};

        # Configure programs to edit/open/play files
        opener = {
          play = [
            {
              run = ''vlc "$@"'';
              orphan = true;
              desc = "Play selection";
            }
          ];
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              desc = "Edit selection";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open selection";
            }
          ];
          extract = [
            {
              run = ''ouch decompress -y "$@"'';
              desc = "Extract selection";
            }
          ];
        };

        preview = {
          max_width = 1000;
          max_height = 1000;
        };

        plugin.prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];

        plugin.prepend_previewers = [
          {
            mime = "application/*zip";
            run = "ouch";
          }
          {
            mime = "application/x-tar";
            run = "ouch";
          }
          {
            mime = "application/x-bzip2";
            run = "ouch";
          }
          {
            mime = "application/x-7z-compressed";
            run = "ouch";
          }
          {
            mime = "application/x-rar";
            run = "ouch";
          }
          {
            mime = "application/x-xz";
            run = "ouch";
          }
          {
            mime = "application/xz";
            run = "ouch";
          }
        ];
      };

      # TODO: Extract to separate file
      keymap = {
        input.prepend_keymap = [
          {
            # Don't exit vi mode on <Esc>, but close the input
            on = "<Esc>";
            run = "close";
            desc = "Cancel input";
          }
        ];

        mgr.prepend_keymap = [
          {
            on = ["<C-p>" "m"];
            run = "plugin mount";
            desc = "Manage device mounts";
          }
          {
            on = ["<C-p>" "c"];
            run = "plugin chmod";
            desc = "Chmod selection";
          }
          {
            on = ["<C-p>" "g"];
            run = "plugin lazygit";
            desc = "Run LazyGit";
          }
          {
            on = ["<C-p>" "a"];
            run = "plugin ouch";
            desc = "Add selection to archive";
          }
          {
            on = ["<C-p>" "d"];
            run = ''shell -- ripdrag -a -n "$@"'';
            desc = "Drag & drop selection";
          }
          {
            on = ["<C-p>" "D"];
            run = "plugin diff";
            desc = "Diff the selected with the hovered file";
          }
          {
            on = ["<C-p>" "r"];
            run = "plugin rsync";
            desc = "Copy files using rsync";
          }
          {
            on = ["<C-p>" "w"];
            run = ''wl-copy < "$0"'';
            desc = "Copy hovered file contents using wl-copy";
          }

          {
            on = "!";
            run = ''shell "$SHELL" --block'';
            desc = "Open $SHELL here";
          }
          {
            on = "y";
            run = [''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list'' "yank"];
            desc = "Copy files to system clipboard on yank";
          }
          # {
          #   on = "p";
          #   run = "plugin smart-paste";
          #   desc = "Paste into hovered directory or CWD";
          # }
          {
            on = "d";
            run = "remove --permanently";
            desc = "Delete selection";
          }
        ];
      };

      # https://github.com/catppuccin/yazi/blob/main/themes/mocha/catppuccin-mocha-lavender.toml
      theme = {
        mgr = {
          cwd = {fg = color.hexS.teal;};

          hovered = {
            fg = color.hexS.accentText;
            bg = color.hexS.accentDim;
            italic = true;
            bold = true;
          };
          preview_hovered = {
            fg = color.hexS.accentText;
            bg = color.hexS.accentDim;
            italic = true;
            bold = true;
          };

          find_keyword = {
            italic = true;
            bold = true;
            underline = true;
          };
          find_position = {
            italic = true;
            bold = true;
            underline = true;
          };

          marker_copied = {
            fg = color.hexS.green;
            bg = color.hexS.green;
          };
          marker_cut = {
            fg = color.hexS.red;
            bg = color.hexS.red;
          };
          marker_marked = {
            fg = color.hexS.teal;
            bg = color.hexS.teal;
          };
          marker_selected = {
            fg = color.hexS.lavender;
            bg = color.hexS.lavender;
          };

          count_copied = {
            fg = color.hexS.accentText;
            bg = color.hexS.green;
          };
          count_cut = {
            fg = color.hexS.accentText;
            bg = color.hexS.red;
          };
          count_selected = {
            fg = color.hexS.accentText;
            bg = color.hexS.lavender;
          };

          border_symbol = "│";
          border_style = {fg = color.hexS.overlay0;};
        };

        tabs = {
          active = {
            fg = color.hexS.accentText;

            # Has to be the same as inactive.fg,
            # otherwise the separators are colored incorrectly
            bg = color.hexS.accent;

            bold = true;
            italic = true;
          };
          inactive = {
            fg = color.hexS.accent;
            bg = color.hexS.surface0;
          };
        };

        mode = {
          normal_main = {
            fg = color.hexS.accentText;
            bg = color.hexS.accent;
            bold = true;
          };
          normal_alt = {
            fg = color.hexS.accent;
            bg = color.hexS.surface0;
          };

          select_main = {
            fg = color.hexS.accentText;
            bg = color.hexS.green;
            bold = true;
          };
          select_alt = {
            fg = color.hexS.green;
            bg = color.hexS.surface0;
          };

          unset_main = {
            fg = color.hexS.accentText;
            bg = color.hexS.flamingo;
            bold = true;
          };
          unset_alt = {
            fg = color.hexS.flamingo;
            bg = color.hexS.surface0;
          };
        };

        status = {
          separator_open = "";
          separator_close = "";

          progress_label = {
            fg = color.hexS.accentText;
            bold = true;
          };
          progress_normal = {
            fg = color.hexS.blue;
            bg = color.hexS.surface0;
          };
          progress_error = {
            fg = color.hexS.red;
            bg = color.hexS.surface0;
          };

          perm_type = {fg = color.hexS.blue;};
          perm_read = {fg = color.hexS.yellow;};
          perm_write = {fg = color.hexS.red;};
          perm_exec = {fg = color.hexS.green;};
          perm_sep = {fg = color.hexS.overlay0;};
        };

        input = {
          border = {fg = color.hexS.accentDim;};
          title = {};
          value = {};
          selected = {reversed = true;};
        };

        pick = {
          border = {fg = color.hexS.accentDim;};
          active = {fg = color.hexS.accentHl;};
          inactive = {};
        };

        confirm = {
          border = {fg = color.hexS.accentDim;};
          title = {fg = color.hexS.accentDim;};
          content = {};
          list = {};
          btn_yes = {reversed = true;};
          btn_no = {};
        };

        cmp = {
          border = {fg = color.hexS.accentDim;};
        };

        tasks = {
          border = {fg = color.hexS.accentDim;};
          title = {};
          hovered = {underline = true;};
        };

        which = {
          cand = {fg = color.hexS.accent;};
          desc = {fg = color.hexS.accentHl;};
          mask = {bg = color.hexS.surface0;};
          rest = {fg = color.hexS.surface0;};
          separator = "  ";
          separator_style = {fg = color.hexS.text;};
        };

        help = {
          on = {fg = color.hexS.accent;};
          run = {fg = color.hexS.accentHl;};
          desc = {fg = color.hexS.text;};
          hovered = {
            fg = color.hexS.accentText; # TODO: This is not applied

            bg = color.hexS.surface0; # If the fg would work we could use color.hexS.accentDim
            bold = true;
            italic = true;
          };
          footer = {
            fg = color.hexS.text;
            bg = color.hexS.surface0;
          };
        };

        notify = {
          title_info = {fg = color.hexS.teal;};
          title_warn = {fg = color.hexS.yellow;};
          title_error = {fg = color.hexS.red;};
        };

        spot = {
          border = {fg = color.hexS.lavender;};
          title = {fg = color.hexS.lavender;};
          tbl_cell = {
            fg = color.hexS.lavender;
            reversed = true;
          };
          tbl_col = {bold = true;};
        };

        # Default rules good enough
        # filetype = {
        #   prepend_rules = import ./specialFiletypes.nix {inherit lib nixosConfig color;};
        # };

        # Prepend to override default config
        icon = {
          prepend_dirs = import ./specialDirectories.nix {inherit color;};
          prepend_files = import ./specialFiles.nix {inherit color;};
          prepend_exts = import ./specialExtensions.nix {inherit color;};
        };
      };
    };
  };
}
