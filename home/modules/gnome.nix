{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.gnome;
in {

  options.modules.gnome = {
    enable = mkEnableOpt "Gnome Desktop";
    # TODO: Add option for dash-to-dock
    extensions = mkBoolOpt false "Enable Gnome shell-extensions";

    # TODO: Add other themes, whitesur for example
    theme = {
      papirusIcons = mkBoolOpt false "Enable the Papirus icon theme";
      numixCursor = mkBoolOpt false "Enable the Numix cursor theme";
      wallpaper = mkOption {
        type = types.str;
        default = "constructionsite";
        description = "What wallpaper to use";
      };
    };

    settings = {
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.services.xserver.desktopManager.gnome.enable;
        message = "Can't enable Gnome module when Gnome is not enabled!";
      }
      {
        assertion = nixosConfig.programs.dconf.enable;
        message = "Can't enable Gnome module when programs.dconf is not enabled!";
      }
    ];

    gtk = mkMerge [
      { enable = true; }

      (optionalAttrs cfg.theme.papirusIcons {
        iconTheme.package = pkgs.papirus-icon-theme;
        iconTheme.name = "Papirus";
      })
    ];

    home.pointerCursor = mkMerge [
      {
        gtk.enable = true;
        x11.enable = true;
      }

      (optionalAttrs cfg.theme.numixCursor {
        package = pkgs.numix-cursor-theme;
        name = "Numix-Cursor";
      })
    ];

    home.packages = with pkgs; builtins.concatLists [
      [
        # gnome.gnome-session # Allow to start gnome from tty (sadly this is not usable, many things don't work)
        gnome.gnome-boxes # VM
        # gnome.sushi # Gnome files previews (use service, has to be added to dbus packages)
        gnome.gnome-logs # systemd log viewer
        gnome.gnome-tweaks # conflicts with nixos/hm gnome settings file sometimes, watch out what settings to change
        gnome.gnome-nettool
        gnome.simple-scan
        gnome.gnome-sound-recorder
        gnome.file-roller # archive manager
        # gnome.dconf-editor
        dconf-editor-wrapped # Sets XDG_DATA_DIRS to include all gsettings-schemas
        gsettings-desktop-schemas
        # gnome-usage # Alternative system performance monitor (gnome.gnome-system-monitor is the preinstalled one)
        # gnome-secrets # Alternative keepass database viewer
        gnome-firmware
      ]

      (optionals cfg.extensions [
        gnomeExtensions.appindicator
        gnomeExtensions.auto-activities
        gnomeExtensions.blur-my-shell
        gnomeExtensions.custom-hot-corners-extended
        gnomeExtensions.extensions-sync
        gnomeExtensions.gamemode
        gnomeExtensions.launch-new-instance
        gnomeExtensions.maximize-to-empty-workspace
        gnomeExtensions.no-overview
        gnomeExtensions.pip-on-top
        gnomeExtensions.rounded-window-corners
        gnomeExtensions.sound-output-device-chooser
        gnomeExtensions.tweaks-in-system-menu
        gnomeExtensions.vitals
      ])
    ];

    # TODO: Check what gnome-tweaks sets
    dconf.settings = with lib.hm.gvariant; {
      # TODO: Connect with audio.easyeffects settings
      "com/github/wwmm/easyeffects" = {
        process-all-inputs = true;
        process-all-outputs = true;
        shutdown-on-window-close = false;
      };

      "com/github/wwmm/easyeffects/spectrum" = {
        show = false;
      };

      "org/gnome/boxes" = {
        view = "list-view";
      };

      "org/gnome/calculator" = {
        accuracy = 2;
        angle-units = "radians";
        base = 10;
        button-mode = "programming";
        number-format = "scientific";
        show-thousands = true;
        show-zeroes = false;
        word-size = 64;
      };

      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.home.homeDirectory}/NixFlake/config/wallpaper/${cfg.theme.wallpaper}.jpg";
        picture-uri-dark = "file://${config.home.homeDirectory}/NixFlake/config/wallpaper/${cfg.theme.wallpaper}.jpg";
      };

      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
      };

      "org/gnome/desktop/datetime" = {
        automatic-timezone = true;
      };

      "org/gnome/desktop/file-sharing" = {
        require-password = "never";
      };

      "org/gnome/desktop/interface" = {
        clock-format = "24h";
        clock-show-date = true;
        clock-show-seconds = false;
        clock-show-weekday = true;
        # cursor-size, cursor-theme set by home-manager
        document-font-name = "Source Han Sans 11";
        enable-hot-corners = false; # TODO: Make dependent on if extended hot corners extension is installed
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        font-name = "Source Han Sans 11";
        # gtk-theme, icon-theme set by home-manager
        monospace-font-name = "Source Han Mono 10";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        middle-click-emulation = true;
        # TODO: Check natural-scroll (I can't remember which is which)
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/privacy" = {
        old-files-age = 7;
        recent-files-max-age = 7;
        remove-old-temp-files = true;
        remove-old-trash-files = true;
        report-technical-problems = false;
        send-software-usage-stats = false;
      };

      "org/gnome/desktop/screensaver" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.home.homeDirectory}/NixFlake/config/wallpaper/${cfg.theme.wallpaper}.jpg";
      };

      # TODO: "org/gnome/desktop/wm/keybindings" = {};

      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "toggle-shade";
        button-layout = "appmenu:minimize,maximize,close";
        focus-mode = "click";
        mouse-button-modifier = "<Alt>";
        resize-with-right-button = true;
        # theme set by home-manager
        titlebar-font = "Source Han Sans Bold 11";
      };

      # TODO: Revisit after Gnome 43 update
      "org/gnome/epiphany" = {
        ask-for-default = false;
        default-search-engine = "Google";
        homepage-url = "about:newtab";
        use-google-search-suggestions = true;
      };

      "org/gnome/epiphany/web" = {
        remember-passwords = false;
      };

      "org/gnome/mutter" = {
        attach-modal-dialogs = true;
        dynamic-workspaces = true;
        edge-tiling = true;
        experimental-features = [
          "autoclose-xwayland"
          "rt-scheduler"
          "scale-monitor-framebuffer"
        ];
      };

      "org/gnome/nautilus/icon-view" = {
        captions = [ "size" "date_modified" "none" ];
        default-zoom-level = "larger";
      };

      "org/gnome/nautilus/list-view" = {
        use-tree-view = true;
      };

      "org/gnome/nautilus/preferences" = {
        always-use-locateion-entry = true;
        click-policy = "double";
        default-folder-viewer = "list-view";
        search-view = "list-view";
        show-create-link = true;
        show-delete-permanently = true;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = 4700;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "interactive";
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell" = {
        always-show-log-out = true;
        disable-user-extensions = false;
        disabled-extensions = [
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "apps-menu@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
        enabled-extensions = with pkgs; builtins.concatLists [
          [
            "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          ]

          (optionals cfg.extensions [
            gnomeExtensions.appindicator.extensionUuid
            gnomeExtensions.auto-activities.extensionUuid
            gnomeExtensions.blur-my-shell.extensionUuid
            gnomeExtensions.custom-hot-corners-extended.extensionUuid
            gnomeExtensions.extensions-sync.extensionUuid
            gnomeExtensions.gamemode.extensionUuid
            gnomeExtensions.launch-new-instance.extensionUuid
            gnomeExtensions.maximize-to-empty-workspace.extensionUuid
            gnomeExtensions.no-overview.extensionUuid
            gnomeExtensions.pip-on-top.extensionUuid
            gnomeExtensions.rounded-window-corners.extensionUuid
            gnomeExtensions.sound-output-device-chooser.extensionUuid
            gnomeExtensions.tweaks-in-system-menu.extensionUuid
            gnomeExtensions.vitals.extensionUuid
          ])
        ];
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };

      "org/gnome/shell/extensions/blur-my-shell" = {
        brightness = 0.5;
        noise-amount = 0;
        sigma = 15;
      };

      "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
        blur = true;
      };

      "org/gnome/shell/extensions/blur-my-shell/panel" = {
        blur = true;
        customize = false;
        unblur-dynamically = true;
      };

      "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-top-left-0" = {
        action = "toggle-overview";
      };

      "org/gnome/shell/extensions/extension-sync" = {
        github-gist-id = "e6054442efa04732fe9998cb1b8fb53c";
      };

      "org/gnome/shell/extensions/vitals" = {
        fixed-widths = true;
        hide-icons = false;
        hide-zeros = false;
        hot-sensors = [ "__network-rx_max__" ];
        position-in-panel = 2;
        show-battery = false;
        show-fan = false;
        show-storage = false;
        show-voltage = false;
        use-higher-precision = false;
      };

      # TODO: "org/gnome/shell/keybindings" = {};

      # NOTE: Some duplicates from mutter
      "org/gnome/shell/overrides" = {
        attach-modal-dialogs = true;
        dynamic-workspaces = true;
        edge-tiling = true;
      };

      "org/gnome/software" = {
        allow-updates = true;
        download-updates = false;
        download-updates-notify = true;
      };

      "org/gnome/system/location" = {
        enabled = true;
      };

      "org/gnome/TextEditor" = {
        auto-indent = true;
        custom-font = "Victor Mono Semi-Bold 11";
        highlight-current-line = true;
        indent-style = "space";
        show-gird = false;
        show-line-numbers = true;
        show-map = true;
        show-right-margin = false;
        tab-width = 4;
        use-system-font = false;
        wrap-text = false;
      };

      "system/proxy" = {
        mode = "none";
      };
    };
  };
}
