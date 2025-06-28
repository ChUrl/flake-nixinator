# Here goes the stuff that will only be enabled on the desktop
{
  pkgs,
  nixosConfig,
  config,
  lib,
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

    home = let
      # Extra config to make Rider Unity integration work
      dotnetCore = with pkgs.dotnetCorePackages;
        combinePackages [
          # sdk_6_0_1xx # Is EOL
          # sdk_7_0_3xx # Is EOL
          sdk_8_0_3xx
          sdk_9_0_3xx
        ];

      extra-path = with pkgs; [
        dotnetCore
        dotnetPackages.Nuget
        mono
        # msbuild

        # Add any extra binaries you want accessible to Rider here
      ];

      extra-lib = with pkgs; [
        # Add any extra libraries you want accessible to Rider here
      ];

      rider = pkgs.jetbrains.rider.overrideAttrs (attrs: {
        postInstall =
          ''
            # Wrap rider with extra tools and libraries
            mv $out/bin/rider $out/bin/.rider-toolless
            makeWrapper $out/bin/.rider-toolless $out/bin/rider \
              --argv0 rider \
              --prefix PATH : "${lib.makeBinPath extra-path}" \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath extra-lib}"

            # Making Unity Rider plugin work!
            # The plugin expects the binary to be at /rider/bin/rider,
            # with bundled files at /rider/
            # It does this by going up two directories from the binary path
            # Our rider binary is at $out/bin/rider, so we need to link $out/rider/ to $out/
            shopt -s extglob
            ln -s $out/rider/!(bin) $out/
            shopt -u extglob
          ''
          + attrs.postInstall or "";
      });
    in {
      packages = with pkgs; [
        # quartus-prime-lite # Intel FPGA design software

        # Don't want heavy IDE's on the laptop
        jetbrains.clion
        jetbrains.rust-rover
        jetbrains.pycharm-professional
        # jetbrains.idea-ultimate
        # jetbrains.webstorm

        # Unity Stuff
        # unityhub # TODO: Disable until https://github.com/NixOS/nixpkgs/issues/418451 is closed
        rider
        dotnetCore
        mono

        blender
        godot_4
        obs-studio
        kdePackages.kdenlive
        krita
        makemkv

        steam-devices-udev-rules
      ];

      file = {
        ".local/share/applications/jetbrains-rider.desktop".source = let
          desktopFile = pkgs.makeDesktopItem {
            name = "jetbrains-rider";
            desktopName = "Rider";
            exec = "\"${rider}/bin/rider\"";
            icon = "rider";
            type = "Application";
            # Don't show desktop icon in search or run launcher
            extraConfig.NoDisplay = "true";
          };
        in "${desktopFile}/share/applications/jetbrains-rider.desktop";

        ".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source = ../../../config/mangohud/MangoHud.conf;

        # ".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.dotfiles}/mangohud/MangoHud.conf";
      };
    };

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
