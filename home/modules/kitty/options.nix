{
  lib,
  mylib,
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Kitty";
}
