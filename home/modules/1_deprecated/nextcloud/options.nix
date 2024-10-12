{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Nextcloud Client";
  autostart = mkBoolOption false "Autostart the Nextcloud client (systemd)";
}
