# Here goes the stuff that will only be enabled on the desktop
{
  pkgs,
  nixosConfig,
  config,
  lib,
  mylib,
  username,
  inputs,
  ...
}: {
  config = {
    homemodules = {
      btop.cuda = true;

      # This has been relocated here from the default config,
      # because it forces en-US keyboard layout.
      fcitx.enable = true;

      waybar.monitors = ["DP-1" "DP-2"];
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

      rider-unity = pkgs.jetbrains.rider.overrideAttrs (attrs: {
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
        # Intel FPGA design software
        # quartus-prime-lite

        jetbrains.clion
        # jetbrains.rust-rover
        # jetbrains.pycharm-professional
        # jetbrains.idea-ultimate
        # jetbrains.webstorm
        # jetbrains.rider
        zed-editor
        vscode
        # ghidra # launch with _JAVA_AWT_WM_NONREPARENTING=1 (use programs.ghidra)

        # Unity Stuff
        # unityhub
        # rider-unity
        # dotnetCore
        # mono
        # steam-run-free # nix-alien doesn't seem to run unity apps, this does...

        inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
        (blender.override {cudaSupport = true;})
        godot_4
        (obs-studio.override {cudaSupport = true;})
        kdePackages.kdenlive
        # davinci-resolve
        krita
        makemkv
        lrcget
        # msty
        # jellyfin-media-player # CVE, can't install
        jellyfin-desktop
        jellyfin-mpv-shim
        # tidal-hifi
        # tidal-dl-ng # TODO: Borked
        # spotdl
        tiddl
        picard
        handbrake
        teamspeak6-client

        steam-devices-udev-rules
      ];

      file = lib.mkMerge [
        {
          # ".local/share/applications/jetbrains-rider.desktop".source = let
          #   desktopFile = pkgs.makeDesktopItem {
          #     name = "jetbrains-rider";
          #     desktopName = "Rider";
          #     exec = "\"${rider-unity}/bin/rider\"";
          #     icon = "rider";
          #     type = "Application";
          #     # Don't show desktop icon in search or run launcher
          #     extraConfig.NoDisplay = "true";
          #   };
          # in "${desktopFile}/share/applications/jetbrains-rider.desktop";

          ".var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf".source =
            ../../../config/mangohud/MangoHud.conf;
        }
        (lib.optionalAttrs (mylib.modules.contains config.home.packages pkgs.makemkv) {
          ".MakeMKV/settings.conf".source =
            config.lib.file.mkOutOfStoreSymlink
            "${nixosConfig.sops.templates."makemkv-settings.conf".path}";
        })
      ];

      # Do not change.
      # This marks the version when NixOS was installed for backwards-compatibility.
      stateVersion = "22.05";
    };

    services = {
      flatpak = {
        packages = [
          "com.valvesoftware.Steam"
          "com.valvesoftware.Steam.Utility.steamtinkerlaunch"
          "org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08"
          "org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"
          "io.github.Foldex.AdwSteamGtk"
          "com.vysp3r.ProtonPlus"
          # "net.davidotek.pupgui2"

          "org.prismlauncher.PrismLauncher"
          "com.usebottles.bottles"
          "io.github.lawstorant.boxflat"

          # "com.unity.UnityHub"
        ];

        overrides = {
          "org.prismlauncher.PrismLauncher".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Downloads"

              "/tmp" # To allow temporary world folder creation for datapack installation
            ];
          };

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

          "com.vysp3r.ProtonPlus".Context = {
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

          "com.unity.UnityHub".Context = {
            filesystems = [
              "${config.home.homeDirectory}/Unity"
              "${config.home.homeDirectory}/Projects"
            ];
          };
        };
      };
    };
  };
}
