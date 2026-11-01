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
      ACME DNS-01 provider (lego). Required for wildcard certificates, which in
      turn are required for the `*.local.chriphost.de` names.
    '';
  };

  acmeDomain = mkOption {
    type = types.str;
    default = "*.local.chriphost.de";
    description = "Domain the wildcard certificate is issued for.";
  };

  acmeCertName = mkOption {
    type = types.str;
    default = "local.chriphost.de";
    description = ''
      Name of the `security.acme.certs.<name>` entry. Vhosts reference this via
      `useACMEHost`.
    '';
  };

  acmeResolver = mkOption {
    type = types.nullOr types.str;
    default = null;
    example = "8.8.8.8:53";
    description = ''
      Recursive resolver used for lego's DNS propagation check (`host:port`).

      The LAN resolver (AdGuard) serves NODATA for TXT queries below
      `*.local.chriphost.de` because those names are local rewrites there. That
      makes lego's recursive check loop until its timeout even though the
      challenge record is published on all authoritative nameservers.
    '';
  };

  openFirewall =
    mkBoolOption true
    "Open httpPort/httpsPort in the firewall.";
}
