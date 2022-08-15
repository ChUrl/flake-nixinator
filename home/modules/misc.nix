{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.misc;
in {
  options.modules.misc = {
    enable = mkEnableOpt "Misc module";

    keepass = {
      enable = mkEnableOpt "KeePassXC";
      autostart = mkBoolOpt false "Autostart KeePassXC";
    };

    protonmail = {
      enable = mkEnableOpt "ProtonMail";
      autostart = mkBoolOpt false "Autostart ProtonMail Bridge";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; builtins.concatLists [
      (optionals cfg.keepass.enable [ keepassxc ])
      (optionals cfg.protonmail.enable [ protonmail-bridge ])
    ];

    systemd.user.services = mkMerge [
      (optionalAttrs (cfg.keepass.enable && cfg.keepass.autostart) {
        autostart-keepass = {
          Unit = {
            Type = "oneshot";
            Description = "KeePassXC password manager";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };

          Service = {
            # Environment = "PATH=${config.home.profileDirectory}/bin"; # Leads to /etc/profiles/per-user/christoph/bin
            ExecStart = "${pkgs.keepassxc}/bin/keepassxc ${config.home.homeDirectory}/Documents/KeePass/passwords.kbdx";
            # ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
            Restart = "on-failure";
          };

          Install.WantedBy = [ "graphical-session.target" ];
        };
      })

      (optionalAttrs (cfg.protonmail.enable && cfg.protonmail.autostart) {
        autostart-protonmail = {
          Unit = {
            Description = "ProtonMail Bridge";
            After = [ "network.target" ];
          };

          Service = {
            ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --log-level info --noninteractive";
            Restart = "always";
          };

          Install.WantedBy = [ "default.target" ];
        };
      })
    ];
  };
}
