{
  lib,
  mylib,
  ...
}: {
  enable = mylib.modules.mkBoolOption true ''
    Install and decrypt the sops secrets.
    Hosts that have no age key (e.g. the WSL host) disable this. Their modules
    must then not declare any sops secrets, and the consumers in
    system/default.nix and the home config are skipped as well.
  '';

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
