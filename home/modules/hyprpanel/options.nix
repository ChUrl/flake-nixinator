{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Enable Hyprpanel";
  systemd.enable = mkEnableOption "Start using systemd";
}
