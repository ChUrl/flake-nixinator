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

  fail2ban =
    mkBoolOption true
    "Ban IPs that repeatedly fail SSH authentication.";
}
