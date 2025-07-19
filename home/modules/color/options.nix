{
  lib,
  mylib,
  ...
}: {
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
}
