{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  inherit (mylib.modules) mkBoolOption;
in {
  enable = mkEnableOption "Caddy reverse proxy";

  email = mkOption {
    type = types.str;
    default = "christoph.urlacher@protonmail.com";
    description = "Email address for the ACME account.";
  };

  httpPort = mkOption {
    type = types.port;
    default = 80;
    description = "Port Caddy serves HTTP on.";
  };

  httpsPort = mkOption {
    type = types.port;
    default = 443;
    description = "Port Caddy serves HTTPS on (only used when autoHttps is enabled).";
  };

  autoHttps = mkBoolOption true ''
    Automatic HTTPS (ACME). Turn off for plain HTTP origin servers.

    With autoHttps = false every vhost address must use the `http://`
    scheme (`hostName = "http://host"`). A bare host name is still treated as
    an HTTPS site by Caddy and is served with TLS on `httpsPort`.
  '';

  dnsProvider = mkOption {
    type = types.nullOr (types.enum ["ionos"]);
    default = null;
    description = ''
      ACME DNS-01 provider. Required for wildcard certificates, which in turn
      are required for the `*.local.chriphost.de` names.
    '';
  };

  openFirewall =
    mkBoolOption true
    "Open httpPort/httpsPort in the firewall.";
}
