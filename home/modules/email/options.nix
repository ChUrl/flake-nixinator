{
  lib,
  mylib
}:
with lib;
with mylib.modules;
{
  enable = mkEnableOpt "Email";
  autosync = mkEnableOpt "Automatically call \"notmuch new\" via systemd timer";
  imapnotify = mkEnableOpt "Use imapnotify to sync and index mail automatically";

  kmail = {
    enable = mkEnableOpt "Kmail";
    autostart = mkEnableOpt "Autostart Kmail";
  };
}