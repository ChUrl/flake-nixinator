{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
    ];
    initrd.kernelModules = [];
    kernelModules = [
      "kvm-intel"
      "ip_tables" # Required by wireguard docker container
    ];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2d1b1f62-f008-4562-906e-5a63d854b18b";
      fsType = "ext4";
      options = ["defaults" "rw" "relatime"];
    };

    # Synology DS223j

    "/media/synology-syncthing" = {
      device = "192.168.86.15:/volume1/DockerVolumes";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    # TrueNAS

    "/media/Movie" = {
      device = "192.168.86.20:/mnt/Seagate4TB/Movies";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    "/media/Show" = {
      device = "192.168.86.20:/mnt/Seagate4TB/Shows";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    "/media/TV-Music" = {
      device = "192.168.86.20:/mnt/Seagate4TB/Music";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };
  };

  swapDevices = [
    {
      device = "/var/swap";
      size = 1024 * 4; # Without hibernation 4.0 GB to 0.5 x RAM
    }
  ];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = false;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
