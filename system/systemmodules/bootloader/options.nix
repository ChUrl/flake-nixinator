{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "Enable boot loader configuration";

  loader = lib.mkOption {
    type = lib.types.enum [
      "grub"
      "systemd-boot"
      "lanzaboote"
    ];
    description = "What boot loader to use";
    example = "systemd-boot";
    default = "systemd-boot";
  };

  systemd-boot.bootDevice = lib.mkOption {
    type = lib.types.str;
    description = "The path to the boot partition";
    example = "/boot/efi";
    default = "/boot/efi";
  };

  grub.bootDevice = lib.mkOption {
    type = lib.types.str;
    description = "The path to the boot partition";
    example = "/dev/sda";
    default = "/dev/sda";
  };
}
