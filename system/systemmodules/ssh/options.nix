{
  lib,
  mylib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  inherit (mylib.modules) mkBoolOption;
in {
  enable = mkEnableOption "hardened OpenSSH server";

  port = mkOption {
    type = types.port;
    default = 22;
    description = "Port the OpenSSH daemon listens on.";
  };

  allowedUsers = mkOption {
    type = types.listOf types.str;
    default = [];
    example = ["christoph"];
    description = ''
      Users allowed to log in over SSH (`AllowUsers` in sshd_config).
      An empty list means no restriction.
    '';
  };

  trustedSources = mkOption {
    type = types.listOf types.str;
    default = [];
    example = ["10.10.10.1/32"];
    description = ''
      Sources that must never be banned or rate-limited (fail2ban `ignoreIP`
      and OpenSSH `PerSourcePenaltyExemptList`).

      Needed for hosts whose SSH is proxied for other clients: a TCP stream
      collapses every client into the proxy's IP, so per-IP protection would
      lock out the legitimate users along with the bots instead.
    '';
  };

  fail2ban =
    mkBoolOption true
    "Ban IPs that repeatedly fail SSH authentication.";
}
