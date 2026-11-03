{
  lib,
  mylib,
  ...
}: {
  directories = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = ''
      Paths relative to $HOME that should be persisted. HM modules can't set
      system options, so they declare them here and the system impermanence
      module folds them in (mode 0755, owned by the user).
    '';
    example = ''
      [".config/obsidian"]
    '';
    default = [];
  };
}
