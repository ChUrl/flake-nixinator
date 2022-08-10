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

    noisetorch = {
      enable = mkEnableOpt "Noisetorch";
      autostart = mkBoolOpt false "Autostart Noistorch";
    };

    steam = {
      enable = mkEnableOpt "Steam (flatpak)";
      protonGE = mkBoolOpt false "Enable Steam Proton GloriousEggroll runner (flatpak)";
      gamescope = mkBoolOpt false "Enable the gamescope micro compositor (flatpak)";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
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

      # TODO: Extra config (extensions etc), maybe standalone chromium module
      (optionals cfg.discordChromium.enable [ chromium ])
      (optionals cfg.noisetorch.enable [ noisetorch ])
    ];

    xdg.desktopEntries.discordChromium = mkIf cfg.discordChromium.enable {
      name = "Discord (Chromium)";
      genericName = "Online voice chat";
      icon = "discord";
      exec = "chromium --new-window discord.com/app";
      terminal = false;
      categories = [ "Network" "Chat" ];
    };

    systemd.user.services = mkIf (cfg.noisetorch.enable && cfg.noisetorch.autostart) {
      noisetorch-autostart = {
        Unit = {
          Description = "Noisetorch noise suppression";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "oneshot";
          Environment = "PATH=/etc/profiles/per-user/${config.home.username}/bin";
          ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i";
        };
       };
    };

    # NOTE: Important to not disable this option if another module enables it
    modules.flatpak.bottles.enable = mkIf cfg.bottles.enable true;

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