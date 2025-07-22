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

  # Autostart programs
  always-exec = import ./autostart.nix {inherit lib pkgs config hyprland;};

  # Keybindings
  always-bind = import ./mappings.nix {inherit lib config hyprland;};

  # Mousebindings
  always-bindm = {
    "$mainMod, mouse:272" = ["movewindow"];
    "$mainMod, mouse:273" = ["resizewindow"];
  };
in {
  options.modules.hyprland = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf hyprland.enable {
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
      hyprlock = import ./hyprlock.nix {inherit config hyprland color;};

      # TODO: IMV shouldn't be part of the hyprland module
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
    };

    services = {
      # TODO: Dunst shouldn't be part of the hyprland module
      dunst = import ./dunst.nix {inherit pkgs config hyprland color;};
      hypridle = import ./hypridle.nix {inherit config hyprland color;};
      hyprpaper = import ./hyprpaper.nix {inherit config hyprland color;};
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

      systemd.enable = true; # Enable hyprland-session.target
      systemd.variables = ["--all"]; # Import PATH into systemd
      xwayland.enable = true;

      plugins = [
        inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
        inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
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
