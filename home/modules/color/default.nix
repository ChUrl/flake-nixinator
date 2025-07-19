{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) color;
in {
  options.modules.color = import ./options.nix {inherit lib mylib;};

  config = let
    colorDefs = import ./schemes/${color.scheme}.nix;

    mkColorAssignment = defs: key: {${key} = defs.${key};};
    mkStringColorAssignment = defs: key: {${key} = "#${defs.${key}}";};
    mkRgbColorAssignment = defs: key: {${key} = mylib.color.hexToRGB defs.${key};};
    mkRgbStringColorAssignment = defs: key: {${key} = mylib.color.hexToRGBString "," defs.${key};};
  in {
    # Helper script that processes a visual mode selection and replaces
    # referenced colors in-place with their counterparts in this module.
    # Usage: ":'<,'>!applyColors<cr>"
    home.packages = let
      mkPythonColorDef = name: value: "    '${name}': '${value}',";

      applyColors =
        pkgs.writers.writePython3Bin
        "applyColors"
        {
          doCheck = false;
        }
        (
          builtins.concatStringsSep "\n" [
            "colors: dict[str, str] = {"
            (config.modules.color.hex
              |> builtins.mapAttrs mkPythonColorDef
              |> builtins.attrValues
              |> builtins.concatStringsSep "\n")
            "}"
            (builtins.readFile ./applyColors.py)
          ]
        );
    in [applyColors];

    # This module sets its own options to the values specified in a colorscheme file.
    modules.color = {
      # RRGGBB (0-F)
      hex =
        colorDefs
        |> builtins.attrNames
        |> builtins.map (mkColorAssignment colorDefs)
        |> lib.mergeAttrsList;

      # #RRGGBB (0-F)
      hexS =
        colorDefs
        |> builtins.attrNames
        |> builtins.map (mkStringColorAssignment colorDefs)
        |> lib.mergeAttrsList;

      # [RR GG BB] (0-255)
      rgb =
        colorDefs
        |> builtins.attrNames
        |> builtins.map (mkRgbColorAssignment colorDefs)
        |> lib.mergeAttrsList;

      # RR,GG,BB (0-255)
      rgbS =
        colorDefs
        |> builtins.attrNames
        |> builtins.map (mkRgbStringColorAssignment colorDefs)
        |> lib.mergeAttrsList;
    };
  };
}
