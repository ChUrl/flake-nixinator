{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable lazygit";
}
