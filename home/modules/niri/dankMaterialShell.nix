{color}: {
  enable = true;

  systemd = {
    enable = false;
    restartIfChanged = true;
  };

  # Deprecated
  # enableClipboard = true;
  # enableBrightnessControl = false;
  # enableColorPicker = true;
  # enableSystemSound = false;

  enableSystemMonitoring = true;
  enableVPN = true;
  enableDynamicTheming = false;
  enableAudioWavelength = true;
  enableCalendarEvents = false;

  niri = {
    enableKeybinds = false;
    enableSpawn = false;
  };

  # This is generated from the DMS settings dialog.
  # Run: nix eval --impure --expr 'builtins.fromJSON (builtins.readFile ~/.config/DankMaterialShell/settings.json)'
  settings = {
    # Bar
    barConfigs = [
      {
        # Widgets
        leftWidgets = [
          {
            enabled = true;
            id = "launcherButton";
          }
          {
            enabled = true;
            id = "workspaceSwitcher";
          }
          {
            enabled = true;
            focusedWindowCompactMode = true;
            id = "focusedWindow";
          }
        ];
        centerWidgets = [
          {
            enabled = true;
            id = "music";
            mediaSize = 1;
          }
        ];
        rightWidgets = [
          {
            enabled = true;
            id = "cpuUsage";
            minimumWidth = true;
          }
          {
            enabled = true;
            id = "memUsage";
            minimumWidth = true;
          }
          {
            enabled = true;
            id = "diskUsage";
          }
          {
            enabled = true;
            id = "clipboard";
          }
          {
            enabled = true;
            id = "controlCenterButton";
          }
          {
            enabled = true;
            id = "systemTray";
          }
          {
            clockCompactMode = true;
            enabled = true;
            id = "clock";
          }
          {
            enabled = true;
            id = "notificationButton";
          }
        ];

        enabled = true;
        id = "default";
        name = "Main Bar";

        # Behavior
        autoHide = false;
        autoHideDelay = 250;
        maximizeDetection = true;
        openOnOverview = false;

        # Border
        borderColor = "surfaceText";
        borderEnabled = false;
        borderOpacity = 1;
        borderThickness = 2;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        gothCornersEnabled = false;

        # Styling
        position = 0;
        fontScale = 1.1;
        bottomGap = 0;
        innerPadding = 4;
        noBackground = false;
        popupGapsAuto = true;
        popupGapsManual = 4;
        spacing = 0;
        transparency = 1;
        widgetOutlineColor = "primary";
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 2;
        widgetTransparency = 1;
        squareCorners = true;
        screenPreferences = ["all"];
        showOnLastDisplay = true;
        visible = true;
      }
    ];

    # Power saving
    acLockTimeout = 0;
    acMonitorTimeout = 0;
    acProfileName = "";
    acSuspendBehavior = 0;
    acSuspendTimeout = 0;

    animationSpeed = 1;

    # Launcher
    appLauncherGridColumns = 4;
    appLauncherViewMode = "list";
    launchPrefix = "";
    launcherLogoBrightness = 0.5;
    launcherLogoColorInvertOnMode = false;
    launcherLogoColorOverride = "";
    launcherLogoContrast = 1;
    launcherLogoCustomPath = "";
    launcherLogoMode = "os";
    launcherLogoSizeOffset = 0;

    # Audio
    audioInputDevicePins = {};
    audioOutputDevicePins = {};
    audioVisualizerEnabled = true;

    # Battery
    batteryLockTimeout = 0;
    batteryMonitorTimeout = 0;
    batteryProfileName = "";
    batterySuspendBehavior = 0;
    batterySuspendTimeout = 0;

    # Wallpaper
    blurWallpaperOnOverview = true;
    blurredWallpaperLayer = false;
    wallpaperFillMode = "Fill";

    # Control center
    controlCenterShowAudioIcon = true;
    controlCenterShowBatteryIcon = false;
    controlCenterShowBluetoothIcon = true;
    controlCenterShowBrightnessIcon = false;
    controlCenterShowMicIcon = true;
    controlCenterShowNetworkIcon = true;
    controlCenterShowPrinterIcon = false;
    controlCenterShowVpnIcon = true;
    controlCenterWidgets = [
      {
        enabled = true;
        id = "volumeSlider";
        width = 50;
      }
      {
        enabled = true;
        id = "brightnessSlider";
        width = 50;
      }
      {
        enabled = true;
        id = "wifi";
        width = 50;
      }
      {
        enabled = true;
        id = "bluetooth";
        width = 50;
      }
      {
        enabled = true;
        id = "audioOutput";
        width = 50;
      }
      {
        enabled = true;
        id = "audioInput";
        width = 50;
      }
      {
        enabled = true;
        id = "nightMode";
        width = 50;
      }
      {
        enabled = true;
        id = "darkMode";
        width = 50;
      }
    ];

    # Styling
    cornerRadius = 10;
    currentThemeName = "cat-mauve";
    customAnimationDuration = 500;
    fontFamily = "MonoLisa Normal";
    monoFontFamily = "MonoLisa Normal";
    fontScale = 1;
    fontWeight = 500;
    gtkThemingEnabled = false;
    iconTheme = "System Default";

    # Lock
    fadeToLockEnabled = true;
    fadeToLockGracePeriod = 5;
    lockBeforeSuspend = false;
    lockDateFormat = "yyyy-MM-dd";
    lockScreenActiveMonitor = "all";
    lockScreenInactiveColor = "#000000";
    lockScreenShowDate = true;
    lockScreenShowPasswordField = true;
    lockScreenShowPowerActions = true;
    lockScreenShowProfileImage = true;
    lockScreenShowSystemIcons = true;
    lockScreenShowTime = true;
    loginctlLockIntegration = true;

    # Notifications
    notificationOverlayEnabled = false;
    notificationPopupPosition = 0;
    notificationTimeoutCritical = 0;
    notificationTimeoutLow = 5000;
    notificationTimeoutNormal = 5000;

    # OSD
    osdAlwaysShowValue = true;
    osdAudioOutputEnabled = true;
    osdBrightnessEnabled = true;
    osdCapsLockEnabled = true;
    osdIdleInhibitorEnabled = true;
    osdMediaVolumeEnabled = true;
    osdMicMuteEnabled = true;
    osdPosition = 7;
    osdPowerProfileEnabled = false;
    osdVolumeEnabled = true;

    # Power menu
    powerActionConfirm = true;
    powerActionHoldDuration = 0.5;
    powerMenuActions = ["reboot" "logout" "poweroff" "lock" "restart"];
    powerMenuDefaultAction = "poweroff";
    powerMenuGridLayout = false;

    # Settings
    focusedWindowCompactMode = false;
    hideBrightnessSlider = false;
    keyboardLayoutNameCompactMode = false;
    modalDarkenBackground = true;
    nightModeEnabled = false;
    niriOverviewOverlayEnabled = true;
    showBattery = false;
    showCapsLockIndicator = false;
    showClipboard = true;
    showClock = true;
    showControlCenterButton = true;
    showCpuTemp = true;
    showCpuUsage = true;
    showDock = false;
    showFocusedWindow = true;
    showGpuTemp = false;
    showLauncherButton = true;
    showMemUsage = true;
    showMusic = true;
    showNotificationButton = true;
    showOccupiedWorkspacesOnly = false;
    showPrivacyButton = false;
    showSystemTray = true;
    showWorkspaceApps = false;
    showWorkspaceIndex = false;
    showWorkspacePadding = false;
    showWorkspaceSwitcher = true;
    soundNewNotification = true;
    soundPluggedIn = true;
    soundVolumeChanged = true;
    soundsEnabled = false;

    # Launcher
    sortAppsAlphabetically = false;
    spotlightCloseNiriOverview = true;
    spotlightModalViewMode = "list";

    # Clock
    use24HourClock = true;
    showSeconds = true;
    clockCompactMode = false;
    clockDateFormat = "yyyy-MM-dd";

    # Media
    waveProgressEnabled = true;
    scrollTitleEnabled = true;

    # Weather
    showWeather = true;
    useFahrenheit = false;
    useAutoLocation = false;
    weatherCoordinates = "51.5142273,7.4652789";
    weatherEnabled = true;
    weatherLocation = "Dortmund, Nordrhein-Westfalen";

    # Workspaces
    workspaceNameIcons = {};
    workspaceScrolling = false;
    workspacesPerMonitor = true;

    # Dock
    dockAutoHide = false;
    dockBorderColor = "surfaceText";
    dockBorderEnabled = false;
    dockBorderOpacity = 1;
    dockBorderThickness = 1;
    dockBottomGap = 0;
    dockGroupByApp = false;
    dockIconSize = 40;
    dockIndicatorStyle = "circle";
    dockMargin = 0;
    dockOpenOnOverview = false;
    dockPosition = 1;
    dockSpacing = 4;
    dockTransparency = 1;

    # Random shit
    widgetBackgroundColor = "sc";
    widgetColorMode = "default";
    wifiNetworkPins = {};
    brightnessDevicePins = {};
    bluetoothDevicePins = {};
    centeringMode = "index";
    useSystemSoundTheme = false;
    vpnLastConnected = "";
    syncModeWithPortal = true;
    terminalsAlwaysDark = false;
    updaterCustomCommand = "";
    updaterTerminalAdditionalParams = "";
    updaterUseCustomCommand = false;
    showOnLastDisplay = {};
    dwlShowAllTags = false;
    enableFprint = false;
    enabledGpuPciIds = [];
    customPowerActionHibernate = "";
    customPowerActionLock = "";
    customPowerActionLogout = "";
    customPowerActionPowerOff = "";
    customPowerActionReboot = "";
    customPowerActionSuspend = "";
    customThemeFile = "";
    displayNameMode = "system";
    matugenScheme = "scheme-tonal-spot";
    matugenTargetMonitor = "";
    matugenTemplateAlacritty = true;
    matugenTemplateDgop = true;
    matugenTemplateFirefox = true;
    matugenTemplateFoot = true;
    matugenTemplateGhostty = true;
    matugenTemplateGtk = true;
    matugenTemplateKcolorscheme = true;
    matugenTemplateKitty = true;
    matugenTemplateNiri = true;
    matugenTemplatePywalfox = true;
    matugenTemplateQt5ct = true;
    matugenTemplateQt6ct = true;
    matugenTemplateVesktop = true;
    matugenTemplateVscode = true;
    matugenTemplateWezterm = true;
    notepadFontFamily = "";
    notepadFontSize = 14;
    notepadLastCustomTransparency = 0.7;
    notepadShowLineNumbers = false;
    notepadTransparencyOverride = -1;
    notepadUseMonospace = true;
    maxFprintTries = 15;
    maxWorkspaceIcons = 3;
    mediaSize = 1;
    networkPreference = "auto";
    selectedGpuIndex = 0;
    popupTransparency = 1;
    privacyShowCameraIcon = false;
    privacyShowMicIcon = false;
    privacyShowScreenShareIcon = false;
    qtThemingEnabled = false;
    runDmsMatugenTemplates = false;
    runUserMatugenTemplates = false;
    runningAppsCompactMode = true;
    runningAppsCurrentWorkspace = false;
    runningAppsGroupByApp = false;
    screenPreferences = {};

    configVersion = 2;
  };

  session = {
    # Settings
    doNotDisturb = false;
    isLightMode = false;
    weatherHourlyDetailed = true;

    # Night
    nightModeAutoEnabled = true;
    nightModeAutoMode = "time";
    nightModeEnabled = true;
    nightModeEndHour = 6;
    nightModeEndMinute = 0;
    nightModeHighTemperature = 6500;
    nightModeLocationProvider = "";
    nightModeStartHour = 22;
    nightModeStartMinute = 0;
    nightModeTemperature = 5500;
    nightModeUseIPLocation = false;

    # Hardware
    nonNvidiaGpuTempEnabled = false;
    nvidiaGpuTempEnabled = false;
    selectedGpuIndex = 0;
    wifiDeviceOverride = "";
    enabledGpuPciIds = [];
    lastBrightnessDevice = "";

    # Wallpapers
    perModeWallpaper = false;
    perMonitorWallpaper = false;
    wallpaperCyclingEnabled = false;
    wallpaperCyclingInterval = 300;
    wallpaperCyclingMode = "interval";
    wallpaperCyclingTime = "06:00";
    wallpaperPath = "/home/christoph/NixFlake/wallpapers/Windows.jpg";
    wallpaperPathDark = "";
    wallpaperPathLight = "";
    wallpaperTransition = "iris bloom";

    # Random shit
    includedTransitions = ["fade" "wipe" "disc" "stripes" "iris bloom" "pixelate" "portal"];
    launchPrefix = "";
    latitude = 0;
    longitude = 0;
    pinnedApps = [];
    hiddenTrayIds = [];
    recentColors = [];
    showThirdPartyPlugins = true;

    # Ultra random shit
    monitorCyclingSettings = {};
    monitorWallpapers = {};
    monitorWallpapersDark = {};
    monitorWallpapersLight = {};
    brightnessExponentValues = {};
    brightnessExponentialDevices = {};
    brightnessUserSetValues = {};

    configVersion = 1;
  };
}
