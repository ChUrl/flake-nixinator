{
  lib,
  mylib,
  ...
}: let
  colorKeys = [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"

    "text"
    "subtext1"
    "subtext0"
    "overlay2"
    "overlay1"
    "overlay0"
    "surface2"
    "surface1"
    "surface0"
    "base"
    "mantle"
    "crust"
  ];
in {
  scheme = lib.mkOption {
    type = lib.types.enum [
      "catppuccin-latte"
      "catppuccin-mocha"
    ];
    description = "The color scheme to use";
    example = "catppuccin-mocha";
    default = "catppuccin-mocha";
  };

  font = lib.mkOption {
    type = lib.types.str;
    description = "The font to use";
    example = "JetBrainsMono Nerd Font Mono";
    default = "JetBrainsMono Nerd Font Mono";
  };

  # These options will be populated automatically.

  hex = lib.mkOption {
    type = lib.types.attrs;
    description = "Colors in \"RRGGBB\" hexadecimal format";
  };

  hexS = lib.mkOption {
    type = lib.types.attrs;
    description = "Colors in \"#RRGGBB\" hexadecimal format";
  };

  rgb = lib.mkOption {
    type = lib.types.attrs;
    description = "Colors in [RR GG BB] decimal format";
  };

  rgbS = lib.mkOption {
    type = lib.types.attrs;
    description = "Colors in \"RR,GG,BB\" decimal format";
  };

  # Some semantic aliases for colors
  bg = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The color to use as background";
    example = "base";
    default = "base";
  };

  text = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The text color to use";
    example = "text";
    default = "text";
  };

  accent = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The accent color to use";
    example = "mauve";
    default = "mauve";
  };

  accentHL = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The accented accent color to use";
    example = "pink";
    default = "pink";
  };

  accentText = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The text color to use for accents";
    example = "base";
    default = "base";
  };
}
