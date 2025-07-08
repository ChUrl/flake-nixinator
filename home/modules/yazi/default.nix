{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) yazi;
in {
  options.modules.yazi = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf yazi.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      shellWrapperName = "y";

      plugins = {
        inherit (pkgs.yaziPlugins) chmod diff full-border git lazygit mount ouch rsync starship sudo; # smar-paste
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
    };
  };
}
