{ config, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.gaming;
  cfgfp = config.modules.flatpak;
in {
  imports = [
    # NOTE: I don't know if this is the right approach or if I should use config.modules.flatpak
    ./flatpak.nix
  ];

  options.modules.gaming = {
    enable = mkEnableOpt "Gaming module";

    discordChromium.enable = mkEnableOpt "Discord (Chromium)";
    polymc.enable = mkEnableOpt "PolyMC (flatpak)";
    bottles.enable = mkEnableOpt "Bottles (flatpak)";

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
      (mkIf cfg.polymc.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable PolyMC without the flatpak module!";
      })
      (mkIf cfg.bottles.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable Bottles without the flatpak module!";
      })
    ];

    home.packages = with pkgs; builtins.concatLists [
      [ gamemode ] # gamemode should be always enabled (could also be enabled by audio module)

      # TODO: Extra config (extensions etc) in chromium module
      (optionals cfg.discordChromium.enable [ chromium ])

      (optionals cfg.steam.adwaita [ adwaita-for-steam ])
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
        copySteamAdwaitaSkin = hm.dag.entryAfter [ "writeBoundary" ] ''
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
        deleteSteamAdwaitaSkin = hm.dag.entryAfter [ "writeBoundary" ] ''
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
      categories = [ "Network" "Chat" ];
    };

    # NOTE: Important to not disable this option if another module enables it
    modules.flatpak.bottles.enable = mkIf cfg.bottles.enable true;

    modules.flatpak.extraOverride = [
      (optionalAttrs cfg.bottles.enable {
        "com.usebottles.bottles" = "${config.home.homeDirectory}/.var/app/com.valvesoftware.Steam/data/Steam;${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD";
      })
      (optionalAttrs cfg.steam.enable {
        "com.valvesoftware.Steam" = "${config.home.homeDirectory}/GameSSD;${config.home.homeDirectory}/GameHDD";
      })
    ];

    modules.flatpak.extraInstall = builtins.concatLists [
      (optionals cfg.steam.enable [ "com.valvesoftware.Steam" ])
      (optionals (cfg.steam.enable && cfg.steam.protonGE) [ "com.valvesoftware.Steam.CompatibilityTool.Proton-GE" ])
      (optionals (cfg.steam.enable && cfg.steam.gamescope) [ "com.valvesoftware.Steam.Utility.gamescope" ])
      (optionals cfg.polymc.enable [ "org.polymc.PolyMC" ])
    ];

    modules.flatpak.extraRemove = builtins.concatLists [
      (optionals (!cfg.steam.enable) [ "com.valvesoftware.Steam" ])
      (optionals (!cfg.steam.enable || !cfg.steam.protonGE) [ "com.valvesoftware.Steam.CompatibilityTool.Proton-GE" ])
      (optionals (!cfg.steam.enable || !cfg.steam.gamescope) [ "com.valvesoftware.Steam.Utility.gamescope" ])
      (optionals (!cfg.polymc.enable) [ "org.polymc.PolyMC" ])
    ];
  };
}