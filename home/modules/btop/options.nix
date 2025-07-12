{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable the btop system monitor";

  cuda = lib.mkEnableOption "Enable Cuda support for btop";
}
