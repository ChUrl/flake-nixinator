{
  lib,
  mylib,
  colorKeys,
  ...
}:
with lib;
with mylib.modules; let
  mkColorOption = key: {
    light.${key} = mkOption {
      type = types.str;
      description = "The RGB hex color value for ${key} in the light scheme";
      example = "EEEEEE";
    };
    dark.${key} = mkOption {
      type = types.str;
      description = "The RGB hex color value for ${key} in the dark scheme";
      example = "111111";
    };
  };
in
  (lib.pipe colorKeys [
    (builtins.map mkColorOption)
    lib.mergeAttrsList
  ])
  // {
    enable = mkEnableOption "Enable color schemes";

    lightScheme = mkOption {
      type = types.str;
      description = "The color scheme to use for light colors";
      example = "catppuccin-latte";
      default = "catppuccin-latte";
    };

    darkScheme = mkOption {
      type = types.str;
      description = "The color scheme to use for dark colors";
      example = "catppuccin-mocha";
      default = "catppuccin-mocha";
    };

    font = mkOption {
      type = types.str;
      description = "The font to use";
      example = "JetBrainsMono Nerd Font Mono";
      default = "JetBrainsMono Nerd Font Mono";
    };

    keys = mkOption {
      type = types.listOf types.str;
      description = "The names of all possible colors";
      default = colorKeys;
    };

    light = mkOption {
      type = types.attrs;
      description = "Colors belonging to the selected light scheme";
    };

    dark = mkOption {
      type = types.attrs;
      description = "Colors belonging to the selected dark scheme";
    };
  }