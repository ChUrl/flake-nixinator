{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Gaming module";

  # discordElectron.enable = mkEnableOpt "Discord (Electron) (nixpkgs)";
  # discordChromium.enable = mkEnableOpt "Discord (Chromium)";
  prism.enable = mkEnableOpt "PrismLauncher for Minecraft (flatpak)";
  bottles.enable = mkEnableOpt "Bottles (flatpak)";
  # dwarffortress.enable = mkEnableOpt "Dwarf Fortress";

  steam = {
    enable = mkEnableOpt "Steam (flatpak)";
    gamescope = mkBoolOpt false "Enable the gamescope micro compositor (flatpak)";
    adwaita = mkBoolOpt false "Enable the adwaita-for-steam skin";
    protonup = mkBoolOpt false "Enable ProtonUP-QT";
  };
}
