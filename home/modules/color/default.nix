{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) color;

  # Options and assignments will be generated from those keys
  colorKeys = [
    # Colors
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

    # 50 shades of gray
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
  options.modules.color = import ./options.nix {inherit lib mylib colorKeys;};

  config = let
    lightDefs = import ./schemes/${color.lightScheme}.nix;
    darkDefs = import ./schemes/${color.darkScheme}.nix;

    mkColorAssignment = defs: key: {${key} = defs.${key};};
    mkRgbColorAssignment = defs: key: {${key} = mylib.color.hexToRGB defs.${key};};
    mkRgbStringColorAssignment = defs: key: {${key} = mylib.color.hexToRGBString "," defs.${key};};
  in
    lib.mkIf color.enable {
      # This module sets its own options
      # to the values specified in a colorscheme file.
      modules.color = {
        hex = {
          light = lib.pipe colorKeys [
            (builtins.map (mkColorAssignment lightDefs))
            lib.mergeAttrsList
          ];

          dark = lib.pipe colorKeys [
            (builtins.map (mkColorAssignment darkDefs))
            lib.mergeAttrsList
          ];
        };

        rgb = {
          light = lib.pipe colorKeys [
            (builtins.map (mkRgbColorAssignment lightDefs))
            lib.mergeAttrsList
          ];

          dark = lib.pipe colorKeys [
            (builtins.map (mkRgbColorAssignment darkDefs))
            lib.mergeAttrsList
          ];
        };

        rgbString = {
          light = lib.pipe colorKeys [
            (builtins.map (mkRgbStringColorAssignment lightDefs))
            lib.mergeAttrsList
          ];

          dark = lib.pipe colorKeys [
            (builtins.map (mkRgbStringColorAssignment darkDefs))
            lib.mergeAttrsList
          ];
        };
      };
    };
}
