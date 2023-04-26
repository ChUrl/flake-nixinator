{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOpt "Hyprland Window Manager + Compositor";

  kb-layout = mkOption {
    type = types.str;
    description = "Keyboard layout to use";
  };

  kb-variant = mkOption {
    type = types.str;
    description = "Keyboard layout variant";
  };

  theme = mkOption {
    type = types.str;
    description = "Wallpaper and colorscheme to use";
  };

  monitors = mkOption {
    type = types.str;
    description = "Hyprland monitor configuration";
  };
}
