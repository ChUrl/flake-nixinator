{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) TEMPLATE;
in {
  options.modules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config =
    lib.mkIf TEMPLATE.enable {
    };
}
