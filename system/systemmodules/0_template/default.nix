{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.systemmodules) TEMPLATE;
in {
  options.systemmodules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config =
    lib.mkIf TEMPLATE.enable {
    };
}
