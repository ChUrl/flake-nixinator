# Example: https://beb.ninja/post/email/
# Example: https://sbr.pm/configurations/mails.html
# NOTE: The passwords must exist in kwallet
# TODO: Emacs mail config
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
  cfg = config.modules.email;
in {
  options.modules.email = import ./options.nix { inherit lib; };

  # TODO: Add Maildir to nextcloud sync
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      builtins.concatLists [
        (optionals cfg.kmail.enable [kmail])
      ];

    home.file = mkMerge [
      (optionalAttrs (cfg.kmail.enable && cfg.kmail.autostart) {
        ".config/autostart/org.kde.kmail2.desktop".source = ../../config/autostart/org.kde.kmail2.desktop;
      })
    ];

    programs = {
      mbsync.enable = true; # isync package
      msmtp.enable = true;
      # Run notmuch new to index all new mail
      notmuch = {
        enable = true;
        hooks = {
          # When running notmuch new all channels will be syncronized by mbsync
          preNew = "mbsync --all";
        };
      };
    };

    # TODO: imapnotify can't parse the configuration, HM bug?
    services.imapnotify.enable = cfg.imapnotify;

    # Autosync, don't need imapnotify when enabled
    systemd.user.services.mail-autosync = (mkIf cfg.autosync) {
      Unit = {Description = "Automatic notmuch/mbsync synchronization";};
      Service = {
        Type = "oneshot";
        # ExecStart = "${pkgs.isync}/bin/mbsync -a";
        ExecStart = "${pkgs.notmuch}/bin/notmuch new";
      };
    };
    systemd.user.timers.mail-autosync = (mkIf cfg.autosync) {
      Unit = {Description = "Automatic notmuch/mbsync synchronization";};
      Timer = {
        OnBootSec = "30";
        OnUnitActiveSec = "5m";
      };
      Install = {WantedBy = ["timers.target"];};
    };

    accounts.email.accounts = {
      urpost = {
        address = "tobi@urpost.de";
        userName = "tobi@urpost.de";
        realName = "Christoph Urlacher";
        signature.showSignature = "none";

        imap.host = "mail.zeus08.de";
        imap.port = 993;
        smtp.host = "mail.zeus08.de";
        smtp.port = 465;

        passwordCommand = "kwallet-query -f email -r urpost kdewallet";

        mbsync = {
          # Imap
          enable = true;
          create = "maildir";
        };
        msmtp.enable = true; # Smtp
        notmuch.enable = true;
        imapnotify.enable = cfg.imapnotify;
        imapnotify.onNotify = {
          mail = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived on Urpost'";
        };

        primary = true;
      };

      hhu = {
        address = "christoph.urlacher@hhu.de";
        userName = "churl100";
        realName = "Christoph Urlacher";
        signature.showSignature = "none";

        imap.host = "mail.hhu.de";
        imap.port = 993;
        smtp.host = "mail.hhu.de";
        smtp.port = 465;

        passwordCommand = "kwallet-query -f email -r hhu kdewallet";

        mbsync = {
          # Imap
          enable = true;
          create = "maildir";
        };
        msmtp.enable = true; # Smtp
        notmuch.enable = true;
        imapnotify.enable = cfg.imapnotify;
        imapnotify.onNotify = {
          mail = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived on HHU'";
        };

        primary = false;
      };

      # TODO: Setup the correct groups/patterns
      gmail = {
        address = "tobiasmustermann529@gmail.com";
        userName = "tobiasmustermann529@gmail.com";
        realName = "Christoph Urlacher";
        signature.showSignature = "none";

        flavor = "gmail.com";

        # NOTE: Uses Gmail app password
        passwordCommand = "kwallet-query -f email -r gmail kdewallet";

        mbsync = {
          # Imap
          enable = true;
          create = "maildir";
          patterns = ["*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail"]; # Only sync inbox
        };
        msmtp.enable = true; # Smtp
        notmuch.enable = true;
        imapnotify.enable = cfg.imapnotify;
        imapnotify.onNotify = {
          mail = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived on GMail'";
        };

        primary = false;
      };
    };
  };
}
