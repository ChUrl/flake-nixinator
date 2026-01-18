{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Polkit";

  allowedActions = mkOption {
    type = types.listOf types.str;
    description = "Actions that should be manageable by a User without Root Password";
    example = ''
      [
        "org.freedesktop.NetworkManager.settings.modify.system"
      ]
    '';
    default = [];
  };

  allowedSystemServices = mkOption {
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
