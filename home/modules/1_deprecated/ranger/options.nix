{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Ranger";
  preview = mkBoolOption false "Enable Ranger image preview";
}
