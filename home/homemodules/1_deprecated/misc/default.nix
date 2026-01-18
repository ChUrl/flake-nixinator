{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
# TODO: Remove this module, put protonmail into the email module
with lib;
with mylib.modules; let
  cfg = config.modules.misc;
in {
  options.modules.misc = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      builtins.concatLists [
        (optionals cfg.keepass.enable [keepassxc])
        (optionals cfg.protonmail.enable [protonmail-bridge])
      ];

    systemd.user.services = mkMerge [
      (optionalAttrs (cfg.keepass.enable && cfg.keepass.autostart) {
        # TODO: Disable only for plasma
        # autostart-keepass = {
        #  Unit = {
        #    Type = "oneshot";
        #    Description = "KeePassXC password manager";
        #    PartOf = [ "graphical-session.target" ];
        #    After = [ "graphical-session.target" ];
        #  };

        #  Service = {
        #    # Environment = "PATH=${config.home.profileDirectory}/bin"; # Leads to /etc/profiles/per-user/christoph/bin
        #    ExecStart = "${pkgs.keepassxc}/bin/keepassxc ${config.home.homeDirectory}/Documents/KeePass/passwords.kbdx";
        #    # ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
        #    Restart = "on-failure";
        #  };

        #  Install.WantedBy = [ "graphical-session.target" ];
        # };
      })

      # TODO: Disable only for plasma
      # TODO: Error: has no wallet, find out how to get imap credentials from this
      # (optionalAttrs (cfg.protonmail.enable && cfg.protonmail.autostart) {
      #   autostart-protonmail = {
      #     Unit = {
      #       Description = "ProtonMail Bridge";
      #       After = [ "network.target" ];
      #     };

      #     Service = {
      #       ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --no-window --log-level info --noninteractive";
      #       Restart = "always";
      #     };

      #     Install.WantedBy = [ "default.target" ];
      #   };
      # })
    ];
  };
}
