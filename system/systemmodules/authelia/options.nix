{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  enable = mkEnableOption "Authelia authentication portal";

  domain = mkOption {
    type = types.str;
    default = "chriphost.de";
    description = "Base domain the session cookie is valid for.";
  };

  authUrl = mkOption {
    type = types.str;
    default = "https://auth.chriphost.de";
    description = "URL the portal is reachable at.";
  };

  adminDomains = mkOption {
    type = types.listOf types.str;
    default = ["*.admin.chriphost.de"];
    description = ''
      Domains that require two factors.

      Nextcloud, Immich, Paperless, ntfy, Gitea don't use Authelia deliberately
      to NOT go through the portal: their mobile apps would break.
    '';
  };
}
