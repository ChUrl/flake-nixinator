{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.systemmodules) TEMPLATE;
in {
  # NOTE: Server service modules keep the `systemmodules.*` namespace so the
  #       host config looks the same everywhere and does not collide with
  #       nixpkgs' `services.*`.
  options.systemmodules.TEMPLATE = import ./options.nix {inherit lib mylib;};

  config =
    lib.mkIf TEMPLATE.enable {
    };
}
