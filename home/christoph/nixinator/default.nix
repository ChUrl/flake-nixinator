{
  inputs,
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# Here goes the stuff that will only be enabled on the desktop
rec {
  imports = [
    ../../modules
  ];

  config = {
    modules = {
      hyprland = {
        enable = true;
        theme = "Three-Bears";

        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = ''
          # See https://wiki.hyprland.org/Configuring/Monitors/
          monitor = HDMI-A-1, 2560x1440@144, 1920x0, 1
          monitor = HDMI-A-2, 1920x1080@60, 0x0, 1

          # I have the first 9 workspaces on the main monitor, the last one on the secondary monitor
          workspace = 1, monitor:HDMI-A-1
          workspace = 2, monitor:HDMI-A-1
          workspace = 3, monitor:HDMI-A-1
          workspace = 4, monitor:HDMI-A-1
          workspace = 5, monitor:HDMI-A-1
          workspace = 6, monitor:HDMI-A-1
          workspace = 7, monitor:HDMI-A-1
          workspace = 8, monitor:HDMI-A-1
          workspace = 9, monitor:HDMI-A-1
          workspace = 10, monitor:HDMI-A-2
        '';
      };

      audio = {
        enable = false;

        carla.enable = false;
        bitwig.enable = true; # TODO: Check what happens when upgrade plan ends, do I need to pin the version then?
        tenacity.enable = true;

        faust.enable = true;
        bottles.enable = false;
        yabridge.enable = true;
        yabridge.autoSync = true;

        noisesuppression = {
          noisetorch.enable = false;
          noisetorch.autostart = false;
          easyeffects.enable = false;
          easyeffects.autostart = false;
        };

        cardinal.enable = true;
        distrho.enable = true;
      };

      gaming = {
        enable = true;

        prism.enable = true;
        bottles.enable = false;
        cemu.enable = true;
        # TODO: Webcord
        # discordChromium.enable = false;
        # discordElectron.enable = false; # This is the nixpkgs version, prefer the one from flatpak module
        # dwarffortress.enable = false;

        steam = {
          enable = true;
          gamescope = true;
          adwaita = true;
          protonup = true;
        };
      };
    };

    home.packages = with pkgs; [
      quartus-prime-lite # Intel FPGA design software
    ];

    # NOTE: This has been relocated here from the default config, because it forces en-US keyboard layout
    #       The laptop needs de-DE...
    # Chinese Input
    # i18n.inputMethod.enabled = "fcitx5";
    # i18n.inputMethod.fcitx5.addons = with pkgs; [
    #   fcitx5-gtk
    #   libsForQt5.fcitx5-qt
    #   fcitx5-chinese-addons
    #   fcitx5-configtool # TODO: Remove this and set config through HomeManager
    # ];
  };
}
