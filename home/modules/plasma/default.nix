# TODO: Use this: https://github.com/pjones/plasma-manager
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
  cfg = config.modules.plasma;
in {
  options.modules.plasma = import ./options.nix { inherit lib mylib; };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = nixosConfig.services.xserver.desktopManager.plasma5.enable;
        message = "Can't enable Plasma module when Plasma is not enabled!";
      }
    ];

    home.packages = with pkgs; [
      # libsForQt5.qt5ct # QT Configurator for unintegrated desktops
      libsForQt5.ark
      libsForQt5.discover
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
      libsForQt5.spectacle
      libsForQt5.skanlite
    ];

    # Autostart KRunner Daemon
    home.file.".config/autostart/krunner.desktop".source = ../../config/autostart/krunner.desktop;
  };
}
