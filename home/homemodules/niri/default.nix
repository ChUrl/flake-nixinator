{
  config,
  nixosConfig,
  lib,
  mylib,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.modules) niri color;
in {
  options.modules.niri = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf niri.enable rec {
    assertions = [
      {
        assertion = nixosConfig.programs.niri.enable;
        message = "Can't enable Niri config with Niri disabled!";
      }
      {
        assertion = !(programs.noctalia-shell.enable && programs.dank-material-shell.enable);
        message = "Can't enable Noctalia and DankMaterialShell at the same time!";
      }
    ];

    gtk = {
      enable = true;
      iconTheme.package = color.iconPackage;
      iconTheme.name = color.iconTheme;
    };

    # Disable niri polkit if we use DMS, as it has its own
    systemd.user.services.niri-flake-polkit = lib.mkForce {};

    home = {
      sessionVariables = {
        QT_QPA_PLATFORMTHEME = "gtk3"; # For Noctalia
        GDK_BACKEND = "wayland"; # For screen sharing
      };

      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = color.cursorPackage;
        name = color.cursor;
        size = color.cursorSize;
      };

      packages = with pkgs; [
        xwayland-satellite
        ncpamixer # Audio control

        nautilus # Fallback file chooser used by xdg-desktop-portal-gnome

        # In case we fallback to the default config
        alacritty
        fuzzel
      ];
    };

    programs = {
      # TODO: Those should be modules with their own options
      noctalia-shell = import ./noctalia.nix {inherit color;};
      dank-material-shell = import ./dankMaterialShell.nix {inherit config color;};

      # TODO: Extract options
      niri = {
        # enable = true; # Enabled in system module

        settings = {
          input = {
            focus-follows-mouse = {
              enable = true;
              max-scroll-amount = "0%"; # Skip partial windows that would scroll the viewport on focus
            };

            keyboard = {
              xkb = {
                layout = "us";
                variant = "altgr-intl";
                options = "nodeadkeys";
              };
            };

            touchpad = {
              click-method = "clickfinger";
              tap = true;
              drag = true;
              dwt = true;
              natural-scroll = true;
              scroll-method = "two-finger";
            };
          };

          hotkey-overlay = {
            hide-not-bound = true;
            skip-at-startup = true;
          };

          prefer-no-csd = true; # Disable client-side decorations (e.g. window titlebars)

          spawn-at-startup = [
            # TODO: Depend on options
            # {argv = ["noctalia-shell"];}
            {argv = ["dms" "run"];}

            {argv = ["kitty" "--hold" "fastfetch"];}
            {argv = ["zeal"];}
            {argv = ["protonvpn-app"];}
            {argv = ["fcitx5"];}
            {argv = ["jellyfin-mpv-shim"];}

            {sh = "sleep 5s && nextcloud --background";}
            {sh = "sleep 5s && keepassxc";}
          ];

          workspaces = {
            "1" = {open-on-output = "DP-1";};
            "2" = {open-on-output = "DP-1";};
            "3" = {open-on-output = "DP-1";};
            "4" = {open-on-output = "DP-1";};
            "5" = {open-on-output = "DP-1";};
            "6" = {open-on-output = "DP-1";};
            "7" = {open-on-output = "DP-1";};
            "8" = {open-on-output = "DP-1";};
            "9" = {open-on-output = "DP-1";};
            "10" = {open-on-output = "DP-2";};
          };

          outputs = {
            "DP-1" = {
              focus-at-startup = true;
              mode = {
                width = 3440;
                height = 1440;
                refresh = 164.999;
              };
              position = {
                x = 1920;
                y = 0;
              };
            };
            "DP-2" = {
              focus-at-startup = false;
              mode = {
                width = 1920;
                height = 1080;
                refresh = 60.0;
              };
              position = {
                x = 0;
                y = 0;
              };
            };
          };

          cursor = {
            hide-when-typing = true;
            theme = color.cursor;
            size = color.cursorSize;
          };

          layout = {
            # This border is drawn INSIDE the window
            border = {
              enable = true;
              width = 2;
              active = {color = color.hex.accent;};
              inactive = {color = color.hex.base;};
            };

            # This border is drawn OUTSIDE of the focused window
            focus-ring = {
              enable = false;
            };

            # Hint where a dragged window will be inserted
            insert-hint = {
              enable = true;
              display = {color = color.hex.accentDim;};
            };

            always-center-single-column = true;

            # Gaps between windows
            gaps = 8;

            # Gaps at screen borders
            struts = {
              # left = 8;
              # right = 8;
              top = 4; # Somehow the bar eclusivity doesn't work as expected
              bottom = 2;
            };
          };

          gestures = {
            hot-corners = {enable = false;};
          };

          window-rules = [
            # Rules for all windows
            {
              default-column-width.proportion = 0.5;
              default-window-height.proportion = 1.0;

              # Rounded corners
              clip-to-geometry = true;
              geometry-corner-radius = {
                bottom-left = 8.0;
                bottom-right = 8.0;
                top-left = 8.0;
                top-right = 8.0;
              };

              # open-floating = false;
              # open-focused = false;
              # open-fullscreen = false;
              # open-maximized = false;

              # open-on-output = "DP-1";
              # open-on-workspace = "2";

              # opacity = 0.8;
            }

            # Rules for specific windows
            {
              matches = [{app-id = "Zotero";}];
              open-on-workspace = "2";
            }
            {
              matches = [{app-id = "neovide";}];
              open-on-workspace = "2";
              open-maximized = true;
            }
            {
              matches = [{app-id = "code-url-handler";}];
              open-on-workspace = "2";
              open-floating = true;
            }
            {
              matches = [{app-id = "obsidian";}];
              open-on-workspace = "3";
            }
            {
              matches = [{app-id = "firefox";}];
              open-on-workspace = "4";
              open-maximized = true;
            }
            {
              matches = [{app-id = "Google-chrome";}];
              open-on-workspace = "4";
            }
            {
              matches = [{app-id = "chromium-browser";}];
              open-on-workspace = "4";
            }
            {
              matches = [{app-id = "org.qutebrowser.qutebrowser";}];
              open-on-workspace = "4";
            }
            {
              matches = [{app-id = "steam";}];
              open-on-workspace = "5";
            }
            {
              matches = [{app-id = "steam_app_(.+)";}];
              open-on-workspace = "6";
              open-floating = true;
              open-maximized = true;
            }
            {
              matches = [{app-id = "signal";}];
              open-on-workspace = "7";
              open-maximized = true;
            }
            {
              matches = [{app-id = "discord";}];
              open-on-workspace = "9";
              open-maximized = true;
            }
          ];

          layer-rules = [
            {
              # Set the overview wallpaper on the backdrop.
              matches = [{namespace = "^noctalia-overview*";}];
              place-within-backdrop = true;
            }
          ];

          debug = {
            # Allows notification actions and window activation from Noctalia.
            honor-xdg-activation-with-invalid-serial = [];
          };

          # TODO: Only start hypr... stuff with hyprland, not systemd (hypridle, hyprpaper currently)

          # TODO: Move values to config option and set in home/christoph/niri.nix
          binds = with config.lib.niri.actions; {
            # Applications
            "Mod+T" = {
              action = spawn "kitty";
              hotkey-overlay = {title = "Spawn Kitty.";};
            };
            "Mod+E" = {
              action = spawn "kitty" "--title=Yazi" "yazi";
              hotkey-overlay = {title = "Spawn Yazi.";};
            };
            "Mod+B" = {
              action = spawn "kitty" "--title=Btop" "btop";
              hotkey-overlay = {title = "Spawn Btop.";};
            };
            "Mod+R" = {
              action = spawn "kitty" "--title=Rmpc" "rmpc";
              hotkey-overlay = {title = "Spawn Rmpc.";};
            };
            "Mod+N" = {
              action = spawn "neovide";
              hotkey-overlay = {title = "Spawn Neovide.";};
            };
            "Mod+Ctrl+N" = {
              action = spawn "kitty" "--title=Navi" "navi";
              hotkey-overlay = {title = "Call Navi for help.";};
            };
            "Mod+Shift+N" = {
              action = spawn "neovide" "${config.paths.dotfiles}/navi/christoph.cheat";
              hotkey-overlay = {title = "Edit the Navi cheats.";};
            };
            "Mod+Shift+F" = {
              action = spawn "neovide" "${config.paths.dotfiles}/flake.nix";
              hotkey-overlay = {title = "Edit the NixFlake.";};
            };

            # TODO: Enable with Noctalia option
            # Noctalia
            # "Mod+A" = {
            #   action = spawn "noctalia-shell" "ipc" "call" "launcher" "toggle";
            #   hotkey-overlay = {title = "Toggle the application launcher.";};
            # };
            # "Mod+Ctrl+L" = {
            #   action = spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock";
            #   hotkey-overlay = {title = "Lock the screen.";};
            # };
            # "Mod+W" = {
            #   action = spawn "noctalia-shell" "ipc" "call" "wallpaper" "toggle";
            #   hotkey-overlay = {title = "Toggle the wallpaper chooser.";};
            # };
            # "Mod+Escape" = {
            #   action = spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle";
            #   hotkey-overlay = {title = "Toggle the session menu.";};
            # };

            # TODO: Enable with DMS option
            # DankMaterialShell
            "Mod+A" = {
              action = spawn "dms" "ipc" "call" "spotlight" "toggle";
              hotkey-overlay = {title = "Toggle the application launcher.";};
            };
            "Mod+Ctrl+L" = {
              action = spawn "dms" "ipc" "call" "lock" "lock";
              hotkey-overlay = {title = "Lock the screen.";};
            };
            "Mod+Escape" = {
              action = spawn "dms" "ipc" "call" "powermenu" "toggle";
              hotkey-overlay = {title = "Toggle the session menu.";};
            };
            "Mod+C" = {
              action = spawn "dms" "ipc" "call" "clipboard" "toggle";
              hotkey-overlay = {title = "Show clipboard history.";};
            };

            # Screenshots
            "Mod+S" = {
              action.screenshot-window = {write-to-disk = true;};
              hotkey-overlay = {title = "Take a screenshot of the current window.";};
            };
            "Mod+Shift+S" = {
              action.screenshot = {show-pointer = true;};
              hotkey-overlay = {title = "Take a screenshot of a region.";};
            };

            # Niri
            "Mod+Shift+Slash" = {
              action = show-hotkey-overlay;
              hotkey-overlay = {hidden = true;};
            };
            # "Alt+Tab" = {
            #   action = "next-window";
            #   hotkey-overlay = {title = "Switch to next window.";};
            # };
            # "Alt+Shift+Tab" = {
            #   action = "previous-window";
            #   hotkey-overlay = {title = "Switch to previous window.";};
            # };

            # Audio
            "XF86AudioRaiseVolume" = {
              action = spawn "wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "5%+";
              hotkey-overlay = {hidden = true;};
            };
            "XF86AudioLowerVolume" = {
              action = spawn "wpctl" "set-volume" "-l" "1.5" "@DEFAULT_AUDIO_SINK@" "5%-";
              hotkey-overlay = {hidden = true;};
            };
            "XF86AudioPlay" = {
              action = spawn "playerctl" "play-pause";
              hotkey-overlay = {hidden = true;};
            };
            "XF86AudioPrev" = {
              action = spawn "playerctl" "previous";
              hotkey-overlay = {hidden = true;};
            };
            "XF86AudioNext" = {
              action = spawn "playerctl" "next";
              hotkey-overlay = {hidden = true;};
            };

            # Niri windows
            "Mod+Q" = {
              action = close-window;
              hotkey-overlay = {title = "Close the current window.";};
            };
            "Mod+F" = {
              action = fullscreen-window;
              hotkey-overlay = {title = "Toggle between fullscreen and tiled window.";};
            };
            "Mod+Equal" = {
              action = set-column-width "+10%";
              hotkey-overlay = {title = "Increase column width";};
            };
            "Mod+Minus" = {
              action = set-column-width "-10%";
              hotkey-overlay = {title = "Decrease column width";};
            };
            "Mod+Shift+M" = {
              action = set-column-width "50%";
              hotkey-overlay = {title = "Set column width to 50%";};
            };
            "Mod+M" = {
              action = maximize-column;
              hotkey-overlay = {title = "Maximize column.";};
            };
            "Mod+V" = {
              action = toggle-window-floating;
              hotkey-overlay = {title = "Toggle between floating and tiled window.";};
            };
            "Mod+O" = {
              action = toggle-overview;
              hotkey-overlay = {title = "Toggle overlay.";};
            };
            "Mod+H" = {
              action = focus-column-or-monitor-left;
              hotkey-overlay = {title = "Focus column on the left. Equivalent bindings for other directions.";};
            };
            "Mod+J" = {
              action = focus-window-or-workspace-down;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+K" = {
              action = focus-window-or-workspace-up;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+L" = {
              action = focus-column-or-monitor-right;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+WheelScrollUp" = {
              action = focus-column-left;
              hotkey-overlay = {title = "Focus column on the left. Equivalent binding for other direction.";};
            };
            "Mod+WheelScrollDown" = {
              action = focus-column-right;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+WheelScrollUp" = {
              action = focus-workspace-up;
              hotkey-overlay = {title = "Focus previous workspace. Equivalent binding for other direction.";};
            };
            "Mod+Shift+WheelScrollDown" = {
              action = focus-workspace-down;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+H" = {
              action = move-column-left-or-to-monitor-left;
              hotkey-overlay = {title = "Move column to the left. Equivalent bindings for other directions.";};
            };
            "Mod+Shift+J" = {
              action = move-window-down-or-to-workspace-down;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+K" = {
              action = move-window-up-or-to-workspace-up;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+L" = {
              action = move-column-right-or-to-monitor-right;
              hotkey-overlay = {hidden = true;};
            };

            # Niri workspaces
            "Mod+1" = {
              action = focus-workspace 1;
              hotkey-overlay = {title = "Focus workspace 1. Equivalent bindings for other workspaces.";};
            };
            "Mod+2" = {
              action = focus-workspace 2;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+3" = {
              action = focus-workspace 3;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+4" = {
              action = focus-workspace 4;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+5" = {
              action = focus-workspace 5;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+6" = {
              action = focus-workspace 6;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+7" = {
              action = focus-workspace 7;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+8" = {
              action = focus-workspace 8;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+9" = {
              action = focus-workspace 9;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+0" = {
              action = focus-workspace 10;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+1" = {
              action.move-window-to-workspace = 1;
              hotkey-overlay = {title = "Move current window to workspace 1. Equivalent bindings for other workspaces.";};
            };
            "Mod+Shift+2" = {
              action.move-window-to-workspace = 2;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+3" = {
              action.move-window-to-workspace = 3;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+4" = {
              action.move-window-to-workspace = 4;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+5" = {
              action.move-window-to-workspace = 5;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+6" = {
              action.move-window-to-workspace = 6;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+7" = {
              action.move-window-to-workspace = 7;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+8" = {
              action.move-window-to-workspace = 8;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+9" = {
              action.move-window-to-workspace = 9;
              hotkey-overlay = {hidden = true;};
            };
            "Mod+Shift+0" = {
              action.move-window-to-workspace = 10;
              hotkey-overlay = {hidden = true;};
            };
          };
        };
      };
    };
  };
}
