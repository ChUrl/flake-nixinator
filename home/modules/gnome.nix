{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.gnome;
in {

  options.modules.gnome = {
    enable = mkEnableOpt "Gnome Desktop";
    extensions = mkBoolOpt false "Enable Gnome shell-extensions";

    # TODO: Add other themes, whitesur for example
    theme = {
      papirusIcons = mkBoolOpt false "Enable the Papirus icon theme";
      numixCursor = mkBoolOpt false "Enable the Numix cursor theme";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.services.xserver.desktopManager.gnome.enable;
        message = "Can't enable Gnome module when Gnome is not enabled!";
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

    # TODO: GSettings overrides (home-manager dconf.settings)

    home.packages = with pkgs; builtins.concatLists [
      [
        # gnome.gnome-session # Allow to start gnome from tty (sadly this is not usable, many things don't work)
        gnome.gnome-boxes # VM
        gnome.sushi # Gnome files previews
        gnome.gnome-logs # systemd log viewer
        gnome.gnome-tweaks # conflicts with nixos/hm gnome settings file sometimes, watch out what settings to change
        gnome.gnome-nettool
        gnome.simple-scan
        gnome.gnome-sound-recorder
        gnome.file-roller # archive manager
        gnome.dconf-editor
        # gnome-usage # Alternative system performance monitor (gnome.gnome-system-monitor is the preinstalled one)
        # gnome-secrets # Alternative keepass database viewer
        gnome-firmware
      ]

      (optionals cfg.extensions [
        gnomeExtensions.appindicator
        gnomeExtensions.blur-my-shell
        gnomeExtensions.sound-output-device-chooser
        gnomeExtensions.vitals
        gnomeExtensions.no-overview
        # gnomeExtensions.switch-workspace
        gnomeExtensions.maximize-to-empty-workspace
        gnomeExtensions.pip-on-top
        gnomeExtensions.custom-hot-corners-extended
        # gnomeExtensions.dock-from-dash
        gnomeExtensions.gamemode
        # gnomeExtensions.gsconnect # kde connect alternative
        # gnomeExtensions.quake-mode # dropdown for any application
        # gnomeExtensions.systemd-manager # to quickly start nextcloud
        gnomeExtensions.extensions-sync
        gnomeExtensions.tweaks-in-system-menu
        # gnomeExtensions.compiz-windows-effect # WobBlY wiNdoWS
        gnomeExtensions.panel-scroll
        gnomeExtensions.rounded-window-corners
        # gnomeExtensions.easyeffects-preset-selector # Throws error com.sth could not be found, dbus problem?
        gnomeExtensions.launch-new-instance
        gnomeExtensions.auto-activities
      ])
    ];
  };
}
