{
  lib,
  mylib,
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Flatpak module";
  fontFix = mkBoolOpt true "Link fonts to ~/.local/share/fonts so flatpak apps can find them";
  iconFix = mkBoolOpt true "Link icons to ~/.local/share/icons so flatpak apps can find them";
  autoUpdate = mkBoolOpt false "Update flatpak apps on nixos-rebuild";
  autoPrune = mkBoolOpt false "Remove unused packages on nixos-rebuild";

  # TODO: Add library function to make this easier
  # TODO: The flatpak name should be included and a list of all enabled apps should be available
  # TODO: Do this for strings + packages
  discord.enable = mkEnableOpt "Discord";
  spotify.enable = mkEnableOpt "Spotify";
  flatseal.enable = mkEnableOpt "Flatseal";
  bottles.enable = mkEnableOpt "Bottles";
  obsidian.enable = mkEnableOpt "Obsidian";
  jabref.enable = mkEnableOpt "Jabref";
  # xwaylandvideobridge = mkEnableOpt "XWayland Video Bridge"; # TODO

  # TODO: Can I use extraInstall = { "com.valve.Steam" = true/false; } and pass the module option as value?
  # This is mainly used by other modules to allow them to use flatpak packages
  extraInstall = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Flatpaks that will be installed additionally";
  };

  # This doesn't uninstall if any flatpak is still present in the extraInstall list
  extraRemove = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Flatpaks that will be removed additionally (use with extraInstall)";
  };

  extraOverride = mkOption {
    type = types.listOf types.attrs;
    default = [];
    # TODO: Change the format to { "com.usebottles.bottles" = [ "~/Documents" "~/Downloads" ]; }
    # TODO: This requires that the lists of the same key are being merged recursively, mkMerge would override the key
    example = [{"com.usebottles.bottles" = "\${config.home.homeDirectory}/Documents";}];
    description = "Additional overrides";
  };

  extraGlobalOverride = mkOption {
    type = types.listOf types.str;
    default = [];
    example = ["\${config.home.homeDirectory}/Documents:ro"];
    description = "Additional global overrides";
  };
}
