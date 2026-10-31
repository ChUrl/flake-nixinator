{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable opt-in state using impermanence.";

  generationRetentionDays = lib.mkOption {
    type = lib.types.ints.positive;
    default = 7;
    description = ''
      How long retired generations of the ephemeral subvolumes (root, home)
      are kept. Pruning runs from a systemd timer during normal operation,
      not from the initrd.
    '';
  };
}
