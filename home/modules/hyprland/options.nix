{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Hyprland Window Manager + Compositor";

  kb-layout = mkOption {
    type = types.str;
    example = "us";
    description = "Keyboard layout to use";
  };

  kb-variant = mkOption {
    type = types.str;
    example = "altgr-intl";
    description = "Keyboard layout variant";
  };

  theme = mkOption {
    type = types.str;
    example = "Three-Bears";
    description = "Wallpaper and colorscheme to use";
  };

  monitors = mkOption {
    type = types.attrs;
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

  workspaces = mkOption {
    type = types.attrs;
    description = "How workspaces are distributed to monitors. These monitors will also receive a wallpaper.";
    example = ''
      {
        "HDMI-A-1" = [1 2 3 4 5 6 7 8 9];
        "HDMI-A-2" = [0];
      }
    '';
  };

  autostart = mkOption {
    type = types.listOf types.str;
    description = "Programs to launch when Hyprland starts";
    example = ''
      [
        "keepassxc"
        "nextcloud --background"
      ]
    '';
  };

  workspacerules = mkOption {
    type = types.attrs;
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

  floating = mkOption {
    type = types.listOf types.attrs;
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

  transparent = mkOption {
    type = types.listOf types.str;
    description = "What programs should be transparent? Accepts window class.";
    example = ''
      [
        "kitty"
      ]
    '';
  };

  keybindings = {
    main-mod = mkOption {
      type = types.str;
      description = "Main modifier key";
      example = ''
        "SUPER"
      '';
    };

    mod-bindings = mkOption {
      type = types.attrs;
      description = "Hyprland keyboard shortcuts using the modifier key";
      example = ''
        {
          "Q" = ["killactive"];
          "V" = ["togglefloating"];
        }
      '';
    };

    bindings = mkOption {
      type = types.attrs;
      description = "Hyprland keyboard shortcuts";
      example = ''
        {
          "CTRL ALT, R" = [
            "moveworkspacetomonitor, 1 HDMI-A-1"
            "moveworkspacetomonitor, 2 HDMI-A-1"
          ];
        }
      '';
    };
  };
}
