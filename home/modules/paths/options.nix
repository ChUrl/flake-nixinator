{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "paths";

  nixflake = lib.mkOption {
    type = lib.types.path;
    apply = toString;
    default = "${config.home.homeDirectory}/NixFlake";
    example = "${config.home.homeDirectory}/NixFlake";
    description = "Location of the NixFlake working copy";
  };

  dotfiles = lib.mkOption {
    type = lib.types.path;
    apply = toString;
    default = "${config.nixflake}/config";
    example = "${config.nixflake}/config";
    description = "Location of the NixFlake working copy's config directory";
  };
}
