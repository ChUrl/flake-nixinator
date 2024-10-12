{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Gaming module";

  # discordElectron.enable = mkEnableOption "Discord (Electron) (nixpkgs)";
  # discordChromium.enable = mkEnableOption "Discord (Chromium)";
  prism.enable = mkEnableOption "PrismLauncher for Minecraft (flatpak)";
  bottles.enable = mkEnableOption "Bottles (flatpak)";
  # dwarffortress.enable = mkEnableOption "Dwarf Fortress";
  cemu.enable = mkEnableOption "Cemu (nixpkgs)";

  steam = {
    enable = mkEnableOption "Steam (flatpak)";
    gamescope = mkBoolOption false "Enable the gamescope micro compositor (flatpak)";
    adwaita = mkBoolOption false "Enable the adwaita-for-steam skin";
    protonup = mkBoolOption false "Enable ProtonUP-QT";
  };
}
