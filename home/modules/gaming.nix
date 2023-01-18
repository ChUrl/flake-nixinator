{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.gaming;
  cfgfp = config.modules.flatpak;
in {
  imports = [
    # NOTE: I don't know if this is the right approach or if I should use config.modules.flatpak
    ./flatpak.nix
  ];

  # TODO: Enable flatpak MangoHud, there are multiple versions, Steam.Utility.MangoHud works but can't be configured (in ~/.config/MangoHud), other versions don't even work (need to figure that out as Steam.Utility.MangoHud is EOL...)
  # TODO: SteamTinkerLaunch option
  # TODO: Dolphin + SteamRomManager option

  options.modules.gaming = {
    enable = mkEnableOpt "Gaming module";

    discordElectron.enable = mkEnableOpt "Discord (Electron) (nixpkgs)";
    discordChromium.enable = mkEnableOpt "Discord (Chromium)";
    prism.enable = mkEnableOpt "PrismLauncher for Minecraft (flatpak)";
    bottles.enable = mkEnableOpt "Bottles (flatpak)";
    dwarffortress.enable = mkEnableOpt "Dwarf Fortress";

    steam = {
      enable = mkEnableOpt "Steam (flatpak)";
      protonGE = mkBoolOpt false "Enable Steam Proton GloriousEggroll runner (flatpak)";
      gamescope = mkBoolOpt false "Enable the gamescope micro compositor (flatpak)";
      adwaita = mkBoolOpt false "Enable the adwaita-for-steam skin";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      # TODO: Make lib function for multiple assertions that have the same condition
      (mkIf cfg.steam.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable Steam without the flatpak module!";
      })
      (mkIf cfg.prism.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable PrismLauncher without the flatpak module!";
      })
      (mkIf cfg.bottles.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable Bottles without the flatpak module!";
      })
    ];

    home.packages = with pkgs;
      builtins.concatLists [
        [
          gamemode # gamemode should be always enabled (could also be enabled by audio module)
          oversteer # TODO: Make option
          # Sometimes needed for Proton prefix shenenigans (for AC etc.), but probably only works with Protontricks only so disable for now...
          # wine64 # TODO: Make option or dependant on protontricks?
        ]

        # TODO: Extra config (extensions etc) in chromium module
        (optionals cfg.discordChromium.enable [chromium])

        # Prefer flatpak version as nixpkgs version isn't always updated in time
        (optionals cfg.discordElectron.enable [discord])
        (optionals cfg.steam.adwaita [adwaita-for-steam])

        # Prefer flatpak version as this one doesn't find the STEAM_DIR automatically
        # (optionals cfg.steam.enable [ protontricks ])

        (optionals cfg.dwarffortress.enable [dwarf-fortress-packages.dwarf-fortress-full])
      ];

    # This doesn't work because steam doesn't detect symlinked skins, files have to be copied
    # https://github.com/ValveSoftware/steam-for-linux/issues/3572
    # home.file = mkMerge [
    #   (optionalAttrs cfg.steam.adwaita {
    #     "adwaita-for-steam" = {
    #       source = "${pkgs.adwaita-for-steam}/share/adwaita-for-steam/Adwaita";
    #       target = ".var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita";
    #       recursive = false;
    #     };
    #   })
    # ];
    home.activation = mkMerge [
      (optionalAttrs cfg.steam.adwaita {
        copySteamAdwaitaSkin = hm.dag.entryAfter ["writeBoundary"] ''
          if [ ! -d ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins ]; then
            mkdir ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins
          fi

          # Delete the directory to copy again, if src was updated
          if [ -d ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita ]; then
            rm -rf ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita
          fi

          cp -r ${pkgs.adwaita-for-steam}/share/adwaita-for-steam/Adwaita ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita
          chmod -R +w ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita
        '';
      })

      (optionalAttrs (! cfg.steam.adwaita) {
        deleteSteamAdwaitaSkin = hm.dag.entryAfter ["writeBoundary"] ''
          rm -rf ${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/.local/share/Steam/skins/Adwaita
        '';
      })
    ];

    xdg.desktopEntries.discordChromium = mkIf cfg.discordChromium.enable {
      name = "Discord (Chromium)";
      genericName = "Online voice chat";
      icon = "discord";
      exec = "chromium --new-window discord.com/app";
      terminal = false;
      categories = ["Network" "Chat"];
    };

    # NOTE: Important to not disable this option if another module enables it
    modules.flatpak.bottles.enable = mkIf cfg.bottles.enable true;

    modules.flatpak.extraOverride = [
      # Allow Bottles to manage proton prefixes
      (optionalAttrs cfg.bottles.enable {
        "com.usebottles.bottles" = "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam;${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD";
      })
      # Allow Steam to access different library folders
      # Allow Steam to explicitly run something through ProtonGE
      (optionalAttrs cfg.steam.enable {
        # TODO: Make the second string into a list [ ~/GameSSD ~/GameHDD ] etc.
        "com.valvesoftware.Steam" = "${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD;/var/lib/flatpak/runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE";
      })
      # Allow protontricks to change prefixes in different library folders
      (optionalAttrs cfg.steam.enable {
        "com.github.Matoking.protontricks" = "${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD";
      })
      # Allow ProtonUP-Qt to see game list and access steam
      (optionalAttrs (cfg.steam.enable && cfg.steam.protonGE) {
        "net.davidotek.pupgui2" = "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam;${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD";
      })
    ];

    # TODO: RetroArch option org.libretro.RetroArch
    modules.flatpak.extraInstall = builtins.concatLists [
      (optionals cfg.steam.enable [
        "com.valvesoftware.Steam"
        "com.github.Matoking.protontricks"
        # "com.valvesoftware.Steam.Utility.steamtinkerlaunch"
        # "com.steamgriddb.steam-rom-manager"
        # "org.DolphinEmu.dolphin-emu"
      ])
      (optionals (cfg.steam.enable && cfg.steam.protonGE) [
        # "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
        "net.davidotek.pupgui2"
      ])
      (optionals (cfg.steam.enable && cfg.steam.gamescope) ["com.valvesoftware.Steam.Utility.gamescope"])
      (optionals cfg.prism.enable ["org.prismlauncher.PrismLauncher"])
    ];

    modules.flatpak.extraRemove = builtins.concatLists [
      (optionals (!cfg.steam.enable) [
        "com.valvesoftware.Steam"
        "com.github.Matoking.protontricks"
        # "com.valvesoftware.Steam.Utility.steamtinkerlaunch"
        # "com.steamgriddb.steam-rom-manager"
        # "org.DolphinEmu.dolphin-emu"
      ])
      (optionals (!cfg.steam.enable || !cfg.steam.protonGE) [
        # "com.valvesoftware.Steam.CompatibilityTool.Proton-GE"
        "net.davidotek.pupgui2"
      ])
      (optionals (!cfg.steam.enable || !cfg.steam.gamescope) ["com.valvesoftware.Steam.Utility.gamescope"])
      (optionals (!cfg.prism.enable) ["org.prismlauncher.PrismLauncher"])
    ];
  };
}
