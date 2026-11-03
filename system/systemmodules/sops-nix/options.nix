{
  lib,
  mylib,
  ...
}: {
  secrets = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Secrets from secrets.yaml that are installed and owned by the
      interactive user. Only used by system modules; secrets needed by the
      user session are declared in the respective home-manager module.
    '';
    example = ''
      ["docker-password"]
    '';
    default = [];
  };

  bootSecrets = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Secrets that have to be available before the users are created
      (neededForUsers). They can't be owned by anyone.
    '';
    example = ''
      ["user-password"]
    '';
    default = [];
  };
}
