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

        globalConfig = lib.mkIf (!cfg.autoHttps) ''
          auto_https off
        '';
      };
    }

    # Wildcard certificates can only be obtained through DNS-01, so a provider
    # has to be configured. NixOS' acme module (lego) issues the certificate
    # and Caddy just loads the files, which avoids building Caddy with a
    # DNS plugin.
    (lib.mkIf (cfg.dnsProvider != null) {
      sops.secrets."caddy-ionos-prefix" = {};
      sops.secrets."caddy-ionos-key" = {};

      sops.templates."caddy-acme.env" = {
        owner = "acme";
        group = "acme";
        mode = "0400";
        content = ''
          IONOS_API_KEY=${config.sops.placeholder."caddy-ionos-prefix"}.${config.sops.placeholder."caddy-ionos-key"}
        '';
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
