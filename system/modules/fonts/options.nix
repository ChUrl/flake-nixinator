{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable fonts configuration";

  defaultSerifFont = lib.mkOption {
    type = lib.types.str;
    description = "Select default serif font";
    example = ''
      "Noto Serif CJK SC"
    '';
    default = "Noto Serif CJK SC";
  };

  defaultSansSerifFont = lib.mkOption {
    type = lib.types.str;
    description = "Select default sans-serif font";
    example = ''
      "Noto Sans CJK SC"
    '';
    default = "Noto Sans CJK SC";
  };

  defaultMonoFont = lib.mkOption {
    type = lib.types.str;
    description = "Select default monospace font";
    example = ''
      "MonoLisa Alt Script"
    '';
    default = "MonoLisa Alt Script";
  };

  fallbackSerifFonts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Select fallback serif fonts";
    example = ''
      [
        "Noto Serif CJK SC"
      ]
    '';
    default = [];
  };

  fallbackSansSerifFonts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Select fallback sans-serif fonts";
    example = ''
      [
        "Noto Sans CJK SC"
      ]
    '';
    default = [];
  };

  fallbackMonoFonts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Select fallback monospace fonts";
    example = ''
      [
        "JetBrainsMono Nerd Font Mono"
      ]
    '';
    default = [
      "JetBrainsMono Nerd Font Mono"
    ];
  };
}
