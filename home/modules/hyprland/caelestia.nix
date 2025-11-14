{
  config,
  hyprland,
  color,
}: {
  enable = hyprland.caelestia.enable;

  systemd = {
    enable = false; # Start from hyprland autostart
    target = "graphical-session.target";
    environment = [];
  };

  settings = {
    appearance = {
      anim = {durations = {scale = 1;};};
      font = {
        family = {
          clock = "Rubik";
          material = "Material Symbols Rounded";
          mono = color.font;
          sans = color.font;
        };
        size = {scale = 1;};
      };

      padding = {scale = 1;};
      rounding = {scale = 1;};
      spacing = {scale = 1;};

      transparency = {
        base = 0.85;
        enabled = false;
        layers = 0.4;
      };
    };

    background = {
      desktopClock = {enabled = false;};
      enabled = true;

      # Lags when visible on both monitors (different refresh rates?)
      visualiser = {
        autoHide = true;
        blur = true;
        enabled = false;
        rounding = 1;
        spacing = 1;
      };
    };

    bar = {
      clock = {showIcon = true;};
      dragThreshold = 20;

      entries = [
        {
          enabled = true;
          id = "logo";
        }
        {
          enabled = true;
          id = "workspaces";
        }
        {
          enabled = true;
          id = "spacer";
        }
        {
          enabled = true;
          id = "activeWindow";
        }
        {
          enabled = true;
          id = "spacer";
        }
        {
          enabled = true;
          id = "clock";
        }
        {
          enabled = true;
          id = "tray";
        }
        {
          enabled = true;
          id = "statusIcons";
        }
        {
          enabled = true;
          id = "power";
        }
      ];

      persistent = true;

      popouts = {
        activeWindow = true;
        statusIcons = true;
        tray = true;
      };

      scrollActions = {
        brightness = false;
        volume = true;
        workspaces = true;
      };

      showOnHover = true;

      status = {
        showAudio = true;
        showBattery = false;
        showBluetooth = true;
        showKbLayout = false;
        showLockStatus = true;
        showMicrophone = false;
        showNetwork = true;
      };

      tray = {
        background = true;
        compact = false;
        iconSubs = [];
        recolour = false;
      };

      workspaces = {
        activeIndicator = true;
        activeLabel = "󰮯";
        activeTrail = true;
        label = "  ";
        occupiedBg = false;
        occupiedLabel = "󰮯";
        perMonitorWorkspaces = false;
        showWindows = false;
        shown = 10;

        # Pick them here: https://fonts.google.com/icons
        specialWorkspaceIcons = [
          {
            icon = "music_note";
            name = "rmpc";
          }
          {
            icon = "memory";
            name = "btop";
          }
          {
            icon = "mark_chat_unread";
            name = "ferdium";
          }
          {
            icon = "network_intelligence";
            name = "msty";
          }
        ];
      };
    };

    border = {
      rounding = 25;
      thickness = 10;
    };

    dashboard = {
      dragThreshold = 50;
      enabled = true;
      mediaUpdateInterval = 500;
      showOnHover = true;
    };

    general = {
      apps = {
        audio = ["kitty" "--title=NcpaMixer" "-e" "ncpamixer"];
        explorer = ["kitty" "--title=Yazi" "-e" "yazi"];
        playback = ["mpv"];
        terminal = ["kitty"];
      };

      battery = {
        criticalLevel = 3;
        warnLevels = [
          {
            icon = "battery_android_frame_2";
            level = 20;
            message = "You might want to plug in a charger";
            title = "Low battery";
          }
          {
            icon = "battery_android_frame_1";
            level = 10;
            message = "You should probably plug in a charger <b>now</b>";
            title = "Did you see the previous message?";
          }
          {
            critical = true;
            icon = "battery_android_alert";
            level = 5;
            message = "PLUG THE CHARGER RIGHT NOW!!";
            title = "Critical battery level";
          }
        ];
      };

      idle = {
        inhibitWhenAudio = true;
        lockBeforeSleep = true;
        timeouts = [
          {
            idleAction = "lock";
            timeout = 600;
          }
          {
            # idleAction = "dpms off";
            # returnAction = "dpms on";
            idleAction = "echo 'idle'";
            returnAction = "echo 'return'";
            timeout = 10000;
          }
          {
            # idleAction = ["systemctl" "suspend-then-hibernate"];
            idleAction = ["echo" "'idle'"];
            timeout = 20000;
          }
        ];
      };
    };

    launcher = {
      actionPrefix = ">";
      actions = [
        {
          command = ["autocomplete" "calc"];
          dangerous = false;
          description = "Do simple math equations (powered by Qalc)";
          enabled = true;
          icon = "calculate";
          name = "Calculator";
        }
        {
          command = ["autocomplete" "scheme"];
          dangerous = false;
          description = "Change the current colour scheme";
          enabled = true;
          icon = "palette";
          name = "Scheme";
        }
        {
          command = ["autocomplete" "wallpaper"];
          dangerous = false;
          description = "Change the current wallpaper";
          enabled = true;
          icon = "image";
          name = "Wallpaper";
        }
        {
          command = ["autocomplete" "variant"];
          dangerous = false;
          description = "Change the current scheme variant";
          enabled = true;
          icon = "colors";
          name = "Variant";
        }
        {
          command = ["autocomplete" "transparency"];
          dangerous = false;
          description = "Change shell transparency";
          enabled = false;
          icon = "opacity";
          name = "Transparency";
        }
        {
          command = ["caelestia" "wallpaper" "-r"];
          dangerous = false;
          description = "Switch to a random wallpaper";
          enabled = false;
          icon = "casino";
          name = "Random";
        }
        {
          command = ["setMode" "light"];
          dangerous = false;
          description = "Change the scheme to light mode";
          enabled = true;
          icon = "light_mode";
          name = "Light";
        }
        {
          command = ["setMode" "dark"];
          dangerous = false;
          description = "Change the scheme to dark mode";
          enabled = true;
          icon = "dark_mode";
          name = "Dark";
        }
        {
          command = ["systemctl" "poweroff"];
          dangerous = true;
          description = "Shutdown the system";
          enabled = true;
          icon = "power_settings_new";
          name = "Shutdown";
        }
        {
          command = ["systemctl" "reboot"];
          dangerous = true;
          description = "Reboot the system";
          enabled = true;
          icon = "cached";
          name = "Reboot";
        }
        {
          command = ["loginctl" "terminate-user" ""];
          dangerous = true;
          description = "Log out of the current session";
          enabled = true;
          icon = "exit_to_app";
          name = "Logout";
        }
        {
          command = ["loginctl" "lock-session"];
          dangerous = false;
          description = "Lock the current session";
          enabled = true;
          icon = "lock";
          name = "Lock";
        }
        {
          command = ["systemctl" "suspend-then-hibernate"];
          dangerous = false;
          description = "Suspend then hibernate";
          enabled = false;
          icon = "bedtime";
          name = "Sleep";
        }
      ];

      dragThreshold = 50;
      enableDangerousActions = true;
      hiddenApps = [];
      maxShown = 7;
      maxWallpapers = 9;
      showOnHover = false;
      specialPrefix = "@";
      useFuzzy = {
        actions = false;
        apps = false;
        schemes = false;
        variants = false;
        wallpapers = false;
      };
      vimKeybinds = false;
    };

    lock = {recolourLogo = false;};

    notifs = {
      actionOnClick = false;
      clearThreshold = 0.3;
      defaultExpireTimeout = 5000;
      expandThreshold = 20;
      expire = true;
    };

    osd = {
      enableBrightness = false;
      enableMicrophone = true;
      enabled = true;
      hideDelay = 2000;
    };

    paths = {
      mediaGif = "root:/assets/bongocat.gif";
      sessionGif = "root:/assets/kurukuru.gif";
      wallpaperDir = "~/NixFlake/wallpapers";
    };

    services = {
      audioIncrement = 0.1;
      defaultPlayer = "MPD";
      gpuType = "";
      maxVolume = 1;
      playerAliases = [
        {
          from = "com.github.th_ch.youtube_music";
          to = "YT Music";
        }
      ];
      smartScheme = true;
      useFahrenheit = false;
      useTwelveHourClock = false;
      visualiserBars = 45;
      weatherLocation = "Dortmund, Germany";
    };

    session = {
      commands = {
        hibernate = ["systemctl" "hibernate"];
        logout = ["loginctl" "terminate-user" ""];
        reboot = ["systemctl" "reboot"];
        shutdown = ["systemctl" "poweroff"];
      };
      dragThreshold = 30;
      enabled = true;
      vimKeybinds = false;
    };

    sidebar = {
      dragThreshold = 80;
      enabled = true;
    };

    utilities = {
      enabled = true;
      maxToasts = 4;
      toasts = {
        audioInputChanged = true;
        audioOutputChanged = true;
        capsLockChanged = true;
        chargingChanged = true;
        configLoaded = true;
        dndChanged = true;
        gameModeChanged = true;
        kbLayoutChanged = false;
        nowPlaying = false;
        numLockChanged = true;
        vpnChanged = true;
      };

      vpn = {
        enabled = false;
        provider = [
          {
            displayName = "Wireguard (Your VPN)";
            interface = "your-connection-name";
            name = "wireguard";
          }
        ];
      };
    };
  };

  cli = {
    enable = hyprland.caelestia.enable;

    settings = {
      record = {extraArgs = [];};

      theme = {
        enableBtop = false;
        enableDiscord = false;
        enableFuzzel = false;
        enableGtk = false;
        enableHypr = false;
        enableQt = false;
        enableSpicetify = false;
        enableTerm = false;
      };

      toggles = {
        communication = {
          discord = {
            command = ["discord"];
            enable = false;
            match = [{class = "discord";}];
            move = true;
          };
          whatsapp = {
            enable = false;
            match = [{class = "whatsapp";}];
            move = true;
          };
        };

        music = {
          feishin = {
            enable = false;
            match = [{class = "feishin";}];
            move = true;
          };
          spotify = {
            command = ["spicetify" "watch" "-s"];
            enable = false;
            match = [{class = "Spotify";} {initialTitle = "Spotify";} {initialTitle = "Spotify Free";}];
            move = true;
          };
        };

        sysmon = {
          btop = {
            command = ["kitty" "--title" "Btop" "-e" "btop"];
            enable = false;
            match = [
              {
                class = "btop";
                title = "Btop";
                workspace = {name = "special:sysmon";};
              }
            ];
          };
        };

        todo = {
          todoist = {
            command = ["todoist"];
            enable = false;
            match = [{class = "Todoist";}];
            move = true;
          };
        };
      };
      wallpaper = {postHook = "echo $WALLPAPER_PATH";};
    };
  };
}
