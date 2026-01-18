{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) TEMPLATE color;
in {
  options.homemodules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf TEMPLATE.enable {};
}
