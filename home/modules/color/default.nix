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
    mkStringColorAssignment = defs: key: {${key} = "#${defs.${key}}";};
    mkRgbColorAssignment = defs: key: {${key} = mylib.color.hexToRGB defs.${key};};
    mkRgbStringColorAssignment = defs: key: {${key} = mylib.color.hexToRGBString "," defs.${key};};
  in {
    # This module sets its own options
    # to the values specified in a colorscheme file.
    # TODO: This is fucking stupid. Add an option to set a colorscheme,
    #       then provide a single hex/rgb/rgbString set, not this light/dark shit.
    modules.color = {
      hex = {
        light =
          colorKeys
          |> builtins.map (mkColorAssignment lightDefs)
          |> lib.mergeAttrsList;

        dark =
          colorKeys
          |> builtins.map (mkColorAssignment darkDefs)
          |> lib.mergeAttrsList;
      };

      hexString = {
        light =
          colorKeys
          |> builtins.map (mkStringColorAssignment lightDefs)
          |> lib.mergeAttrsList;

        dark =
          colorKeys
          |> builtins.map (mkStringColorAssignment darkDefs)
          |> lib.mergeAttrsList;
      };

      rgb = {
        light =
          colorKeys
          |> builtins.map (mkRgbColorAssignment lightDefs)
          |> lib.mergeAttrsList;

        dark =
          colorKeys
          |> builtins.map (mkRgbColorAssignment darkDefs)
          |> lib.mergeAttrsList;
      };

      rgbString = {
        light =
          colorKeys
          |> builtins.map (mkRgbStringColorAssignment lightDefs)
          |> lib.mergeAttrsList;

        dark =
          colorKeys
          |> builtins.map (mkRgbStringColorAssignment darkDefs)
          |> lib.mergeAttrsList;
      };
    };
  };
}
