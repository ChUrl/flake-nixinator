{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Chromium";
  google = mkEnableOption "Google Chrome";
}
