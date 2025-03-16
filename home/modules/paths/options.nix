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
    example = "${config.home.homeDirectory}/NixFlake";
    description = "Location of the NixFlake working copy";
  };

  dotfiles = lib.mkOption {
    type = lib.types.path;
    apply = toString;
    example = "${config.home.homeDirectory}/NixFlake/config";
    description = "Location of the NixFlake working copy's config directory";
  };
}
