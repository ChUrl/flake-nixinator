{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Firefox";
  wayland = mkBoolOption false "Enable firefox wayland support";
  vaapi = mkBoolOption false "Enable firefox vaapi support";
  disableTabBar = mkBoolOption false "Disable the firefox tab bar (for TST)";
  defaultBookmarks = mkBoolOption false "Preset standard bookmarks and folders";
  gnomeTheme = mkBoolOption false "Use Firefox gnome theme (rafaelmardojai)";
}
