{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable jellyfin-tui";
}
