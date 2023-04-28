{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.TEMPLATE;
in {
  options.modules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {};
}
