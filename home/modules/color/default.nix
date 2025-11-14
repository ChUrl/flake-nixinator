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

  config = {
    home.packages = let
      mkPythonColorDef = name: value: "    '${name}': '${value}',";

      # Helper script that processes a visual mode selection and replaces
      # referenced colors in-place with their counterparts in this module.
      # Usage: ":'<,'>!applyColors<cr>"
      applyColors =
        pkgs.writers.writePython3Bin
        "applyColors"
        {
          doCheck = false;
        }
        (builtins.concatStringsSep "\n" [
          "colors: dict[str, str] = {"
          (color.hex
            |> builtins.mapAttrs mkPythonColorDef
            |> builtins.attrValues
            |> builtins.concatStringsSep "\n")
          "}"
          (builtins.readFile ./applyColors.py)
        ]);

      mkBashColorEcho = let
        pastel = "${pkgs.pastel}/bin/pastel";
      in
        name: value: ''printf "%-12s" " ${name}:" && ${pastel} color "${value}" | ${pastel} format hex'';

      # Helper script that prints the color scheme to the terminal
      printNixColors =
        pkgs.writeShellScriptBin
        "printNixColors"
        (builtins.concatStringsSep "\n" [
          ''echo " ${color.scheme}:"''
          ''echo ${lib.concatStrings (lib.replicate 20 "=")}''
          (color.hexS
            |> builtins.mapAttrs mkBashColorEcho
            |> builtins.attrValues
            |> builtins.concatStringsSep "\n")
          ''echo ${lib.concatStrings (lib.replicate 20 "=")}''
        ]);
    in
      [
        applyColors
        printNixColors
      ]
      ++ color.extraPackages;

    # This module sets its own options to the values specified in a colorscheme file.
    modules.color = let
      scheme = import ./schemes/${color.scheme}.nix;

      # Add the aliases
      colorDefs =
        scheme
        // {
          accent = scheme.${color.accent};
          accentHl = scheme.${color.accentHl};
          accentDim = scheme.${color.accentDim};
          accentText = scheme.${color.accentText};
        };

      mkColorAssignment = key: {
        ${key} = colorDefs.${key};
      };
      mkStringColorAssignment = key: {
        ${key} = "#${colorDefs.${key}}";
      };
      mkRgbColorAssignment = key: {
        ${key} = mylib.color.hexToRGB colorDefs.${key};
      };
      mkRgbStringColorAssignment = key: {
        ${key} = mylib.color.hexToRGBString "," colorDefs.${key};
      };
    in {
      # RRGGBB (0-F)
      hex =
        colorDefs
        |> builtins.attrNames
        |> builtins.map mkColorAssignment
        |> lib.mergeAttrsList;

      # #RRGGBB (0-F)
      hexS =
        colorDefs
        |> builtins.attrNames
        |> builtins.map mkStringColorAssignment
        |> lib.mergeAttrsList;

      # [RR GG BB] (0-255)
      rgb =
        colorDefs
        |> builtins.attrNames
        |> builtins.map mkRgbColorAssignment
        |> lib.mergeAttrsList;

      # RR,GG,BB (0-255)
      rgbS =
        colorDefs
        |> builtins.attrNames
        |> builtins.map mkRgbStringColorAssignment
        |> lib.mergeAttrsList;
    };
  };
}
