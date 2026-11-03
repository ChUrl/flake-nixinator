{
  # IONOS VPS: /dev/vda, 10 GB virtio disk.
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";

        content = {
          type = "gpt";

          partitions = {
            bios = {
              size = "1M";
              type = "EF02"; # BIOS boot partition (grub core.img)
            };

            boot = {
              size = "512M";
              type = "8300"; # Linux filesystem
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };

            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
