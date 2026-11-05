{
  config,
  lib,
  mylib,
  ...
}: let
  cfg = config.systemmodules.caddy;
in {
  options.systemmodules.caddy = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.caddy = {
        enable = true;

        inherit
          (cfg)
          email
          httpPort
          httpsPort
          openFirewall
          ;

        # `metrics` enables the HTTP metrics; the admin API (servenix) and the
        # `metrics` vhosts (thinknix/VPS) only serve them.
        globalConfig = ''
          ${lib.optionalString (!cfg.autoHttps) "auto_https off"}
          metrics
        '';

        # One reverse proxy vhost per service that declared one
        virtualHosts = lib.mapAttrs' (name: vhost: let
          fqdn = "${name}.${cfg.localDomain}";

          reverseProxy =
            if vhost.extraConfig != null
            then vhost.extraConfig
            else "reverse_proxy 127.0.0.1:${toString vhost.port}";
        in
          lib.nameValuePair fqdn (
            if cfg.autoHttps
            then {
              useACMEHost = cfg.acmeCertName;
              serverAliases = vhost.aliases;
              extraConfig = reverseProxy;
            }
            else {
              # NOTE: The explicit http:// scheme is required. Without it Caddy
              #       treats the address as an HTTPS site and serves TLS on
              #       httpsPort instead of plain HTTP on httpPort.
              hostName = "http://${fqdn}";
              serverAliases = map (alias: "http://${alias}") vhost.aliases;
              extraConfig = reverseProxy;
            }
          ))
        cfg.vhosts;
      };
    }

    # Wildcard certificates can only be obtained through DNS-01, so a provider
    # has to be configured. NixOS' acme module (lego) issues the certificate
    # and Caddy just loads the files, which avoids building Caddy with a
    # DNS plugin.
    (lib.mkIf (cfg.dnsProvider != null) {
      # Backed up by systemmodules/restic (the ACME directory is hardcoded)
      systemmodules.restic.servicePaths = ["/var/lib/acme"];

      sops.secrets =
        {
          ionos = {
            "caddy-ionos-prefix" = {};
            "caddy-ionos-key" = {};
          };
          inwx = {
            "caddy-inwx-user" = {};
            "caddy-inwx-password" = {};
          };
          hetzner = {
            "caddy-hetzner-api-token" = {};
          };
        }
        .${
          cfg.dnsProvider
        };

      sops.templates."caddy-acme.env" = {
        owner = "acme";
        group = "acme";
        mode = "0400";

        # The env var names are the ones lego expects for the provider.
        content =
          {
            ionos = ''
              IONOS_API_KEY=${config.sops.placeholder."caddy-ionos-prefix"}.${config.sops.placeholder."caddy-ionos-key"}
            '';
            inwx = ''
              INWX_USERNAME=${config.sops.placeholder."caddy-inwx-user"}
              INWX_PASSWORD=${config.sops.placeholder."caddy-inwx-password"}
            '';
            hetzner = ''
              HETZNER_API_TOKEN=${config.sops.placeholder."caddy-hetzner-api-token"}
            '';
          }
          .${
            cfg.dnsProvider
          };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = cfg.email;

        certs.${cfg.acmeCertName} =
          {
            domain = cfg.acmeDomain;

            inherit (cfg) dnsProvider;
            environmentFile = config.sops.templates."caddy-acme.env".path;

            # services.caddy runs as this group and has to read cert.pem/key.pem
            group = "caddy";
          }
          // lib.optionalAttrs (cfg.acmeResolver != null) {
            dnsResolver = cfg.acmeResolver;
          };
      };
    })
  ]);
}
