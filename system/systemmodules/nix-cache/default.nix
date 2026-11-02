{
  config,
  lib,
  mylib,
  ...
}: let
  cfg = config.systemmodules.nix-cache;
  clients = lib.concatStringsSep ", " cfg.allowedClients;
in {
  options.systemmodules.nix-cache = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf cfg.enable {
    sops.secrets."nix-cache-private-key" = {};

    services.nix-serve = {
      enable = true;
      inherit (cfg) port;
      secretKeyFile = config.sops.secrets."nix-cache-private-key".path;
    };

    # The cache is read-only, but only the servers need it.
    networking.firewall.extraInputRules = ''
      ip saddr { ${clients} } tcp dport ${toString cfg.port} accept
    '';
  };
}
