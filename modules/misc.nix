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
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; builtins.concatLists [
      (optionals cfg.keepass.enable [ keepassxc ])
    ];

    systemd.user.services = {
      autostart-keepass =
      (mkIf (cfg.keepass.enable && cfg.keepass.autostart) {
        Unit = {
          Type = "oneshot";
          Description = "KeePassXC password manager";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          Environment = "PATH=${config.home.profileDirectory}/bin"; # Leads to /etc/profiles/per-user/christoph/bin
          ExecStart = "${pkgs.keepassxc}/bin/keepassxc ${config.home.homeDirectory}/Documents/KeePass/passwords.kbdx";
#          ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
          Restart = "on-failure";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      });
    };
  };
}
