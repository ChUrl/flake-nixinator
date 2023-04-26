{
  lib
}:
with lib;
{
  enable = mkEnableOpt "Hyprland Window Manager + Compositor";

  theme = mkOption {
    type = types.str;
    description = "Wallpaper and colorscheme to use";
  };  
}