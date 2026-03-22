{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable ssh";
}
