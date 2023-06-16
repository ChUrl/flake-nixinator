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
        kb-layout = "us";
        kb-variant = "altgr-intl";

        monitors = {
          "HDMI-A-1" = {
            width = 2560;
            height = 1440;
            rate = 144;
            x = 1920;
            y = 0;
            scale = 1;
          };

          "HDMI-A-2" = {
            width = 1920;
            height = 1080;
            rate = 60;
            x = 0;
            y = 0;
            scale = 1;
          };
        };

        workspaces = {
          "HDMI-A-1" = [1 2 3 4 5 6 7 8 9];
          "HDMI-A-2" = [10];
        };
      };

      # audio = {
      #   enable = false;

      #   carla.enable = false;
      #   bitwig.enable = true; # TODO: Check what happens when upgrade plan ends, do I need to pin the version then?
      #   tenacity.enable = true;

      #   faust.enable = true;
      #   bottles.enable = false;
      #   yabridge.enable = true;
      #   yabridge.autoSync = true;

      #   noisesuppression = {
      #     noisetorch.enable = false;
      #     noisetorch.autostart = false;
      #     easyeffects.enable = false;
      #     easyeffects.autostart = false;
      #   };

      #   cardinal.enable = true;
      #   distrho.enable = true;
      # };

      # gaming = {
      #   enable = false;

      #   prism.enable = true;
      #   bottles.enable = false;
      #   cemu.enable = true;
      #   # TODO: Webcord
      #   # discordChromium.enable = false;
      #   # discordElectron.enable = false; # This is the nixpkgs version, prefer the one from flatpak module
      #   # dwarffortress.enable = false;

      #   steam = {
      #     enable = true;
      #     gamescope = true;
      #     adwaita = false;
      #     protonup = true;
      #   };
      # };

      waybar.monitor = "HDMI-A-1";
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
