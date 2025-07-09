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
  # The paths module doesn't use the "modules" namespace to keep the access shorter
  options.paths = import ./options.nix {inherit lib mylib;};

  config = {};
}
