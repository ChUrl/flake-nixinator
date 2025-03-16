{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config) paths;
in {
  options.paths = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf paths.enable {};
}
