{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Email";
  autosync = mkEnableOption "Automatically call \"notmuch new\" via systemd timer";
  imapnotify = mkEnableOption "Use imapnotify to sync and index mail automatically";

  kmail = {
    enable = mkEnableOption "Kmail";
    autostart = mkEnableOption "Autostart Kmail";
  };
}
