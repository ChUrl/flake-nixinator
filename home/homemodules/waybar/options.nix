{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Waybar";

  monitors = mkOption {
    type = types.listOf types.str;
    example = ''["HDMI-A-1", "DP-1"]'';
    description = "What monitor to display the Waybar on";
  };
}
