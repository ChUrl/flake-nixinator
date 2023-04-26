{
  lib
}:
with lib;
{
  enable = mkEnableOpt "Ranger";
  preview = mkBoolOpt false "Enable Ranger image preview";
}