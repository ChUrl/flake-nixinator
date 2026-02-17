{
  config,
  color,
}: {
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
    acLockTimeout = 0;
    acMonitorTimeout = 0;
    acProfileName = "";
    acSuspendBehavior = 0;
    acSuspendTimeout = 0;
    activeDisplayProfile = {};
    animationSpeed = 1;
    appDrawerSectionViewModes = {};
    appIdSubstitutions = [
      {
        pattern = "Spotify";
        replacement = "spotify";
        type = "exact";
      }
      {
        pattern = "beepertexts";
        replacement = "beeper";
        type = "exact";
      }
      {
        pattern = "home assistant desktop";
        replacement = "homeassistant-desktop";
        type = "exact";
      }
      {
        pattern = "com.transmissionbt.transmission";
        replacement = "transmission-gtk";
        type = "contains";
      }
      {
        pattern = "^steam_app_(\\d+)$";
        replacement = "steam_icon_$1";
        type = "regex";
      }
    ];
    appLauncherGridColumns = 4;
    appLauncherViewMode = "list";
    appPickerViewMode = "grid";
    appsDockActiveColorMode = "primary";
    appsDockColorizeActive = false;
    appsDockEnlargeOnHover = false;
    appsDockEnlargePercentage = 125;
    appsDockHideIndicators = false;
    appsDockIconSizePercentage = 100;
    audioInputDevicePins = {};
    audioOutputDevicePins = {};
    audioScrollMode = "volume";
    audioVisualizerEnabled = true;
    audioWheelScrollAmount = 5;
    barConfigs = [
      {
        autoHide = false;
        autoHideDelay = 250;
        borderColor = "surfaceText";
        borderEnabled = false;
        borderOpacity = 1;
        borderThickness = 2;
        bottomGap = 0;
        centerWidgets = [
          {
            enabled = true;
            id = "music";
            mediaSize = 1;
          }
        ];
        enabled = true;
        fontScale = 1.1;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        gothCornersEnabled = false;
        id = "default";
        innerPadding = 4;
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
        maximizeDetection = true;
        name = "Main Bar";
        noBackground = false;
        openOnOverview = true;
        popupGapsAuto = true;
        popupGapsManual = 4;
        position = 0;
        rightWidgets = [
          {
            enabled = true;
            id = "privacyIndicator";
          }
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
            id = "colorPicker";
          }
          {
            enabled = true;
            id = "clipboard";
          }
          {
            enabled = true;
            id = "vpn";
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
        screenPreferences = ["all"];
        showOnLastDisplay = true;
        spacing = 0;
        squareCorners = true;
        transparency = 1;
        visible = true;
        widgetOutlineColor = "primary";
        widgetOutlineEnabled = false;
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 2;
        widgetTransparency = 1;
      }
    ];
    barMaxVisibleApps = 0;
    barMaxVisibleRunningApps = 0;
    barShowOverflowBadge = true;
    batteryChargeLimit = 100;
    batteryLockTimeout = 0;
    batteryMonitorTimeout = 0;
    batteryProfileName = "";
    batterySuspendBehavior = 0;
    batterySuspendTimeout = 0;
    bluetoothDevicePins = {};
    blurWallpaperOnOverview = true;
    blurredWallpaperLayer = true;
    brightnessDevicePins = {};
    browserPickerViewMode = "grid";
    browserUsageHistory = {};
    builtInPluginSettings = {dms_settings_search = {trigger = "?";};};
    buttonColorMode = "primary";
    centeringMode = "index";
    clipboardEnterToPaste = false;
    clockCompactMode = false;
    clockDateFormat = "yyyy-MM-dd";
    configVersion = 5;
    controlCenterShowAudioIcon = true;
    controlCenterShowAudioPercent = false;
    controlCenterShowBatteryIcon = false;
    controlCenterShowBluetoothIcon = true;
    controlCenterShowBrightnessIcon = false;
    controlCenterShowBrightnessPercent = false;
    controlCenterShowMicIcon = true;
    controlCenterShowMicPercent = false;
    controlCenterShowNetworkIcon = true;
    controlCenterShowPrinterIcon = false;
    controlCenterShowScreenSharingIcon = true;
    controlCenterShowVpnIcon = true;
    controlCenterTileColorMode = "primary";
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
    cornerRadius = 10;
    currentThemeCategory = "registry";
    currentThemeName = "custom";
    cursorSettings = {
      dwl = {cursorHideTimeout = 0;};
      hyprland = {
        hideOnKeyPress = false;
        hideOnTouch = false;
        inactiveTimeout = 0;
      };
      niri = {
        hideAfterInactiveMs = 0;
        hideWhenTyping = false;
      };
      size = 24;
      theme = "System Default";
    };
    customAnimationDuration = 500;
    customPowerActionHibernate = "";
    customPowerActionLock = "";
    customPowerActionLogout = "";
    customPowerActionPowerOff = "";
    customPowerActionReboot = "";
    customPowerActionSuspend = "";
    customThemeFile = "/home/christoph/NixFlake/config/dankmaterialshell/catppuccin-mauve.json";
    dankLauncherV2BorderColor = "primary";
    dankLauncherV2BorderEnabled = false;
    dankLauncherV2BorderThickness = 2;
    dankLauncherV2ShowFooter = true;
    dankLauncherV2Size = "compact";
    dankLauncherV2UnloadOnClose = false;
    desktopClockColorMode = "primary";
    desktopClockCustomColor = {
      a = 1;
      b = 1;
      g = 1;
      hslHue = -1;
      hslLightness = 1;
      hslSaturation = 0;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      r = 1;
      valid = true;
    };
    desktopClockDisplayPreferences = ["all"];
    desktopClockEnabled = false;
    desktopClockHeight = 180;
    desktopClockShowAnalogNumbers = false;
    desktopClockShowAnalogSeconds = true;
    desktopClockShowDate = true;
    desktopClockStyle = "analog";
    desktopClockTransparency = 0.8;
    desktopClockWidth = 280;
    desktopClockX = -1;
    desktopClockY = -1;
    desktopWidgetGridSettings = {};
    desktopWidgetGroups = [];
    desktopWidgetInstances = [];
    desktopWidgetPositions = {};
    displayNameMode = "system";
    displayProfileAutoSelect = false;
    displayProfiles = {};
    displayShowDisconnected = false;
    displaySnapToEdge = true;
    dockAutoHide = false;
    dockBorderColor = "surfaceText";
    dockBorderEnabled = false;
    dockBorderOpacity = 1;
    dockBorderThickness = 1;
    dockBottomGap = 0;
    dockGroupByApp = false;
    dockIconSize = 40;
    dockIndicatorStyle = "circle";
    dockIsolateDisplays = false;
    dockLauncherEnabled = false;
    dockLauncherLogoBrightness = 0.5;
    dockLauncherLogoColorOverride = "";
    dockLauncherLogoContrast = 1;
    dockLauncherLogoCustomPath = "";
    dockLauncherLogoMode = "apps";
    dockLauncherLogoSizeOffset = 0;
    dockMargin = 0;
    dockMaxVisibleApps = 0;
    dockMaxVisibleRunningApps = 0;
    dockOpenOnOverview = false;
    dockPosition = 1;
    dockShowOverflowBadge = true;
    dockSmartAutoHide = false;
    dockSpacing = 4;
    dockTransparency = 1;
    dwlShowAllTags = false;
    enableFprint = false;
    enableRippleEffects = true;
    enabledGpuPciIds = [];
    fadeToDpmsEnabled = true;
    fadeToDpmsGracePeriod = 5;
    fadeToLockEnabled = true;
    fadeToLockGracePeriod = 5;
    filePickerUsageHistory = {};
    focusedWindowCompactMode = false;
    fontFamily = "MonoLisa Normal";
    fontScale = 1;
    fontWeight = 500;
    groupWorkspaceApps = true;
    gtkThemingEnabled = false;
    hideBrightnessSlider = false;
    hyprlandLayoutBorderSize = -1;
    hyprlandLayoutGapsOverride = -1;
    hyprlandLayoutRadiusOverride = -1;
    hyprlandOutputSettings = {};
    iconTheme = "System Default";
    keyboardLayoutNameCompactMode = false;
    launchPrefix = "";
    launcherLogoBrightness = 0.5;
    launcherLogoColorInvertOnMode = false;
    launcherLogoColorOverride = "";
    launcherLogoContrast = 1;
    launcherLogoCustomPath = "";
    launcherLogoMode = "os";
    launcherLogoSizeOffset = 0;
    launcherPluginOrder = [];
    launcherPluginVisibility = {};
    lockAtStartup = false;
    lockBeforeSuspend = false;
    lockDateFormat = "yyyy-MM-dd";
    lockScreenActiveMonitor = "all";
    lockScreenInactiveColor = "#000000";
    lockScreenNotificationMode = 0;
    lockScreenPowerOffMonitorsOnLock = false;
    lockScreenShowDate = true;
    lockScreenShowMediaPlayer = true;
    lockScreenShowPasswordField = true;
    lockScreenShowPowerActions = true;
    lockScreenShowProfileImage = true;
    lockScreenShowSystemIcons = true;
    lockScreenShowTime = true;
    loginctlLockIntegration = true;
    mangoLayoutBorderSize = -1;
    mangoLayoutGapsOverride = -1;
    mangoLayoutRadiusOverride = -1;
    matugenScheme = "scheme-tonal-spot";
    matugenTargetMonitor = "";
    matugenTemplateAlacritty = true;
    matugenTemplateDgop = true;
    matugenTemplateEmacs = true;
    matugenTemplateEquibop = true;
    matugenTemplateFirefox = true;
    matugenTemplateFoot = true;
    matugenTemplateGhostty = true;
    matugenTemplateGtk = true;
    matugenTemplateHyprland = true;
    matugenTemplateKcolorscheme = true;
    matugenTemplateKitty = true;
    matugenTemplateMangowc = true;
    matugenTemplateNeovim = true;
    matugenTemplateNiri = true;
    matugenTemplatePywalfox = true;
    matugenTemplateQt5ct = true;
    matugenTemplateQt6ct = true;
    matugenTemplateVesktop = true;
    matugenTemplateVscode = true;
    matugenTemplateWezterm = true;
    matugenTemplateZenBrowser = true;
    maxFprintTries = 15;
    maxWorkspaceIcons = 3;
    mediaSize = 1;
    modalAnimationSpeed = 1;
    modalCustomAnimationDuration = 150;
    modalDarkenBackground = true;
    monoFontFamily = "MonoLisa Normal";
    networkPreference = "auto";
    nightModeEnabled = false;
    niriLayoutBorderSize = -1;
    niriLayoutGapsOverride = -1;
    niriLayoutRadiusOverride = -1;
    niriOutputSettings = {};
    niriOverviewOverlayEnabled = true;
    notepadFontFamily = "";
    notepadFontSize = 14;
    notepadLastCustomTransparency = 0.7;
    notepadShowLineNumbers = false;
    notepadTransparencyOverride = -1;
    notepadUseMonospace = true;
    notificationAnimationSpeed = 1;
    notificationCompactMode = false;
    notificationCustomAnimationDuration = 400;
    notificationHistoryEnabled = true;
    notificationHistoryMaxAgeDays = 7;
    notificationHistoryMaxCount = 50;
    notificationHistorySaveCritical = true;
    notificationHistorySaveLow = true;
    notificationHistorySaveNormal = true;
    notificationOverlayEnabled = false;
    notificationPopupPosition = 0;
    notificationPopupPrivacyMode = false;
    notificationPopupShadowEnabled = true;
    notificationRules = [];
    notificationTimeoutCritical = 0;
    notificationTimeoutLow = 5000;
    notificationTimeoutNormal = 5000;
    osdAlwaysShowValue = true;
    osdAudioOutputEnabled = true;
    osdBrightnessEnabled = true;
    osdCapsLockEnabled = true;
    osdIdleInhibitorEnabled = true;
    osdMediaPlaybackEnabled = true;
    osdMediaVolumeEnabled = true;
    osdMicMuteEnabled = true;
    osdPosition = 7;
    osdPowerProfileEnabled = false;
    osdVolumeEnabled = true;
    padHours12Hour = false;
    popoutAnimationSpeed = 1;
    popoutCustomAnimationDuration = 150;
    popupTransparency = 1;
    powerActionConfirm = true;
    powerActionHoldDuration = 0.5;
    powerMenuActions = ["reboot" "logout" "poweroff" "lock" "restart"];
    powerMenuDefaultAction = "poweroff";
    powerMenuGridLayout = false;
    privacyShowCameraIcon = false;
    privacyShowMicIcon = false;
    privacyShowScreenShareIcon = false;
    qtThemingEnabled = false;
    registryThemeVariants = {};
    reverseScrolling = false;
    runDmsMatugenTemplates = false;
    runUserMatugenTemplates = false;
    runningAppsCompactMode = true;
    runningAppsCurrentMonitor = false;
    runningAppsCurrentWorkspace = false;
    runningAppsGroupByApp = false;
    screenPreferences = {};
    scrollTitleEnabled = true;
    selectedGpuIndex = 0;
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
    showOnLastDisplay = {};
    showPrivacyButton = false;
    showSeconds = true;
    showSystemTray = true;
    showWeather = true;
    showWorkspaceApps = false;
    showWorkspaceIndex = false;
    showWorkspaceName = false;
    showWorkspacePadding = false;
    showWorkspaceSwitcher = true;
    sortAppsAlphabetically = false;
    soundNewNotification = true;
    soundPluggedIn = true;
    soundVolumeChanged = true;
    soundsEnabled = false;
    spotlightCloseNiriOverview = true;
    spotlightModalViewMode = "list";
    spotlightSectionViewModes = {};
    syncComponentAnimationSpeeds = true;
    syncModeWithPortal = true;
    systemMonitorColorMode = "primary";
    systemMonitorCustomColor = {
      a = 1;
      b = 1;
      g = 1;
      hslHue = -1;
      hslLightness = 1;
      hslSaturation = 0;
      hsvHue = -1;
      hsvSaturation = 0;
      hsvValue = 1;
      r = 1;
      valid = true;
    };
    systemMonitorDisplayPreferences = ["all"];
    systemMonitorEnabled = false;
    systemMonitorGpuPciId = "";
    systemMonitorGraphInterval = 60;
    systemMonitorHeight = 480;
    systemMonitorLayoutMode = "auto";
    systemMonitorShowCpu = true;
    systemMonitorShowCpuGraph = true;
    systemMonitorShowCpuTemp = true;
    systemMonitorShowDisk = true;
    systemMonitorShowGpuTemp = false;
    systemMonitorShowHeader = true;
    systemMonitorShowMemory = true;
    systemMonitorShowMemoryGraph = true;
    systemMonitorShowNetwork = true;
    systemMonitorShowNetworkGraph = true;
    systemMonitorShowTopProcesses = false;
    systemMonitorTopProcessCount = 3;
    systemMonitorTopProcessSortBy = "cpu";
    systemMonitorTransparency = 0.8;
    systemMonitorVariants = [];
    systemMonitorWidth = 320;
    systemMonitorX = -1;
    systemMonitorY = -1;
    terminalsAlwaysDark = false;
    updaterCustomCommand = "";
    updaterHideWidget = false;
    updaterTerminalAdditionalParams = "";
    updaterUseCustomCommand = false;
    use24HourClock = true;
    useAutoLocation = false;
    useFahrenheit = false;
    useSystemSoundTheme = false;
    wallpaperFillMode = "Fill";
    waveProgressEnabled = true;
    weatherEnabled = true;
    widgetBackgroundColor = "sc";
    widgetColorMode = "default";
    wifiNetworkPins = {};
    windSpeedUnit = "kmh";
    workspaceAppIconSizeOffset = 0;
    workspaceColorMode = "default";
    workspaceDragReorder = true;
    workspaceFocusedBorderColor = "primary";
    workspaceFocusedBorderEnabled = false;
    workspaceFocusedBorderThickness = 2;
    workspaceFollowFocus = false;
    workspaceNameIcons = {};
    workspaceOccupiedColorMode = "none";
    workspaceScrolling = false;
    workspaceUnfocusedColorMode = "default";
    workspaceUrgentColorMode = "default";
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
