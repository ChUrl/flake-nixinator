{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable opt-in state using impermanence.";

  # TODO: Options for host-specific config
}
