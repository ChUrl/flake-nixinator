# Here goes the stuff that will only be enabled on the desktop
{
  pkgs,
  nixosConfig,
  config,
  ...
}: {
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

          "DP-1" = {
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
          "DP-1" = [10];
        };

        autostart = {
          delayed = [
            "fcitx5"
          ];
        };

        floating = [
          {
            class = "fcitx";
          }
        ];
      };

      waybar.monitor = "HDMI-A-1";
    };

    home.packages = with pkgs; [
      # quartus-prime-lite # Intel FPGA design software

      # Don't want heavy IDE's on the laptop
      jetbrains.clion
      jetbrains.rust-rover
      jetbrains.pycharm-professional
      jetbrains.idea-ultimate
      jetbrains.webstorm

      unityhub
      jetbrains.rider
      (with dotnetCorePackages;
        combinePackages [
          # sdk_6_0_1xx # Is EOL
          # sdk_7_0_3xx # Is EOL
          sdk_8_0_3xx
          sdk_9_0_3xx
        ]) # For Rider/Unity
      mono # For Rider/Unity

      blender
      # godot_4
      obs-studio
      kdePackages.kdenlive
      krita
      makemkv

      steam-devices-udev-rules
    ];

    # home.file.".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.dotfiles}/mangohud/MangoHud.conf";
    home.file.".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source = ../../../config/mangohud/MangoHud.conf;

    services = {
      flatpak = {
        packages = [
          "com.valvesoftware.Steam"
          "com.valvesoftware.Steam.Utility.steamtinkerlaunch"
          "net.davidotek.pupgui2"

          "org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08"
          "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"

          "org.prismlauncher.PrismLauncher"
          "com.usebottles.bottles"
          "io.github.lawstorant.boxflat"
        ];

        overrides = {
          "com.valvesoftware.Steam".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Games"

              # This is Proton-GE installed from flatpak. ProtonUpQT doesn't require it.
              "/var/lib/flatpak/runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
            ];
          };

          "net.davidotek.pupgui2".Context = {
            filesystems = [
              "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam"
              "${config.home.homeDirectory}/Games"
            ];
          };

          "com.usebottles.bottles".Context = {
            filesystems = [
              "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam"
              "${config.home.homeDirectory}/Games"
            ];
          };
        };
      };
    };
  };
}
