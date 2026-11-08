{
  lib,
  mylib,
  ...
}: {
  enable = lib.mkEnableOption "declarative live-OS VMs with immutable images";

  # One launcher script per declared live image. The guest cannot
  # write anywhere persistent, so there is no state to keep or restore.
  live = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
      options = {
        source = lib.mkOption {
          type = lib.types.submodule {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                description = "Download URL of the live image (ISO or raw disk image).";
              };

              hash = lib.mkOption {
                type = lib.types.str;
                description = "SRI hash of the image, e.g. from `nix store prefetch-file --json <url>`.";
              };
            };
          };
          description = "Pinned image source. Fetched into the Nix store at build time, so the URL has to be reachable during rebuilds and the hash has to be updated on every release.";
        };

        binary = lib.mkOption {
          type = lib.types.str;
          default = "${name}-vm";
          description = "Name of the launcher command added to PATH.";
        };

        memorySize = lib.mkOption {
          type = lib.types.ints.positive;
          default = 4096;
          description = "Memory allocated to the VM, in MiB.";
        };

        cores = lib.mkOption {
          type = lib.types.ints.positive;
          default = 2;
          description = "Number of virtual CPU cores.";
        };

        display = lib.mkOption {
          type = lib.types.enum ["gtk" "sdl" "none"];
          default = "gtk";
          description = ''
            Guest display backend. "none" makes the machine headless; combine
            it with an extra "-vnc :1" (via "extraArgs" or the launcher) to
            connect a viewer of your choice.
          '';
        };

        vga = lib.mkOption {
          type = lib.types.enum ["virtio" "std"];
          default = "virtio";
          description = ''
            Guest graphics device. "virtio" is the modern choice and works
            with every Linux live image; use "std" for maximum compatibility
            with exotic guests.
          '';
        };

        # "cdrom" for .iso images, "disk" for raw .img images
        media = lib.mkOption {
          type = lib.types.enum ["cdrom" "disk"];
          default = "cdrom";
          description = "How the image is exposed to the guest and booted from.";
        };

        diskSize = lib.mkOption {
          type = lib.types.nullOr lib.types.ints.positive;
          default = null;
          description = ''
            Virtual size of the guest's boot disk, in MiB. Only used with
            media = "disk": an ephemeral qcow2 overlay is created in
            $XDG_RUNTIME_DIR, backed by the immutable image and grown to
            this size.
          '';
        };

        usb = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Expose disk images as a USB mass storage device instead of
            virtio-blk. Set to false for the faster virtio-blk if the
            image boots from any disk.
          '';
        };

        usbController = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Attach a USB controller to the guest even when media = "cdrom".
            Required for usb-host passthrough (QEMU's pc and q35 machines
            no longer provide a USB bus) and for the usb-storage disk
            transport.
          '';
        };

        network = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Give the guest a NAT network interface (slirp user networking:
            entirely userspace, no bridges, no firewall changes, no root).
          '';
        };

        audio = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Give the guest a sound card (routed through PulseAudio/PipeWire).";
        };

        uefi = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Boot with OVMF firmware (on a q35 machine) instead of legacy SeaBIOS (on a pc machine).";
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra arguments passed verbatim to qemu-system-x86_64.";
          example = ''["-vnc" ":1"]'';
        };
      };
    }));
    default = {};
    description = "Live OS images to expose as VM launcher commands.";
  };
}
