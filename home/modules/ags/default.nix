{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.ags;
in {
  options.modules.ags = import ./options.nix {inherit lib mylib;};

  config =
    mkIf cfg.enable {
    };
}
