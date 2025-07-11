{
  lib,
  mylib,
  ...
}: {
  secrets = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    description = "The secrets to expose on this host";
    example = ''
      christoph = [
        "docker-password"
      ];
    '';
    default = [];
  };

  bootSecrets = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    description = "The secrets to expose on this host earlier in the boot process";
    example = ''
      christoph = [
        "user-password"
      ];
    '';
    default = [];
  };
}
