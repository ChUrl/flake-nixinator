{
  lib,
  mylib,
  ...
}: {
  # Server service template. Copy this directory, rename TEMPLATE everywhere
  # and add it to system/services/nixos/default.nix.
  enable = lib.mkEnableOption "TEMPLATE";
}
