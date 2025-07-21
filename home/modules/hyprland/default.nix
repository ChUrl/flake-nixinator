{
  inputs,
  config,
  lib,
  mylib,
  pkgs,
  nixosConfig,
  username,
  ...
}: let
  inherit (config.modules) hyprland color;

  always-bind = lib.mergeAttrsList [
    {
      # Hyprland control
      "$mainMod, a" = ["exec, rofi -drun-show-actions -show drun"];
      "$mainMod, q" = ["killactive"];
      "$mainMod, v" = ["togglefloating"];
      "$mainMod, f" = ["fullscreen"];
      "$mainMod, c" = ["exec, clipman pick --tool=rofi"];
      "$mainMod SHIFT, l" = ["exec, loginctl lock-session"];
      "$mainMod, tab" = ["workspace, previous"];
      "ALT, tab" = ["exec, rofi -show window"];
      # "$mainMod, g" = ["togglegroup"];
      # "ALT, tab" = ["changegroupactive"];

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

      # Reset workspaces to the defined configuration in hyprland.workspaces:
      "CTRL ALT, r" = let
        mkWBinding = m: w:
          "moveworkspacetomonitor, "
          + "${builtins.toString w} ${builtins.toString m}";
        mkWsBindings = m: ws: builtins.map (mkWBinding m) ws;
      in
        hyprland.workspaces
        |> builtins.mapAttrs mkWsBindings
        |> builtins.attrValues
        |> builtins.concatLists;
    }

    # Switch to WS: "$mainMod, 1" = ["workspace, 1"];
    (let
      mkWBinding = w: k: {"$mainMod, ${k}" = ["workspace, ${w}"];};
    in
      hyprland.keybindings.ws-bindings
      |> builtins.mapAttrs mkWBinding
      |> builtins.attrValues
      |> lib.mergeAttrsList)

    # Toggle special WS: "$mainMod, x" = ["togglespecialworkspace, ferdium"];
    (let
      mkSpecialWBinding = w: k: {"$mainMod, ${k}" = ["togglespecialworkspace, ${w}"];};
    in
      hyprland.keybindings.special-ws-bindings
      |> builtins.mapAttrs mkSpecialWBinding
      |> builtins.attrValues
      |> lib.mergeAttrsList)

    # Move to WS: "$mainMod SHIFT, 1" = ["movetoworkspace, 1"];
    (let
      mkMoveWBinding = w: k: {"$mainMod SHIFT, ${k}" = ["movetoworkspace, ${w}"];};
    in
      (hyprland.keybindings.ws-bindings)
      |> builtins.mapAttrs mkMoveWBinding
      |> builtins.attrValues
      |> lib.mergeAttrsList)

    # Move to special WS: "$mainMod SHIFT, x" = ["movetoworkspace, special:ferdium"];
    (let
      mkSpecialMoveWBinding = w: k: {"$mainMod SHIFT, ${k}" = ["movetoworkspace, special:${w}"];};
    in
      (hyprland.keybindings.special-ws-bindings)
      |> builtins.mapAttrs mkSpecialMoveWBinding
      |> builtins.attrValues
      |> lib.mergeAttrsList)
  ];

  always-bindm = {
    "$mainMod, mouse:272" = ["movewindow"];
    "$mainMod, mouse:273" = ["resizewindow"];
  };

  always-exec = builtins.concatLists [
    (lib.optionals hyprland.dunst.enable ["dunst"]) # Notifications
    [
      # Start clipboard management
      "wl-paste -t text --watch clipman store --no-persist"
      "wl-paste -p -t text --watch clipman store -P --histpath=\"~/.local/share/clipman-primary.json\""

      "hyprctl setcursor Bibata-Modern-Classic 16"
      "hyprsunset --identity"

      # HACK: Hyprland doesn't set the xwayland/x11 keymap correctly
      "setxkbmap -layout ${hyprland.keyboard.layout} -variant ${hyprland.keyboard.variant} -option ${hyprland.keyboard.option} -model pc104"

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
        ".config/hypr/keybindings.info".text = let
          fixupHomeDir = key:
            builtins.replaceStrings ["/home/${username}"] ["~"] key;

          fixupNixStore = key: let
            # The pattern has to match the entire string, otherwise it won't work
            matches = builtins.match ".*/nix/store/(.*)/.*" key;
          in
            if (matches == null)
            then key
            else builtins.replaceStrings matches ["..."] key;

          fixupNoMod = key:
            builtins.replaceStrings ["<-"] ["<"] key;

          mkBindHelpKey = key:
            builtins.replaceStrings ["$mainMod" " " ","] ["${hyprland.keybindings.main-mod}" "-" ""] key;

          mkBindHelpAction = action:
            builtins.replaceStrings [","] [""] action;

          mkBindHelp = key: action: "<${mkBindHelpKey key}>: ${mkBindHelpAction action}";

          mkBindsHelp = key: actions:
            actions
            |> builtins.map (mkBindHelp key)
            |> builtins.map fixupNoMod
            |> builtins.map fixupNixStore
            |> builtins.map fixupHomeDir;
        in
          (hyprland.keybindings.bindings // always-bind)
          |> builtins.mapAttrs mkBindsHelp
          |> builtins.attrValues
          |> builtins.concatLists
          |> builtins.concatStringsSep "\n";
      };
    };

    programs = {
      imv = {
        enable = true;
        settings = {
          options = {
            background = "${color.hex.base}";
            overlay = true;
            overlay_font = "${color.font}:12";
            overlay_background_color = "${color.hex.accent}";
            overlay_text_color = "${color.hex.accentText}";
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
              path = "${config.paths.nixflake}/wallpapers/${color.wallpaper}.jpg";
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
              font_color = "rgb(${color.hex.accentText})";
              font_family = "${color.font}";
              inner_color = "rgb(${color.hex.accent})";
              outer_color = "rgb(${color.hex.accent})";
              outline_thickness = 2;
              placeholder_text = "<span foreground='\#\#${color.hex.accentText}'>Password...</span>";
              shadow_passes = 0;
              rounding = 4;
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
              color = "rgba(${color.hex.text}AA)";
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
              color = "rgba(${color.hex.text}AA)";
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

          # Wallpapers have to be preloaded to be displayed
          preload = let
            mkPreload = name: "${config.paths.nixflake}/wallpapers/${name}.jpg";
          in
            color.wallpapers |> builtins.map mkPreload;

          wallpaper = let
            mkWallpaper = monitor:
              "${monitor}, "
              + "${config.paths.nixflake}/wallpapers/${color.wallpaper}.jpg";
          in
            hyprland.monitors
            |> builtins.attrNames
            |> builtins.map mkWallpaper;
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
            monitor = config.modules.waybar.monitor;
            font = "${color.font} 11";
            offset = "10x10";
            background = color.hexS.base;
            foreground = color.hexS.text;
            frame_width = 2;
            corner_radius = 6;
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

          "col.active_border" = "rgb(${color.hex.accent})";
          "col.inactive_border" = "rgb(${color.hex.base})";
        };

        group = {
          groupbar = {
            enabled = true;
            render_titles = false;
            font_size = 10;
            gradients = false;

            "col.active" = "rgb(${color.hex.accent})";
            "col.inactive" = "rgb(${color.hex.base})";
          };

          "col.border_active" = "rgb(${color.hex.accent})";
          "col.border_inactive" = "rgb(${color.hex.base})";
        };

        input = {
          kb_layout = hyprland.keyboard.layout;
          kb_variant = hyprland.keyboard.variant;
          kb_options = hyprland.keyboard.option;
          kb_model = "pc104";
          kb_rules = "";

          follow_mouse = true;

          touchpad = {
            natural_scroll = "no";
          };

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        monitor = let
          mkMonitor = name: conf:
            "${name}, "
            + "${builtins.toString conf.width}x${builtins.toString conf.height}@"
            + "${builtins.toString conf.rate}, "
            + "${builtins.toString conf.x}x${builtins.toString conf.y}, "
            + "${builtins.toString conf.scale}";
        in
          hyprland.monitors
          |> builtins.mapAttrs mkMonitor
          |> builtins.attrValues;

        workspace = let
          mkWorkspace = monitor: workspace:
            "${builtins.toString workspace}, "
            + "monitor:${builtins.toString monitor}";

          mkWorkspaces = monitor: workspace-list:
            builtins.map (mkWorkspace monitor) workspace-list;
        in
          hyprland.workspaces
          |> builtins.mapAttrs mkWorkspaces
          |> builtins.attrValues
          |> builtins.concatLists;

        bind = let
          mkBind = key: action: "${key}, ${action}";
          mkBinds = key: actions: builtins.map (mkBind key) actions;
        in
          (hyprland.keybindings.bindings // always-bind)
          |> builtins.mapAttrs mkBinds
          |> builtins.attrValues
          |> builtins.concatLists;

        bindm = let
          mkBind = key: action: "${key}, ${action}";
          mkBinds = key: actions: builtins.map (mkBind key) actions;
        in
          always-bindm
          |> builtins.mapAttrs mkBinds
          |> builtins.attrValues
          |> builtins.concatLists;

        exec-once = let
          mkDelayedStart = str: ''hyprctl dispatch exec "sleep 5s && ${str}"'';

          mkSpecialSilentStart = w: str: "[workspace special:${w} silent] ${str}";
          mkSpecialSilentStarts = w: strs: builtins.map (mkSpecialSilentStart w) strs;
        in
          lib.mkMerge [
            always-exec
            hyprland.autostart.immediate
            (hyprland.autostart.special-silent
              |> builtins.mapAttrs mkSpecialSilentStarts
              |> builtins.attrValues
              |> builtins.concatLists)
            (hyprland.autostart.delayed
              |> builtins.map mkDelayedStart)
          ];

        windowrule = let
          mkWorkspaceRule = workspace: class:
            "workspace ${workspace}, "
            + "class:^(${class})$";
          mkWorkspaceRules = workspace: class-list:
            builtins.map (mkWorkspaceRule workspace) class-list;

          mkFloatingRule = attrs:
            "float"
            + (lib.optionalString (builtins.hasAttr "class" attrs) ", class:^(${attrs.class})$")
            + (lib.optionalString (builtins.hasAttr "title" attrs) ", title:^(${attrs.title})$");

          mkTranslucentRule = class:
            "opacity ${hyprland.transparent-opacity} ${hyprland.transparent-opacity}, "
            + "class:^(${class})$";
        in
          lib.mkMerge [
            (hyprland.workspacerules
              |> builtins.mapAttrs mkWorkspaceRules
              |> builtins.attrValues
              |> builtins.concatLists)
            (hyprland.floating
              |> builtins.map mkFloatingRule)
            (hyprland.transparent
              |> builtins.map mkTranslucentRule)
            hyprland.windowrules
          ];

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
          "ignorealpha 0.001,rofi" # Fix pixelated corners
          "xray 0,rofi" # Render on top of other windows
          "dimaround,rofi"

          "blur,waybar"
          "blur,gtk4-layer-shell"
          "blur,bar-0"
          "blur,bar-1"
        ];

        decoration = {
          rounding = 4;

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
