{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Ranger";
  preview = mkBoolOpt false "Enable Ranger image preview";
}
