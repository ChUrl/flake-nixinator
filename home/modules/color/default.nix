{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) color;
in {
  options.modules.color = import ./options.nix {inherit lib mylib;};

  config = let
    lightDefs = import ./schemes/${color.lightScheme}.nix;
    darkDefs = import ./schemes/${color.darkScheme}.nix;

    # Assignments will be generated from those keys
    colorKeys = builtins.attrNames lightDefs;

    mkColorAssignment = defs: key: {${key} = defs.${key};};
    mkRgbColorAssignment = defs: key: {${key} = mylib.color.hexToRGB defs.${key};};
    mkRgbStringColorAssignment = defs: key: {${key} = mylib.color.hexToRGBString "," defs.${key};};
  in {
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
