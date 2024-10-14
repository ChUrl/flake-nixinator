{
  lib,
  mylib,
  colorKeys,
  ...
}:
with lib;
with mylib.modules; {
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

  # Internal-only options

  keys = mkOption {
    type = types.listOf types.str;
    description = "The names of all possible colors";
    default = colorKeys;
  };

  hex = mkOption {
    type = types.attrs;
    description = "Colors in \"RRGGBB\" hexadecimal format";
  };

  rgbString = mkOption {
    type = types.attrs;
    description = "Colors in \"RR,GG,BB\" decimal format";
  };

  rgb = mkOption {
    type = types.attrs;
    description = "Colors in [RR GG BB] decimal format";
  };
}
