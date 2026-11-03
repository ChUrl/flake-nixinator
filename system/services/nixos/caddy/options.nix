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
    type = types.nullOr types.port;
    default = 80;
    description = "Port Caddy serves HTTP on.";
  };

  httpsPort = mkOption {
    type = types.nullOr types.port;
    default = 443;
    description = ''
      Port Caddy serves HTTPS on (only used when autoHttps is enabled).
      Set to null on plain HTTP origin servers.
    '';
  };

  autoHttps = mkBoolOption true ''
    Automatic HTTPS (ACME). Turn off for plain HTTP origin servers.

    With autoHttps = false every vhost address must use the `http://`
    scheme (`hostName = "http://host"`). A bare host name is still treated as
    an HTTPS site by Caddy and is served with TLS on `httpsPort`.
  '';

  dnsProvider = mkOption {
    type = types.nullOr (types.enum ["ionos" "inwx" "hetzner"]);
    default = null;
    description = ''
      ACME DNS-01 provider (lego). Required for wildcard certificates, which in
      turn are required for the `*.local.chriphost.gay` names.

      `hetzner` uses `caddy-hetzner-api-token` (Hetzner **Cloud API** token with
      DNS read+write — DNS-01 creates and removes TXT records),
      `inwx` uses `caddy-inwx-user`/`caddy-inwx-password` (INWX account),
      `ionos` uses `caddy-ionos-prefix`/`caddy-ionos-key` (IONOS API key).
    '';
  };

  acmeDomain = mkOption {
    type = types.str;
    default = "*.local.chriphost.gay";
    description = "Domain the wildcard certificate is issued for.";
  };

  acmeCertName = mkOption {
    type = types.str;
    default = "local.chriphost.gay";
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
      `*.local.chriphost.gay` because those names are local rewrites there. That
      makes lego's recursive check loop until its timeout even though the
      challenge record is published on all authoritative nameservers.
    '';
  };

  localDomain = mkOption {
    type = types.str;
    default = "local.chriphost.gay";
    description = ''
      Domain below which the vhosts are served: a service declaring the vhost
      `foo` is reachable as `foo.<localDomain>`.
    '';
  };

  vhosts = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        port = mkOption {
          type = types.port;
          description = "Loopback port of the service (127.0.0.1:<port>).";
        };

        aliases = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Additional host names for the vhost, e.g. the public (VPS) name of a
            service that is proxied with the Host header preserved.
          '';
        };

        extraConfig = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Overrides the default `reverse_proxy 127.0.0.1:<port>`.";
        };
      };
    });
    default = {};
    description = ''
      Reverse proxy vhosts, declared by the modules of the services they front.
      How they are rendered depends on the role of the host: an HTTPS-terminating
      host uses the wildcard certificate, a plain HTTP origin host serves them
      with the `http://` scheme.
    '';
  };

  openFirewall =
    mkBoolOption true
    "Open httpPort/httpsPort in the firewall.";
}
