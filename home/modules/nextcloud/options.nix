{
  lib
}:
with lib;
{
  enable = mkEnableOpt "Nextcloud Client";
  autostart = mkBoolOpt false "Autostart the Nextcloud client (systemd)";
}