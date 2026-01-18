{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) TEMPLATE color;
in {
  options.modules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf TEMPLATE.enable {};
}
