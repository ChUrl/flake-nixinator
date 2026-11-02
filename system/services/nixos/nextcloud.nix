{
  lib,
  pkgs,
  ...
}: let
  hostName = "nextcloud.local.chriphost.de";
in {
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
        "nextcloud.vps.chriphost.de"
        "vps.chriphost.de"
      ];

      # Caddy on this host and the VPS hop
      trusted_proxies = [
        "127.0.0.1"
        "::1"
      ];

      overwriteprotocol = "https";
      overwrite.cli.url = "https://nextcloud.vps.chriphost.de";
      default_phone_region = "DE";
    };

    # The module's default of 8 triggers Nextcloud's "OPcache interned strings
    # buffer is nearly full" warning.
    phpOptions = {
      "opcache.interned_strings_buffer" = "32";
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
      "nextcloud.vps.chriphost.de"
      "vps.chriphost.de"
    ];
  };
}
