{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  enable = mkEnableOption "nix-serve binary cache";

  port = mkOption {
    type = types.port;
    default = 5000;
    description = "Port the cache listens on.";
  };

  allowedClients = mkOption {
    type = types.listOf types.str;
    default = [
      "192.168.86.25" # servenix
      "192.168.86.26" # thinknix
    ];
    description = "Addresses allowed to fetch from the cache.";
  };
}
