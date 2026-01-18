{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable the fcitx5 input method";
}
