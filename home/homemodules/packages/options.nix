{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable common packages";
}
