{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  cfg = config.systemmodules.caddy;

  # TODO: determine the real hash when this path is first enabled (5.2).
  #       The expression is inert while dnsProvider = null.
  caddyPackage =
    if cfg.dnsProvider == "ionos"
    then
      pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/ionos@v1.0.1"];
        hash = lib.fakeHash;
      }
    else pkgs.caddy;
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

        package = caddyPackage;

        globalConfig = lib.mkIf (!cfg.autoHttps) ''
          auto_https off
        '';
      };
    }

    # Wildcard certificates need DNS-01, so the IONOS API key is only
    # rendered into a file when a provider is configured.
    (lib.mkIf (cfg.dnsProvider == "ionos") {
      sops.templates."caddy-acme.env" = {
        owner = "caddy";
        group = "caddy";
        mode = "0400";
        content = ''
          IONOS_API_KEY=${config.sops.placeholder."caddy-ionos-prefix"}.${config.sops.placeholder."caddy-ionos-key"}
        '';
      };

      services.caddy = {
        environmentFile = config.sops.templates."caddy-acme.env".path;

        globalConfig = ''
          acme_dns ionos {
            api_token {env.IONOS_API_KEY}
            allowed_zones chriphost.de
          }
        '';
      };
    })
  ]);
}
