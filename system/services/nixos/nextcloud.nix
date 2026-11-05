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
