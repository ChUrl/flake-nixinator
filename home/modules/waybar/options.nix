{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Waybar";

  monitor = mkOption {
    type = types.str;
    example = "HDMI-A-1";
    description = "What monitor to display the Waybar on";
  };
}
