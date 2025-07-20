{
  lib,
  mylib,
  ...
}: rec {
  enable = lib.mkEnableOption "Hyprland Window Manager + Compositor";

  kb-layout = lib.mkOption {
    type = lib.types.str;
    example = "us";
    description = "Keyboard layout to use";
  };

  kb-variant = lib.mkOption {
    type = lib.types.str;
    example = "altgr-intl";
    description = "Keyboard layout variant";
  };

  # A bit dumb, but I want a single location where those are defined.
  # Only supposed to be set from here.
  wallpapers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Available wallpapers";

    # Run eza -1 | sd ".jpg" "" | sd "^" "\"" | sd "\$" "\"" | sd "\"\"" "" | wl-copy
    # in ~/NixFlake/wallpapers/
    default = [
      "Blade-Runner-Downwards"
      "Blade-Runner-Upwards"
      "City-Outlook"
      "Everest-Fishing"
      "Foggy-Lake"
      "Three-Bears"
    ];
  };

  wallpaper = lib.mkOption {
    type = lib.types.enum wallpapers.default;
    example = "Three-Bears";
    description = "Wallpaper to use";
    default = "Foggy-Lake";
  };

  dunst.enable = lib.mkEnableOption "Enable dunst notification daemon";

  monitors = lib.mkOption {
    type = lib.types.attrs;
    description = "Hyprland Monitor Configurations";
    example = ''
      {
        "HDMI-A-1" = {
          width = 2560;
          height = 1440;
          rate = 144;
          x = 1920;
          y = 0;
          scale = 1;
        }
      }
    '';
  };

  workspaces = lib.mkOption {
    type = lib.types.attrs;
    description = "How workspaces are distributed to monitors. These monitors will also receive a wallpaper.";
    example = ''
      {
        "HDMI-A-1" = [1 2 3 4 5 6 7 8 9];
        "HDMI-A-2" = [0];
      }
    '';
  };

  autostart = {
    immediate = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Programs to launch when Hyprland starts";
      example = ''
        [
          "kitty"
        ]
      '';
      default = [];
    };

    delayed = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Programs to launch with a delay when Hyprland starts (e.g. to wait for the waybar tray)";
      example = ''
        [
          "keepassxc"
          "nextcloud --background"
        ]
      '';
      default = [];
    };

    special-silent = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      description = "Programs to silently launch on special workspaces";
      example = ''
        {
          "ferdium" = ["ferdium"];
          "btop" = ["kitty --title=Btop btop"];
        }
      '';
      default = {};
    };
  };

  workspacerules = lib.mkOption {
    type = lib.types.attrs;
    description = "Launch programs on specified workspaces, accepts window class.";
    example = ''
      {
        "2" = [
          "jetbrains-clion"
          "code-url-handler"
        ];
      }
    '';
  };

  windowrules = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Specify specific window rules.";
    example = ''
      [
        "suppressevent activate, class: Unity"
      ]
    '';
  };

  transparent-opacity = lib.mkOption {
    type = lib.types.str;
    description = "The opacity transparent windows should have.";
    example = "0.8";
  };

  floating = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    description = "What programs are floating down here?";
    example = ''
      [
        {
          class = "thunar";
          title = "File Operation Progress";
        }
        {
          class = "org.kde.polkit-kde-authentication-agent-1";
        }
      ]
    '';
  };

  transparent = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "What programs should be transparent? Accepts window class.";
    example = ''
      [
        "kitty"
      ]
    '';
  };

  keybindings = {
    main-mod = lib.mkOption {
      type = lib.types.str;
      description = "Main modifier key";
      example = ''
        "SUPER"
      '';
      default = "SUPER";
    };

    bindings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      description = "Hyprland keyboard shortcuts";
      default = {};
      example = ''
        {
          "CTRL ALT, R" = [
            "moveworkspacetomonitor, 1 HDMI-A-1"
            "moveworkspacetomonitor, 2 HDMI-A-1"
          ];
        }
      '';
    };

    ws-bindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Map keys to workspaces";
      default = {};
      example = ''
        {
          # "<Workspace>" = "<Key>";
          "1" = "1";
          "10" = "0";
        }
      '';
    };

    special-ws-bindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Map keys to special (scratchpad) workspaces";
      default = {};
      example = ''
        {
          # "<Workspace>" = "<Key>";
          "ferdium" = "x";
          "btop" = "b";
        }
      '';
    };
  };
}
