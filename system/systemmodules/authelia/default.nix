{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.systemmodules.authelia;

  # Name of the single instance defined below. The nixpkgs module derives
  # the systemd service and the system user from it (authelia-main).
  instance = config.services.authelia.instances.main;

  usersDatabase = config.sops.templates."authelia-users-database.yml".path;
in {
  options.systemmodules.authelia = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    sops.secrets."authelia-jwt-secret" = {
      owner = instance.user;
      group = instance.group;
      mode = "0400";
    };

    sops.secrets."authelia-storage-encryption-key" = {
      owner = instance.user;
      group = instance.group;
      mode = "0400";
    };

    sops.secrets."authelia-password-hash" = {
      owner = instance.user;
      group = instance.group;
      mode = "0400";
    };

    # The hash stays out of the nix store by using the placeholder
    sops.templates."authelia-users-database.yml" = {
      owner = instance.user;
      group = instance.group;
      mode = "0400";
      content = ''
        users:
          christoph:
            displayname: "Christoph"
            password: "${config.sops.placeholder."authelia-password-hash"}"
            email: "christoph.urlacher@protonmail.com"
            groups:
              - admins
      '';
    };

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia-storage-encryption-key".path;
      };

      settings = {
        theme = "dark";

        # Passkeys need the real HTTPS origin, so TOTP is the default for now
        default_2fa_method = "totp";

        # Only reachable through the tunnel / the reverse proxy in front of it.
        server.address = "tcp://127.0.0.1:9091";

        log = {
          level = "info";
          format = "text";
        };

        totp = {
          issuer = cfg.domain;
          period = 30;
          skew = 1;
        };

        authentication_backend.file.path = usersDatabase;

        storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";

        session = {
          name = "authelia_session";
          expiration = "1h";
          inactivity = "5m";
          remember_me = "1M";
          cookies = [
            {
              domain = cfg.domain;
              authelia_url = cfg.authUrl;
            }
          ];
        };

        regulation = {
          max_retries = 5;
          find_time = "2m";
          ban_time = "5m";
        };

        access_control = {
          # Anything not matched below is denied.
          default_policy = "deny";

          rules = [
            {
              domain = [
                "auth.chriphost.de"
                "auth.local.chriphost.de"
                "auth.vps.chriphost.de"
              ];
              policy = "bypass";
            }
            {
              domain = cfg.adminDomains;
              policy = "two_factor";
            }
          ];
        };
      };
    };
  };
}
