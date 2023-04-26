{
  lib
}:
with lib;
{
    enable = mkEnableOpt "Gnome Desktop";
    # TODO: Add option for dash-to-dock
    extensions = mkBoolOpt false "Enable Gnome shell-extensions";

    # TODO: Add other themes, whitesur for example
    theme = {
      papirusIcons = mkBoolOpt false "Enable the Papirus icon theme";
      numixCursor = mkBoolOpt false "Enable the Numix cursor theme";
      wallpaper = mkOption {
        type = types.str;
        default = "constructionsite";
        description = "What wallpaper to use";
      };
    };

    settings = {
    };
}