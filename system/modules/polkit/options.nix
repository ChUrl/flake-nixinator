{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Polkit";

  allowed-system-services = mkOption {
    type = types.listOf types.str;
    description = "System Services that should be manageable by a User without Root Password";
    example = ''
      [
        "jellyfin"
        "stablediffusion"
      ]
    '';
    default = [];
  };
}
