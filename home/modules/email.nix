{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.email;
in {

  options.modules.email = {
    enable = mkEnableOpt "Email";
  };

  config = mkIf cfg.enable {
    programs = {
      mbsync.enable = true;
      msmtp.enable = true;
      notmuch = {
        enable = true;
        hooks = {
          preNew = "mbsync --all";
        };
      };
    };

    accounts.email.accounts = {
      urpost = {
        address = "tobi@urpost.de";
        userName = "tobi@urpost.de";
        realName = "Christoph Urlacher";
        signatur.showSignature = "none";

        imap.host = "mail.zeus08.de";
        imap.port = 993;
        smtp.host = "mail.zeus08.de";
        smtp.port = 465;

        passwordCommand = "kwallet-query -f email -r urpost kdewallet";

        mbsync = { # Imap
          enable = true;
          create = "maildir";
        };
        msmtp.enable = true; # Smtp
        notmuch.enable = true;

        primary = true;
      };
    };
  };
}
