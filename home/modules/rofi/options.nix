{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Rofi";

  theme = mkOption {
    type = types.str;
    example = "Three-Bears";
    description = "Color theme to use";
  };
}
