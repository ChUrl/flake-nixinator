{
  lib,
  mylib,
  pkgs,
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
in rec {
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

  cursor = lib.mkOption {
    type = lib.types.str;
    description = "The cursor to use";
    example = "Bibata-Modern-Classic";
    default = "Bibata-Modern-Classic";
  };

  cursorSize = lib.mkOption {
    type = lib.types.int;
    description = "The cursor size";
    example = 24;
    default = 24;
  };

  cursorPackage = lib.mkOption {
    type = lib.types.package;
    description = "The cursor package";
    example = pkgs.bibata-cursors;
    default = pkgs.bibata-cursors;
  };

  iconTheme = lib.mkOption {
    type = lib.types.str;
    description = "The icon theme to use";
    example = "Papirus";
    default = "Papirus";
  };

  iconPackage = lib.mkOption {
    type = lib.types.package;
    description = "The icon theme package";
    example = pkgs.papirus-icon-theme;
    default = pkgs.papirus-icon-theme;
  };

  extraPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    description = "Extra packages to install";
    example = ''
      [
        pkgs.bibata-cursors
      ]
    '';
    default = [];
  };

  # This option is set automatically
  wallpapers = let
    # Collect all the available wallpapers.
    # We can't do this in default.nix as the value
    # needs to be available during option evaluation.
    wallpapers = let
      rmFileExt = file: builtins.replaceStrings [".jpg"] [""] file;

      rmBasePath = file: let
        matches = builtins.match "/.*/(.*)" file;
      in
        if matches == null
        then file
        else (builtins.head matches);
    in
      lib.filesystem.listFilesRecursive ../../../wallpapers
      |> builtins.map builtins.toString
      |> builtins.map rmFileExt
      |> builtins.map rmBasePath;
  in
    lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      description = "The available wallpapers";
      default = wallpapers;
    };

  wallpaper = lib.mkOption {
    type = lib.types.enum wallpapers.default;
    description = "The wallpaper to use";
    example = "Foggy-Lake";
    default = "Foggy-Lake";
  };

  # Some semantic aliases for colors

  accent = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The accent color to use";
    example = "mauve";
    default = "mauve";
  };

  accentHl = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The accented accent color to use";
    example = "pink";
    default = "pink";
  };

  accentDim = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The dim accent color to use";
    example = "lavender";
    default = "lavender";
  };

  accentText = lib.mkOption {
    type = lib.types.enum colorKeys;
    description = "The text color to use for accents";
    example = "base";
    default = "base";
  };

  # These options will be populated automatically.

  hex = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Colors in \"RRGGBB\" hexadecimal format";
  };

  hexS = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Colors in \"#RRGGBB\" hexadecimal format";
  };

  rgb = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Colors in [RR GG BB] decimal format";
  };

  rgbS = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Colors in \"RR,GG,BB\" decimal format";
  };
}
