{
  config,
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.color;

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
    lightDefs = import ./${cfg.lightScheme}.nix;
    darkDefs = import ./${cfg.darkScheme}.nix;

    mkLightColorAssignment = key: {${key} = lightDefs.${key};};
    mkDarkColorAssignment = key: {${key} = darkDefs.${key};};
  in
    mkIf cfg.enable {
      # This module sets its own options
      # to the values specified in a colorscheme file.
      modules.color.light = lib.pipe colorKeys [
        (builtins.map mkLightColorAssignment)
        lib.mergeAttrsList
      ];

      modules.color.dark = lib.pipe colorKeys [
        (builtins.map mkDarkColorAssignment)
        lib.mergeAttrsList
      ];
    };
}
