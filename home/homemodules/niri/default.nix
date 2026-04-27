{
  config,
  nixosConfig,
  lib,
  mylib,
  inputs,
  pkgs,
  ...
}: let
  inherit (config.homemodules) niri color;
in {
  options.homemodules.niri = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf niri.enable rec {
    assertions = [
      {
        assertion = nixosConfig.programs.niri.enable;
        message = "Can't enable Niri config with Niri disabled!";
      }
    ];

    gtk = let
      gtkConfig = {
        enable = true;

        colorScheme = "dark";

        iconTheme = {
          package = color.iconPackage;
          name = color.iconTheme;
        };

        cursorTheme = {
          name = color.cursor;
          package = color.cursorPackage;
        };

        theme = {
          # name = "adw-gtk3-dark";
          # package = pkgs.adw-gtk3;
          name = "catppuccin-mocha-mauve-standard";
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            accents = ["mauve"];
            size = "standard";
          };
        };
      };

      gtkExtraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    in
      gtkConfig
      // {
        gtk3 = gtkConfig // {extraConfig = gtkExtraConfig;};
        gtk4 = gtkConfig // {extraConfig = gtkExtraConfig;};
      };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };

    # Disable Niri's kde auth agent and start gnome auth agent instead
    systemd.user.services.niri-flake-polkit = lib.mkForce {};
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    home = {
      file = {
        # Link theme for flatpak
        ".themes/${config.gtk.theme.name}".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}";

        ".config/waypaper/config.ini".text = lib.generators.toINI {} {
          Settings = {
            use_xdg_state = true;

            # Those are contained in the statefile (.local/state/waypaper/state.ini):
            # backend = "swww";
            # folder = "~/NixFlake/wallpapers";
            # monitors = "All";
            # wallpaper =

            language = "en";
            show_path_in_tooltip = true;
            fill = "fill";
            sort = "name";
            color = "#ffffff";
            subfolders = false;
            all_subfolders = false;
            show_hidden = false;
            show_gifs_only = false;
            zen_mode = false;
            number_of_columns = 3;
            swww_transition_type = "wipe";
            swww_transition_step = 90;
            swww_transition_angle = 30;
            swww_transition_duration = 1;
            swww_transition_fps = 60;
            mpvpaper_sound = false;
            # mpvpaper_options = "";
            # post_command =
            # stylesheet = /home/christoph/.config/waypaper/style.css
            # keybindings = ~/.config/waypaper/keybindings.ini
          };
        };
      };

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
        # ncpamixer # Audio control
        wiremix # Audio control
        swww
        waypaper
        wtype # For elephant

        # GTK apps (look good and work well with xdg portals)
        nautilus # Fallback file chooser used by xdg-desktop-portal-gnome

        # Catppuccin-GTK theme
        sassc
        gtk-engine-murrine
        gnome-themes-extra

        # In case we fallback to the default niri config/keybindings
        alacritty
        fuzzel
      ];
    };

    services = {
      dunst = {
        enable = true;

        iconTheme.package = color.iconPackage;
        iconTheme.name = color.iconTheme;

        settings = {
          global = {
            # monitor = config.homemodules.waybar.monitor;
            follow = "keyboard";
            font = "${color.font} 11";
            offset = "9x11";
            background = color.hexS.base;
            foreground = color.hexS.text;
            frame_width = 2;
            corner_radius = 8;
            separator_color = "frame";
          };

          urgency_low = {
            frame_color = color.hexS.green;
          };

          urgency_normal = {
            frame_color = color.hexS.green;
          };

          urgency_critical = {
            frame_color = color.hexS.red;
          };
        };
      };
    };

    programs = {
      walker = {
        enable = true;
        runAsService = true;

        # https://github.com/abenz1267/walker/blob/master/resources/config.toml
        config = {
          theme = "cattpuccin-mocha";

          providers = {
            default = ["desktopapplications"];
          };
          empty = ["desktopapplications"];

          selection_wrap = true;
          hide_quick_activation = true;
          actions_as_menu = true;
        };

        themes."cattpuccin-mocha" = let
          border-radius = "8px";
        in {
          style = ''
            @define-color rosewater #${color.hex.rosewater};
            @define-color flamingo #${color.hex.flamingo};
            @define-color pink #${color.hex.pink};
            @define-color mauve #${color.hex.mauve};
            @define-color red #${color.hex.red};
            @define-color maroon #${color.hex.maroon};
            @define-color peach #${color.hex.peach};
            @define-color yellow #${color.hex.yellow};
            @define-color green #${color.hex.green};
            @define-color teal #${color.hex.teal};
            @define-color sky #${color.hex.sky};
            @define-color sapphire #${color.hex.sapphire};
            @define-color blue #${color.hex.blue};
            @define-color lavender #${color.hex.lavender};
            @define-color text #${color.hex.text};
            @define-color subtext1 #${color.hex.subtext1};
            @define-color subtext0 #${color.hex.subtext0};
            @define-color overlay2 #${color.hex.overlay2};
            @define-color overlay1 #${color.hex.overlay1};
            @define-color overlay0 #${color.hex.overlay0};
            @define-color surface2 #${color.hex.surface2};
            @define-color surface1 #${color.hex.surface1};
            @define-color surface0 #${color.hex.surface0};
            @define-color base #${color.hex.base};
            @define-color mantle #${color.hex.mantle};
            @define-color crust #${color.hex.crust};

            @define-color accent #${color.hex.accent};

            * {
              all: unset;
              font-family: ${color.font};
            }

            .normal-icons {
              -gtk-icon-size: 16px;
            }

            .large-icons {
              -gtk-icon-size: 32px;
            }

            scrollbar {
              opacity: 0;
            }

            .box-wrapper {
              box-shadow:
                0 19px 38px rgba(0, 0, 0, 0.3),
                0 15px 12px rgba(0, 0, 0, 0.22);
              background: @base;
              padding: 20px;
              border-radius: ${border-radius};
              border: 2px solid @accent;
            }

            .preview-box,
            .elephant-hint,
            .placeholder {
              color: @text;
            }

            .search-container {
              border-radius: ${border-radius};
              background: @mantle;
              padding: 8px;
            }

            .input placeholder {
              opacity: 0.5;
            }

            .input selection {
              background: @surface1;
            }

            .input {
              caret-color: @text;
              background: none;
              padding: 10px;
              color: @text;
            }

            .list {
              color: @text;
            }

            .item-box {
              border-radius: ${border-radius};
              padding: 10px;
            }

            .item-quick-activation {
              background: alpha(@mauve, 0.25);
              border-radius: ${border-radius};
              padding: 10px;
            }

            child:selected .item-box,
            row:selected .item-box {
              background: alpha(@surface0, 0.6);
            }

            .item-subtext {
              font-size: 12px;
              opacity: 0.5;
            }

            .providerlist .item-subtext {
              font-size: unset;
              opacity: 0.75;
            }

            .item-image-text {
              font-size: 28px;
            }

            .preview {
              border: 1px solid alpha(@mauve, 0.25);
              border-radius: ${border-radius};
              color: @text;
            }

            .calc .item-text {
              font-size: 24px;
            }

            .symbols .item-image {
              font-size: 24px;
            }

            .todo.done .item-text-box {
              opacity: 0.25;
            }

            .todo.urgent {
              font-size: 24px;
            }

            .todo.active {
              font-weight: bold;
            }

            .bluetooth.disconnected {
              opacity: 0.5;
            }

            .preview .large-icons {
              -gtk-icon-size: 64px;
            }

            .keybinds {
              padding-top: 10px;
              border-top: 1px solid @surface0;
              font-size: 12px;
              color: @text;
            }

            .keybind-button {
              opacity: 0.5;
            }

            .keybind-button:hover {
              opacity: 0.75;
            }

            .keybind-bind {
              text-transform: lowercase;
              opacity: 0.35;
            }

            .keybind-label {
              padding: 2px 4px;
              border-radius: ${border-radius};
              border: 1px solid @text;
            }

            .error {
              padding: 10px;
              background: @red;
              color: @base;
            }

            :not(.calc).current {
              font-style: italic;
            }

            .preview-content.archlinuxpkgs,
            .preview-content.dnfpackages {
              font-family: monospace;
            }
          '';

          # layouts = {};
        };
      };

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
            {argv = ["ashell" "-c" "${config.paths.dotfiles}/ashell/config.toml"];}
            {argv = ["waypaper" "--restore"];}

            {argv = ["kitty" "--hold" "fastfetch"];}
            {argv = ["fcitx5"];}
            # {argv = ["zeal"];}
            # {argv = ["protonvpn-app"];}
            # {argv = ["jellyfin-mpv-shim"];}

            {sh = "sleep 5s && nextcloud --background";}
            # {sh = "sleep 5s && keepassxc";}
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

            shadow = {
              enable = true;
              draw-behind-window = true;
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

            # Floating + unmaximized windows
            {
              matches = [
                {app-id = "com.github.finefindus.eyedropper";}
                {app-id = "re.sonny.Junction";}
              ];

              open-maximized = false;
              open-floating = true;

              # default-floating-position = {
              #   x = 0;
              #   y = 0;
              #   relative-to = "center";
              # };
            }

            # Specific floating windows
            {
              matches = [
                {app-id = "re.sonny.Junction";}
              ];
              default-column-width.fixed = 500;
              default-window-height.fixed = 250;
            }
            {
              matches = [
                {app-id = "com.github.finefindus.eyedropper";}
              ];
              default-column-width.fixed = 250;
              default-window-height.fixed = 500;
            }

            # Rules for specific windows
            {
              matches = [{app-id = "neovide";}];
              open-on-workspace = "2";
              open-maximized = true;
              open-focused = true;
            }
            {
              matches = [{app-id = "jetbrains-clion";}];
              open-on-workspace = "2";
              open-maximized = true;
            }
            {
              matches = [{app-id = "code-url-handler";}];
              open-on-workspace = "2";
              open-floating = true;
            }
            {
              matches = [
                {
                  app-id = "electron";
                  title = ".*Chriphost - Obsidian.*";
                }
              ];
              open-on-workspace = "3";
              # open-maximized = true;
              open-focused = true;
            }
            {
              matches = [{app-id = "Zotero";}];
              open-on-workspace = "3";
              # open-maximized = true;
              open-focused = true;
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
              matches = [{app-id = "factorio";}];
              open-on-workspace = "6";
              # open-floating = true;
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
              # Waybar rounded corners background clipping fix
              matches = [{namespace = "waybar";}];
              opacity = 0.99;
              shadow = {
                enable = true;
                draw-behind-window = true;
              };
            }
          ];

          debug = {
            # Allows notification actions and window activation from Noctalia.
            honor-xdg-activation-with-invalid-serial = [];
          };

          # TODO: Move values to config option and set in home/christoph/niri.nix
          binds = with config.lib.niri.actions; let
            sessionMenu = mylib.rofi.mkMenu {
              prompt = "Session";
              layers = [
                {
                  "󰤂  Poweroff" = "poweroff";
                  "󰜉  Reboot" = "reboot";
                  "󰌾  Lock" = "loginctl lock-session";
                  # "  Reload Hyprpanel" = "systemctl --user restart hyprpanel.service";
                  # "  Reload Hyprland" = "hyprctl reload";
                  # "  Exit Hyprland" = "hyprctl dispatch exit";
                  "  Exit Niri" = "niri msg action quit";
                }
              ];
              prompts = ["Select Session Action"];
              rofiCmd = "walker -d";
            };
            wallpaperMenu = mylib.rofi.mkMenu {
              prompt = "Wallpaper";
              layers = [
                "eza -1 ${config.paths.nixflake}/wallpapers"
              ];
              prompts = ["Select Wallpaper"];
              # Use waypaper instead of swww directly, so the chosen wallpaper will be restored after reboot
              command = "waypaper --wallpaper ${config.paths.nixflake}/wallpapers/$OPTION0";
              rofiCmd = "walker -d";
            };
            # No lectures anymore :) - Kept as example
            lecturesMenu = mylib.rofi.mkMenu {
              prompt = "Lecture";
              layers = [
                "eza -1 -D ~/Notes/TU"
                "eza -1 -D ~/Notes/TU/$OPTION0"
                "eza -1 ~/Notes/TU/$OPTION0/$OPTION1 | grep '.pdf'"
              ];
              prompts = [
                "Select Lecture"
                "Select Subfolder"
                "Select Deck"
              ];
              command = "xdg-open ~/Notes/TU/$OPTION0/$OPTION1/$OPTION2";
              rofiCmd = "walker -d";
            };
            # niriMenu = mylib.rofi.mkMenu {
            #   prompt = "Niri";
            #   layers = [
            #     {
            #       "󰹑  Take Region Screenshot" = "niri msg action screenshot -p false";
            #       "󰹑  Take Window Screenshot" = "niri msg action screenshot-window -p false -d true";
            #       "󰹑  Take Full-Screen Screenshot" = "niri msg action screenshot-screen -p false -d true";
            #     }
            #   ];
            #   prompts = ["Execute Niri Action"];
            #   rofiCmd = "walker -d";
            # };
            globalMenu = mylib.rofi.mkMenu {
              prompt = "Global";
              layers = [
                {
                  "  Control Session" = "${sessionMenu}/bin/rofi-menu-Session";
                  "󰸉  Change Wallpaper" = "${wallpaperMenu}/bin/rofi-menu-Wallpaper";
                  "󰋗  View Keybindings" = "niri msg action show-hotkey-overlay";
                  "  Open Lecture Material" = "${lecturesMenu}/bin/rofi-menu-Lecture";
                  # "  Niri Actions" = "${niriMenu}/bin/rofi-menu-Niri";
                  # TODO: What else? SSH menu?
                }
              ];
              prompts = ["Select Action"];
              rofiCmd = "walker -d";
            };
          in {
            # DMenu
            "Mod+Shift+A" = {
              action = spawn "walker" "-m" "providerlist";
              hotkey-overlay = {title = "Toggle the launcher.";};
            };
            "Mod+A" = {
              action = spawn "walker" "-m" "desktopapplications";
              hotkey-overlay = {title = "Toggle the application launcher.";};
            };
            "Mod+C" = {
              action = spawn "walker" "-m" "clipboard";
              hotkey-overlay = {title = "Show clipboard history.";};
            };
            "Mod+Escape" = {
              action = spawn "${sessionMenu}/bin/rofi-menu-Session";
              hotkey-overlay = {title = "Toggle the session menu.";};
            };
            "Mod+W" = {
              action = spawn "${wallpaperMenu}/bin/rofi-menu-Wallpaper";
              hotkey-overlay = {title = "Open wallpaper menu.";};
            };
            "Mod+D" = {
              action = spawn "${globalMenu}/bin/rofi-menu-Global";
              hotkey-overlay = {title = "Open global menu.";};
            };

            # Applications
            "Mod+Ctrl+W" = {
              action = spawn "waypaper";
              hotkey-overlay = {title = "Open waypaper.";};
            };
            "Mod+Shift+W" = {
              action = spawn "waypaper" "--random";
              hotkey-overlay = {title = "Select random wallpaper.";};
            };
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

            # Screenshots
            "Mod+S" = {
              action.screenshot-window = {
                write-to-disk = true;
                show-pointer = false;
              };
              hotkey-overlay = {title = "Take a screenshot of the current window.";};
            };
            "Mod+Ctrl+S" = {
              action.screenshot-screen = {
                write-to-disk = true;
                show-pointer = false;
              };
              hotkey-overlay = {title = "Take a screenshot of the current screen.";};
            };
            "Mod+Shift+S" = {
              action.screenshot = {show-pointer = false;};
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
            "Mod+Comma" = {
              action = reset-window-height;
              hotkey-overlay = {title = "Reset window height.";};
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
