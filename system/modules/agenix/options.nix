{
  lib,
  mylib,
  ...
}: {
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
}
