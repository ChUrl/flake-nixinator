# TODO: The keys to reset the workspaces need to depend on actual workspace config
{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  nixosConfig,
  ...
}: let
  inherit (config.modules) hyprland color waybar;

  # This function is mapped to the "cfg.monitors" attrSet.
  # For each key-value entry in "cfg.monitors",
  # the key will be assigned to "name" and the value to "conf".
  mkMonitor = name: conf: "${name}, ${toString conf.width}x${toString conf.height}@${toString conf.rate}, ${toString conf.x}x${toString conf.y}, ${toString conf.scale}";

  mkWorkspace = monitor: workspace: "${toString workspace}, monitor:${toString monitor}";
  mkWorkspaces = monitor: workspace-list: map (mkWorkspace monitor) workspace-list;

  mkWorkspaceRule = workspace: class: "workspace ${workspace}, class:^(${class})$";
  mkWorkspaceRules = workspace: class-list: builtins.map (mkWorkspaceRule workspace) class-list;

  mkFloatingRule = attrs:
    "float"
    + (lib.optionalString (builtins.hasAttr "class" attrs) ", class:^(${attrs.class})$")
    + (lib.optionalString (builtins.hasAttr "title" attrs) ", title:^(${attrs.title})$");

  mkTranslucentRule = class: "opacity ${hyprland.transparent-opacity} ${hyprland.transparent-opacity}, class:^(${class})$";

  mkBind = key: action: "${key}, ${action}";
  mkBinds = key: actions: builtins.map (mkBind key) actions;

  # These functions are used to generate the keybindings.info file for Rofi
  fixupNoMod = key: ''${builtins.replaceStrings ["<-"] ["<"] key}'';
  mkBindHelpKey = key: ''${builtins.replaceStrings ["$mainMod" " " ","] ["${hyprland.keybindings.main-mod}" "-" ""] key}'';
  mkBindHelpAction = action: ''${builtins.replaceStrings [","] [""] action}'';
  mkBindHelp = key: action: "<${mkBindHelpKey key}>: ${mkBindHelpAction action}";
  mkBindsHelp = key: actions: builtins.map fixupNoMod (builtins.map (mkBindHelp key) actions);

  mkWallpaper = monitor: "${monitor}, ${config.home.homeDirectory}/NixFlake/wallpapers/${hyprland.theme}.png";

  mkDelayedStart = str: "hyprctl dispatch exec \"sleep 5s && ${str}\"";
  delayed-exec = builtins.map mkDelayedStart hyprland.autostart.delayed;
  mkExec = prog: "${prog}";

  always-bind = {
    # Hyprland control
    "$mainMod, A" = ["exec, rofi -drun-show-actions -show drun"];
    "$mainMod, Q" = ["killactive"];
    "$mainMod, V" = ["togglefloating"];
    "$mainMod, F" = ["fullscreen"];
    "$mainMod, C" = ["exec, clipman pick --tool=rofi"];
    "$mainMod, G" = ["togglegroup"];
    "$mainMod, L" = ["exec, loginctl lock-session"];
    "ALT, tab" = ["changegroupactive"];
    "$mainMod, tab" = ["workspace, previous"];

    # Move focus with mainMod + arrow keys
    "$mainMod, h" = ["movefocus, l"];
    "$mainMod, l" = ["movefocus, r"];
    "$mainMod, k" = ["movefocus, u"];
    "$mainMod, j" = ["movefocus, d"];

    # Swap windows
    "$mainMod CTRL, h" = ["movewindow, l"];
    "$mainMod CTRL, l" = ["movewindow, r"];
    "$mainMod CTRL, k" = ["movewindow, u"];
    "$mainMod CTRL, d" = ["movewindow, d"];

    # TODO: Somehow write this more compact? Try to use workspace 0 instead of 10...
    "$mainMod, 1" = ["workspace, 1"];
    "$mainMod, 2" = ["workspace, 2"];
    "$mainMod, 3" = ["workspace, 3"];
    "$mainMod, 4" = ["workspace, 4"];
    "$mainMod, 5" = ["workspace, 5"];
    "$mainMod, 6" = ["workspace, 6"];
    "$mainMod, 7" = ["workspace, 7"];
    "$mainMod, 8" = ["workspace, 8"];
    "$mainMod, 9" = ["workspace, 9"];
    "$mainMod, 0" = ["workspace, 10"];
    "$mainMod, x" = ["togglespecialworkspace"];

    "$mainMod SHIFT, 1" = ["movetoworkspace, 1"];
    "$mainMod SHIFT, 2" = ["movetoworkspace, 2"];
    "$mainMod SHIFT, 3" = ["movetoworkspace, 3"];
    "$mainMod SHIFT, 4" = ["movetoworkspace, 4"];
    "$mainMod SHIFT, 5" = ["movetoworkspace, 5"];
    "$mainMod SHIFT, 6" = ["movetoworkspace, 6"];
    "$mainMod SHIFT, 7" = ["movetoworkspace, 7"];
    "$mainMod SHIFT, 8" = ["movetoworkspace, 8"];
    "$mainMod SHIFT, 9" = ["movetoworkspace, 9"];
    "$mainMod SHIFT, 0" = ["movetoworkspace, 10"];
    "$mainMod SHIFT, x" = ["movetoworkspace, special"];

    # Reset workspaces to the defined configuration in hyprland.workspaces:
    # [
    #   "moveworkspacetomonitor, 1 HDMI-A-1"
    #   "moveworkspacetomonitor, 2 HDMI-A-1"
    #   ...
    # ]
    "CTRL ALT, R" = let
      mkWorkspaceBinding = monitor: workspace: "moveworkspacetomonitor, ${builtins.toString workspace} ${builtins.toString monitor}";
      mkWorkspacesBindings = monitor: workspaces: builtins.map (mkWorkspaceBinding monitor) workspaces;
    in
      builtins.concatLists (builtins.attrValues (builtins.mapAttrs mkWorkspacesBindings hyprland.workspaces));
  };

  always-bindm = {
    "$mainMod, mouse:272" = ["movewindow"];
    "$mainMod, mouse:273" = ["resizewindow"];
  };

  always-exec = builtins.concatLists [
    (lib.optionals hyprland.dunst.enable ["dunst"]) # Notifications
    [
      "wl-paste -t text --watch clipman store --no-persist"
      "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""
      "hyprctl setcursor Bibata-Modern-Classic 16"
      "hyprsunset --identity"

      # HACK: Hyprland doesn't set the xwayland/x11 keymap correctly
      "setxkbmap -layout ${hyprland.kb-layout} -variant ${hyprland.kb-variant} -model pc104"

      # HACK: Flatpak doesn't find applications in the system PATH
      "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"

      # Provide a polkit authentication UI.
      # This is used for example when running systemd commands without root.
      # "systemctl --user start hyprpolkitagent.service"
      # "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    ]
  ];
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf hyprland.enable {
    # Some assertion is not possible if HM is used standalone,
    # because nixosConfig won't be available.
    assertions = [
      {
        assertion = nixosConfig.programs.hyprland.enable;
        message = "Can't enable Hyprland module with Hyprland disabled!";
      }
      {
        assertion = builtins.hasAttr "hyprlock" nixosConfig.security.pam.services;
        message = "Can't enable Hyprland module without Hyprlock PAM service!";
      }
    ];

    gtk = {
      enable = true;
      iconTheme.package = pkgs.papirus-icon-theme;
      iconTheme.name = "Papirus";
    };

    home = {
      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      packages = with pkgs; [
        hyprpaper # Wallpaper setter
        hyprpicker # Color picker
        # hyprpolkitagent # Ugly polkit authentication GUI
        hyprland-qt-support
        hyprsunset # Blue light filter

        wl-clipboard
        clipman # Clipboard manager (wl-paste)
        libnotify
        inotifyTools # Includes inotifywait

        ncpamixer # Audio control
        slurp # Region selector for screensharing
        grim # Grab images from compositor

        # Deps for Qt5 and Qt6 apps (e.g., Nextcloud)
        qt5.qtwayland
        qt6.qtwayland
      ];

      file = {
        ".config/hypr/keybindings.info".text =
          lib.pipe
          (hyprland.keybindings.bindings // always-bind)
          [
            (builtins.mapAttrs mkBindsHelp)
            builtins.attrValues
            builtins.concatLists
            (builtins.concatStringsSep "\n")
          ];
      };
    };

    programs = {
      imv = {
        enable = true;
        settings = {
          options = {
            background = "${color.hex.dark.text}";
            overlay = true;
            overlay_font = "${color.font}:12";
            overlay_text_color = "${color.hex.dark.text}";
            overlay_background_color = "${color.hex.dark.base}";
          };
        };
      };

      hyprlock = {
        enable = true;

        settings = {
          general = {
            disable_loading_bar = true;
            grace = 0; # Immediately lock
            hide_cursor = true;
            no_fade_in = false;
          };

          # The widgets start here.

          background = [
            {
              path = "~/NixFlake/wallpapers/${hyprland.theme}.png";
              blur_passes = 3;
              blur_size = 10;
              monitor = "";
            }
          ];

          input-field = [
            # Password input
            {
              size = "200, 50";
              position = "0, 0";
              monitor = "";
              dots_center = true;
              fade_on_empty = false;
              font_color = "rgb(${color.hex.dark.base})";
              font_family = "${color.font}";
              inner_color = "rgb(${color.hex.dark.lavender})";
              outer_color = "rgb(${color.hex.dark.base})";
              outline_thickness = 2;
              placeholder_text = "<span foreground='\#\#${color.hex.dark.base}'>Password...</span>";
              shadow_passes = 0;
              rounding = 5;
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            # Date
            {
              position = "0, 300";
              monitor = "";
              text = ''cmd[update:1000] date -I'';
              color = "rgba(${color.hex.dark.text}AA)";
              font_size = 22;
              font_family = "${color.font}";
              halign = "center";
              valign = "center";
            }

            # Time
            {
              position = "0, 200";
              monitor = "";
              text = ''cmd[update:1000] date +"%-H:%M"'';
              color = "rgba(${color.hex.dark.text}AA)";
              font_size = 95;
              font_family = "${color.font} Extrabold";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };

    services = {
      hyprpaper = {
        enable = true;

        settings = {
          ipc = "on";
          splash = false;
          splash_offset = 2.0;

          preload = "~/NixFlake/wallpapers/${hyprland.theme}.png";
          wallpaper = lib.pipe hyprland.monitors [
            builtins.attrNames
            (builtins.map mkWallpaper)
          ];
        };
      };

      hypridle = {
        enable = true;

        settings = {
          general = {
            # DPMS - Display Powermanagement Signaling. "On" means the monitor is on.
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };

          listener = [
            {
              timeout = 900;
              on-timeout = "hyprlock";
            }
            {
              timeout = 1200;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };

      # Notification service
      dunst = {
        enable = hyprland.dunst.enable;

        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus";

        settings = {
          global = {
            monitor = waybar.monitor;
            font = "${color.font} 11";
            offset = "10x10";
            background = "#${color.hex.light.base}";
            foreground = "#${color.hex.light.text}";
            frame_width = 2;
            corner_radius = 5;
            separator_color = "frame";
          };

          urgency_low = {
            frame_color = "#${color.hex.light.green}";
          };

          urgency_normal = {
            frame_color = "#${color.hex.light.green}";
          };

          urgency_critical = {
            frame_color = "#${color.hex.light.red}";
          };
        };
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true; # Enable hyprland-session.target
      systemd.variables = ["--all"]; # Import PATH into systemd
      xwayland.enable = true;

      plugins = [
        # TODO: Takes ages (compiles all hyprland dependencies locally...)
        #       Probably have to use hyprland flake to follow...

        # inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
        # inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
      ];

      settings = {
        "$mainMod" = "${hyprland.keybindings.main-mod}";

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;

          "col.active_border" = "rgb(${color.hex.dark.lavender})";
          "col.inactive_border" = "rgba(${color.hex.dark.base}AA)";
        };

        group = {
          groupbar = {
            enabled = true;
            render_titles = false;
            font_size = 10;
            gradients = false;

            "col.active" = "rgb(${color.hex.dark.lavender})";
            "col.inactive" = "rgba(${color.hex.dark.base}AA)";
          };

          "col.border_active" = "rgb(${color.hex.dark.lavender})";
          "col.border_inactive" = "rgba(${color.hex.dark.base}AA)";
        };

        input = {
          kb_layout = "${hyprland.kb-layout}";
          kb_variant = "${hyprland.kb-variant}";
          kb_model = "pc104";
          kb_options = "";
          kb_rules = "";

          follow_mouse = true;

          touchpad = {
            natural_scroll = "no";
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        monitor = lib.pipe hyprland.monitors [
          (builtins.mapAttrs mkMonitor)
          builtins.attrValues
        ];

        workspace = lib.pipe hyprland.workspaces [
          (builtins.mapAttrs mkWorkspaces)
          builtins.attrValues
          builtins.concatLists
        ];

        bind = lib.pipe (hyprland.keybindings.bindings
          // always-bind) [
          (builtins.mapAttrs mkBinds)
          builtins.attrValues
          builtins.concatLists
        ];

        bindm = lib.pipe always-bindm [
          (builtins.mapAttrs mkBinds)
          builtins.attrValues
          builtins.concatLists
        ];

        exec-once = lib.pipe (always-exec ++ hyprland.autostart.immediate ++ delayed-exec) [
          (builtins.map mkExec)
        ];

        windowrule =
          lib.pipe hyprland.workspacerules [
            (builtins.mapAttrs mkWorkspaceRules)
            builtins.attrValues
            builtins.concatLists
          ]
          ++ lib.pipe hyprland.floating [
            (builtins.map mkFloatingRule)
          ]
          ++ lib.pipe hyprland.transparent [
            (builtins.map mkTranslucentRule)
          ]
          ++ hyprland.windowrules;

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        gestures = {
          workspace_swipe = false;
        };

        misc = {
          # Say no to the anime girl
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;

          # Say no to the "Application not responding" window
          enable_anr_dialog = false;

          disable_splash_rendering = true;
          font_family = "${color.font}";
        };

        # Because those are not windows, but layers,
        # we have to blur them explicitly
        layerrule = [
          "blur,rofi"
          "ignorealpha 0.001,rofi"
          "dimaround,rofi"

          "blur,waybar"
          "blur,gtk4-layer-shell"
          "blur,bar-0"
          "blur,bar-1"
        ];

        decoration = {
          rounding = 5;

          shadow = {
            enabled = false;
          };

          blur = {
            enabled = true;
            size = 10;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
            xray = true;
          };
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default,popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
      };
    };
  };
}
