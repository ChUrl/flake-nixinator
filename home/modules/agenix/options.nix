{
  lib,
  mylib,
  ...
}: let
  mkSecret = file:
    lib.mkOption {
      type = lib.types.path;
      default = file;
    };
in {
  secrets = lib.mkOption {
    type = lib.types.attrs;
    description = "The secret files managed by agenix (and their associated keys)";
    example = ''
      {
        christoph = [
          "heidi-discord-token"
          "kopia-password"
          "kopia-server-username"
          "kopia-server-password"
        ];
      }
    '';

    default = {};
  };

  heidi-discord-token = mkSecret ./heidi-discord-token.age;
  kopia-user-password = mkSecret ./kopia-user-password.age;
  kopia-server-user = mkSecret ./kopia-server-user.age;
  kopia-server-password = mkSecret ./kopia-server-password.age;
}
