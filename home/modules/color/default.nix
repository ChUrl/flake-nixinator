{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.color;
in {
  options.modules.color = import ./options.nix {inherit lib mylib;};

  config = {};
}
