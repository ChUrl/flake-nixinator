{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable tmux";
}
