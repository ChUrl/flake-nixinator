{color}: {
  enable = true;
  settings = {
    # configure noctalia here; defaults will
    # be deep merged with these attributes.

    colorSchemes.predefinedScheme = "Catppuccin";

    general = {
      avatarImage = ../../../config/face.jpeg;
      radiusRatio = 0.2;
      showScreenCorners = false;
      forceBlackScreenCorners = false;
      dimDesktop = true;
      scaleRatio = 1;
      screenRadiusRatio = 1;
      animationSpeed = 1;
      animationDisabled = false;
      compactLockScreen = false;
      lockOnSuspend = true;
      enableShadows = true;
      shadowDirection = "bottom_right";
      shadowOffsetX = 2;
      shadowOffsetY = 3;
      language = "";
    };

    ui = {
      fontDefault = color.font;
      fontFixed = color.font;
      tooltipsEnabled = true;
      panelsAttachedToBar = true;
      settingsPanelAttachTobar = true;
      fontDefaultScale = 1;
      fontFixedScale = 1;
      settingsPanelAttachToBar = false;
    };

    location = {
      name = "Dortmund, Germany";
      monthBeforeDay = true;
      weatherEnabled = true;
      useFahrenheit = false;
      use12hourFormat = false;
      showWeekNumberInCalendar = false;
      showCalendarEvents = true;
      showCalendarWeather = true;
      analogClockInCalendar = false;
      firstDayOfWeek = -1;
    };

    screenRecorder = {
      directory = "~/Videos/Recordings";
      frameRate = 60;
      audioCodec = "aac";
      videoCodec = "h265";
      quality = "very_high";
      colorRange = "limited";
      showCursor = true;
      audioSource = "default_output";
      videoSource = "portal";
    };

    wallpaper = {
      enabled = true;
      overviewEnabled = true;
      directory = "~/NixFlake/wallpapers";
      enableMultiMonitorDirectories = false;
      recursiveSearch = false;
      setWallpaperOnAllMonitors = true;
      defaultWallpaper = ../../../wallpapers/Windows.jpg;
      fillMode = "crop";
      fillColor = "#000000";
      randomEnabled = false;
      randomIntervalSec = 300;
      transitionDuration = 1500;
      transitionType = "random";
      transitionEdgeSmoothness = 0.05;
      monitors = [];
      panelPosition = "follow_bar";
    };

    appLauncher = {
      enableClipboardHistory = true;
      position = "center";
      backgroundOpacity = 1;
      pinnedExecs = [];
      useApp2Unit = false;
      sortByMostUsed = true;
      terminalCommand = "kitty -e";
      customLaunchPrefixEnabled = false;
      customLaunchPrefix = "";
    };

    dock = {
      enabled = false;
    };

    network = {
      wifiEnabled = true;
      bluetoothEnabled = true;
    };

    notifications = {
      enabled = true;
      monitors = [];
      location = "top_right";
      overlayLayer = true;
      backgroundOpacity = 1;
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
    };

    osd = {
      enabled = true;
      location = "top_right";
      monitors = [];
      autoHideMs = 2000;
      overlayLayer = true;
    };

    audio = {
      volumeStep = 5;
      volumeOverdrive = true;
      cavaFrameRate = 30;
      visualizerType = "linear";
      visualizerQuality = "high";
      mprisBlacklist = [];
      preferredPlayer = "";
    };

    nightLight = {
      enabled = false;
      forced = false;
      autoSchedule = true;
      nightTemp = "5000";
      dayTemp = "6500";
      manualSunrise = "06:30";
      manualSunset = "21:30";
    };

    sessionMenu = {
      countdownDuration = 10000;
      enableCountdown = true;
      position = "center";
      powerOptions = [
        {
          action = "lock";
          enabled = true;
        }
        {
          action = "suspend";
          enabled = false;
        }
        {
          action = "reboot";
          enabled = true;
        }
        {
          action = "logout";
          enabled = true;
        }
        {
          action = "shutdown";
          enabled = true;
        }
      ];
      showHeader = true;
    };

    bar = {
      density = "default";
      position = "top";
      showCapsule = false;
      outerCorners = false;
      exclusive = true;
      backgroundOpacity = 1;
      monitors = [];
      floating = false;
      marginVertical = 0.25;
      marginHorizontal = 0.25;

      widgets = {
        left = [
          {
            id = "SidePanelToggle";
            useDistroLogo = true;
          }
          {
            hideUnoccupied = false;
            id = "Workspace";
            labelMode = "none";
          }
          {
            id = "ActiveWindow";
            maxWidth = 250;
          }
        ];
        center = [
          {
            id = "MediaMini";
            maxWidth = 250;
            showAlbumArt = true;
          }
          {
            id = "AudioVisualizer";
            width = 100;
            visualizerType = "mirrored";
          }
        ];
        right = [
          {
            id = "Volume";
          }
          {
            id = "Microphone";
          }
          {
            id = "WiFi";
          }
          {
            id = "Bluetooth";
          }
          {
            id = "Tray";
            drawerEnabled = false;
          }
          {
            formatHorizontal = "yyyy-MM-dd HH:mm";
            formatVertical = "HH mm";
            id = "Clock";
            useMonospacedFont = true;
            usePrimaryColor = true;
          }
          {
            id = "NotificationHistory";
          }
        ];
      };
    };
  };
}
