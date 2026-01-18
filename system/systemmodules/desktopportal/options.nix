{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable XDG desktop portals";
  termfilechooser.enable = lib.mkEnableOption "Enable xdg-desktop-portal-termfilechooser";
  hyprland.enable = lib.mkEnableOption "Configure portals for Hyprland";
  niri.enable = lib.mkEnableOption "Configure portals for Niri";
}
