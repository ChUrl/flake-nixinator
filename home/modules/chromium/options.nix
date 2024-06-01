{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Chromium";
  google = mkEnableOpt "Google Chrome";
}
