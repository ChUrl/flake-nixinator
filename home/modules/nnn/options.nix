{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "NNN File Manager";
}
