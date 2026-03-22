{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable fastfetch";
}
