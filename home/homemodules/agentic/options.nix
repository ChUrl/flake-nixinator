{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "AI coding agents";

  extraPackages = mkOption {
    type = types.listOf types.package;
    default = [];
    description = "Extra packages available to OpenCode.";
  };

  skills = mkOption {
    type = types.attrsOf (types.oneOf [types.lines types.path types.str]);
    default = {};
    example = {
      git-release = ''
        ---
        name: git-release
        description: Create consistent releases and changelogs
        ---
      '';
    };
    description = ''
      Additional OpenCode skills, merged into the built-in ones.
      The key becomes the skill directory name, the value is either inline
      content, a file, or a directory containing a SKILL.md.
    '';
  };
}
