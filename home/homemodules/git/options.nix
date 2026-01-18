{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable git";

  userName = lib.mkOption {
    type = lib.types.str;
    description = "The user's name";
    example = ''
      "John Doe"
    '';
  };

  userEmail = lib.mkOption {
    type = lib.types.str;
    description = "The user's email address";
    example = ''
      "john@doe.com"
    '';
  };

  signCommits = lib.mkEnableOption "Enable commit signing";
}
