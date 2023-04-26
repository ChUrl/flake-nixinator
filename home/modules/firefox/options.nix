{
  lib,
  mylib
}:
with lib;
with mylib.modules;
{
  enable = mkEnableOpt "Firefox";
  wayland = mkBoolOpt false "Enable firefox wayland support";
  vaapi = mkBoolOpt false "Enable firefox vaapi support";
  disableTabBar = mkBoolOpt false "Disable the firefox tab bar (for TST)";
  defaultBookmarks = mkBoolOpt false "Preset standard bookmarks and folders";
  gnomeTheme = mkBoolOpt false "Use Firefox gnome theme (rafaelmardojai)";
}