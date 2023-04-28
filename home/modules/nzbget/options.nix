{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Enable NzbGet";

  mainDir = mkOption {
    type = types.str;
    default = "~/Videos/NzbGet";
    description = "The folder, where nzbget stores downloaded data.";
  };
}
