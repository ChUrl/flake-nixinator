{
  config,
  lib,
  pkgs,
  ...
}: let
  hostName = "nextcloud.local.chriphost.gay";
in {
  # Backed up by systemmodules/restic
  systemmodules.restic.servicePaths = [config.services.nextcloud.datadir];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.nextcloud = {
    port = 8080;
    aliases = ["nextcloud.vps.chriphost.gay"];
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    inherit hostName;

    # TLS terminates at Caddy in front of this; this only affects generated URLs
    https = true;

    # Uses the shared services.postgresql instance
    database.createLocally = true;

    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
    };

    settings = {
      trusted_domains = [
        hostName
        "nextcloud.vps.chriphost.gay"
        "vps.chriphost.gay"
      ];

      # Caddy on this host and the VPS hop
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];

      overwriteprotocol = "https";
      overwrite.cli.url = "https://nextcloud.vps.chriphost.gay";
      default_phone_region = "DE";

      # The logreader app only understands "file"; the module defaults to syslog.
      log_type = "file";
      logfile = "/var/lib/nextcloud/data/nextcloud.log";

      # Silences the "configuration server ID" setup check (single PHP server,
      # harmless, but the check nags otherwise).
      serverid = 1;

      # Mail goes to the local mailpit catcher (host service on 127.0.0.1:1025).
      mail_smtpport = 1025;
      mail_from_address = "nextcloud";
      mail_domain = "chriphost.gay";
    };

    # The module's default of 8 triggers Nextcloud's "OPcache interned strings
    # buffer is nearly full" warning.
    phpOptions = {
      "opcache.interned_strings_buffer" = "32";

      # APCu (memcache.local) hardcodes a 32M shared segment, which Nextcloud's
      # admin check flags once the file cache fills it (reported 91%).
      "apc.shm_size" = "256M";
    };

    # Everything that is not shipped in the Nextcloud tarball is pinned here,
    # so the appstore can stay disabled and nothing updates outside nixos-rebuild.
    extraApps =
      {
        # Nextcloud Office, backed by the Euro-Office Document Server that
        # system/services/docker/euro-office.nix runs on this host.
        inherit (pkgs.nextcloud35Packages.apps) eurooffice files_automatedtagging;
      }
      // {
        # Not packaged in nixpkgs: Flow Notifications 6.0.0 (Nextcloud 35).
        flow_notifications = pkgs.fetchNextcloudApp {
          appName = "flow_notifications";
          appVersion = "6.0.0";
          url = "https://github.com/nextcloud-releases/flow_notifications/releases/download/v6.0.0/flow_notifications-v6.0.0.tar.gz";
          hash = "sha256-Ms7YlImTCT+pRqA9Swyz066gQrYZi0hms6VbP134zzc=";
          license = "agpl3Plus";
        };
      };

    appstoreEnable = false;
  };

  # The connector keeps the Document Server URL and the JWT secret in appconfig
  # (it generates its own secret on install, which would shadow a config.php
  # value), so both have to be set with occ. Idempotent, re-applied on boot.
  systemd.services.nextcloud-eurooffice-config = {
    description = "Configure the Nextcloud Euro-Office connector";
    wantedBy = ["multi-user.target"];
    after = ["nextcloud-setup.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
      ExecCondition = "${lib.getExe config.services.nextcloud.occ} status --exit-code";
      LoadCredential = "jwt:${config.sops.secrets."eurooffice-jwt-secret".path}";
    };
    script = ''
      occ=${lib.getExe config.services.nextcloud.occ}
      $occ config:app:set eurooffice DocumentServerUrl --value=https://office.vps.chriphost.gay/
      # Browsers need the public URL; the Nextcloud -> Document Server requests
      # stay on loopback instead of hairpinning through the VPS.
      $occ config:app:set eurooffice DocumentServerInternalUrl --value=http://127.0.0.1:8086/
      $occ config:app:set eurooffice jwt_secret --value="$(cat "$CREDENTIALS_DIRECTORY/jwt")"
    '';
  };

  # Internal origin: plain HTTP on loopback, Caddy does TLS and routing.
  services.nginx.virtualHosts.${hostName} = {
    listen = lib.mkForce [
      {
        addr = "127.0.0.1";
        port = 8080;
      }
    ];

    # Requests from the VPS arrive with the public Host header
    serverAliases = [
      "nextcloud.vps.chriphost.gay"
      "vps.chriphost.gay"
    ];
  };
}
