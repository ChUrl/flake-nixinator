{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_231623801519";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              # NOTE: The disk identification uses /dev/disk/by-partlabel,
              #       so make sure this matches the actual partlabel!!!
              label = "EFI";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=077"];
              };
            };
            luks = {
              label = "LUKS";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";

                extraOpenArgs = [
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];

                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];

                  # Disable for interactive password entry
                  # keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = ["/tmp/additionalSecret.key"];

                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "NIXOS" "-f"];
                  subvolumes = {
                    "root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
