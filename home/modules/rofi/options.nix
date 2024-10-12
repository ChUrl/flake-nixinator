{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Rofi";

  theme = mkOption {
    type = types.str;
    example = "Three-Bears";
    description = "Color theme to use";
  };
}
