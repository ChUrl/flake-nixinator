{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = mkEnableOpt "Hyprland Window Manager + Compositor";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.programs.hyprland.enable;
        message = "Can't enable Hyprland module with Hyprland disabled!";
      }
    ];

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    home.packages = with pkgs; [
      hyprpaper
      
      # TODO: These are mostly also present in the Plasma module, find a way to unify this?
      libsForQt5.qt5ct # QT Configurator for unintegrated desktops
      libsForQt5.ark
      libsForQt5.breeze-gtk
      libsForQt5.breeze-icons
      libsForQt5.breeze-qt5
      libsForQt5.dolphin
      libsForQt5.dolphin-plugins
      libsForQt5.ffmpegthumbs
      libsForQt5.gwenview
      libsForQt5.kalendar
      libsForQt5.kate
      libsForQt5.kcalc
      libsForQt5.kcharselect
      libsForQt5.kcolorpicker
      libsForQt5.kdenetwork-filesharing
      libsForQt5.kdegraphics-thumbnailers
      libsForQt5.kfind
      libsForQt5.kgpg
      libsForQt5.kmail
      libsForQt5.kompare # Can't be used as git merge tool, but more integrated than kdiff3
      libsForQt5.ksystemlog
      libsForQt5.kwallet # TODO: How does this integrate with hyprland?
      libsForQt5.kwalletmanager # TODO: Same as above
      libsForQt5.kwrited
      libsForQt5.okular
      libsForQt5.plasma-systemmonitor
      libsForQt5.polkit-kde-agent
      libsForQt5.spectacle
      libsForQt5.skanlite

      slurp # Region selector for screensharing
    ];

    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        plugins = [
          pkgs.keepmenu # Rofi KeepassXC frontend
        ];
        terminal = "${pkgs.kitty}/bin/kitty";
  
        font = "JetBrains Mono 14";
        # theme = 
        # extraConfig = '''';
      };

      waybar = {
        enable = true;
        systemd = {
          enable = false;
        };
  
        # settings = {};
        # style = '''';
      };
    };

    services = {
      # Notification service
      dunst = {
        enable = true;
      };
    };

    # Polkit
    home.file.".config/hypr/polkit.conf".text = ''exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-agent-1 &'';
  };
}