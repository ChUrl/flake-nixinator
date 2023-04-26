{
  lib,
  mylib,
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Nextcloud Client";
  autostart = mkBoolOpt false "Autostart the Nextcloud client (systemd)";
}
