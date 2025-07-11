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
    initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
    initrd.kernelModules = [];
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2d1b1f62-f008-4562-906e-5a63d854b18b";
      fsType = "ext4";
      options = ["defaults" "rw" "relatime"];
    };

    "/home/christoph/ssd" = {
      device = "/dev/disk/by-uuid/ff42f57c-cd45-41ea-a0ee-640e638b38bc";
      fsType = "ext4";
      options = ["defaults" "rw" "relatime"];
    };

    # Synology DS223j

    "/media/synology-syncthing" = {
      device = "192.168.86.15:/volume1/DockerVolumes";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    # SG Exos Mirror Shares

    "/media/Movie" = {
      device = "192.168.86.20:/mnt/SG Exos Mirror 18TB/Movie";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    "/media/Show" = {
      device = "192.168.86.20:/mnt/SG Exos Mirror 18TB/Show";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };

    "/media/TV-Music" = {
      device = "192.168.86.20:/mnt/SG Exos Mirror 18TB/Music";
      fsType = "nfs";
      options = ["defaults" "rw" "relatime" "_netdev" "bg" "soft"];
    };
  };

  swapDevices = [];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = false;
    nvidia-container-toolkit.enable = true;

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      modesetting.enable = false;
      open = false; # GTX 1070 is too old for open drivers
      nvidiaSettings = false;
    };

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl

        nvidia-vaapi-driver
      ];
    };
  };

  environment.variables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct"; # egl
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
