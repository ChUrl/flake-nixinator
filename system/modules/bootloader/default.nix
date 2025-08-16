{
  pkgs,
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) bootloader;
in {
  options.modules.bootloader = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf bootloader.enable (lib.mkMerge [
    {
      boot.loader = {
        timeout = 10;
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = bootloader.systemd-boot.bootDevice;
      };
    }
    (lib.mkIf (bootloader.loader == "systemd-boot") {
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
        consoleMode = "max";
      };
    })
    (lib.mkIf (bootloader.loader == "grub") {
      boot.loader.grub = {
        enable = true;
        useOSProber = true;
        device = bootloader.grub.bootDevice;
      };
    })
    (lib.mkIf (bootloader.loader == "lanzaboote") {
      environment.systemPackages = with pkgs; [
        sbctl
      ];

      # Lanzaboote replaces systemd-boot
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;

        # WARN: Make sure to persist this if using impermanence!
        pkiBundle = "/var/lib/sbctl";
      };
    })
  ]);
}
