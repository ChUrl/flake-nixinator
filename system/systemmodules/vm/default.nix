{
  config,
  lib,
  pkgs,
  mylib,
  username,
  ...
}: let
  inherit (config.systemmodules) vm;

  # One launcher per declared live image. The guest's writes are discarded
  # by qemu's "-snapshot", so there is no state to persist anywhere
  mkLauncher = name: cfg: let
    # The store path has the image's basename
    image = pkgs.fetchurl {inherit (cfg.source) url hash;};

    # Legacy BIOS boots from the "pc" machine, UEFI needs "q35" + OVMF.
    machine =
      if cfg.uefi
      then "q35"
      else "pc";

    # An overlay (grown beyond the immutable image) is only sensible for
    # disk-based images
    overlay = cfg.media == "disk" && cfg.diskSize != null;

    # The overlay is created in $XDG_RUNTIME_DIR (fell back to /tmp, e.g. for
    # non-login invocations) and deleted when qemu exits
    overlaySetup = lib.optionalString overlay ''
      scratch=$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/''${name}.XXXXXXXX")
      disk="$scratch/disk.qcow2"
      qemu-img create -q -f qcow2 -F raw -b "$image" "$disk" ${toString cfg.diskSize}M
    '';

    # How the image is exposed to the guest and booted from
    mediaArgs =
      if cfg.media == "cdrom"
      then ''
        args+=(-cdrom "$image" -boot "order=d,menu=off")
      ''
      else let
        drive =
          if overlay
          then ''-drive "file=$disk,format=qcow2,if=none,id=stick"''
          else ''-drive "file=$image,format=raw,if=none,id=stick,readonly=on"'';

        # usb-storage is a removable device: The initramfs is started
        # with live-media=removable and ignores non-removable block
        # devices, so a virtio disk would end in "Unable to find a medium
        # containing a live file system".
        attach =
          if !cfg.usb
          then ''
            -device "virtio-blk-pci,drive=stick"
          ''
          else ''
            -device "usb-storage,drive=stick,removable=on"
          '';
      in ''
        args+=(${drive} ${attach} -boot "order=c,menu=off")
      '';

    # Static qemu arguments, one per line, shell-escaped
    staticArgs =
      [
        "-snapshot" # Discard everything the guest writes
        "-smp"
        (toString cfg.cores)
        "-m"
        (toString cfg.memorySize)
        "-vga"
        cfg.vga
        "-display"
        cfg.display
      ]
      ++ (lib.optionals cfg.network [
        # User-mode networking: no privileged TAP devices, no firewall rules
        "-nic"
        "user,model=virtio-net-pci"
      ])
      ++ (lib.optionals cfg.audio [
        # PulseAudio (PipeWire implements its protocol)
        "-audiodev"
        "pa,id=snd0"
        "-device"
        "intel-hda"
        "-device"
        "hda-duplex,audiodev=snd0"
      ])
      ++ (lib.optionals cfg.usbController [
        # QEMU's pc and q35 machines no longer provide a USB bus, and USB
        # passthrough (-device usb-host) needs one in the guest. XHCI for
        # OVMF (SeaBIOS cannot boot from XHCI), EHCI for SeaBIOS.
        "-device"
        (
          if cfg.uefi
          then "qemu-xhci,id=xhci"
          else "usb-ehci,id=ehci"
        )
      ])
      ++ (lib.optionals cfg.uefi [
        "-drive"
        "if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.firmware}"
      ])
      ++ cfg.extraArgs;
  in
    pkgs.writeShellApplication {
      name = cfg.binary;

      runtimeInputs = [pkgs.qemu_kvm];

      text = ''
        name=${lib.escapeShellArg name}
        image=${image} # Store path, hash-pinned, read-only
        scratch=
        trap '[ -n "$scratch" ] && rm -rf "$scratch"' EXIT

        ${overlaySetup}

        args=(
          ${lib.concatStringsSep "\n  " (map lib.escapeShellArg staticArgs)}
        )
        ${mediaArgs}

        # Use KVM if the user can, otherwise warn and fallback to TCG
        accel=kvm
        cpu=host
        if [ ! -r /dev/kvm ] || [ ! -w /dev/kvm ]; then
          echo "warning: /dev/kvm not accessible, falling back to slow TCG emulation (is the user in the kvm group)" >&2
          accel=tcg
          cpu=max
        fi

        args+=(-machine "${machine},accel=$accel" -cpu "$cpu")

        echo "Booting live image '$name' ($accel)..."
        # qemu runs in the background: bash only runs traps when it isn't
        # waiting for a foreground child, so a TERM/INT to this script
        # could otherwise skip the cleanup below.
        qemu-system-x86_64 "''${args[@]}" "$@" &
        pid=$!
        trap '[ -n "$scratch" ] && rm -rf "$scratch"' EXIT
        trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null; exit 130' HUP INT
        trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null; exit 143' TERM

        # Exit with qemu's status (errexit falls into the EXIT trap)
        wait "$pid"
      '';
    };
in {
  options.systemmodules.vm = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf vm.enable {
    # Unprivileged KVM
    users.groups.kvm = {};
    # "usb" is needed for usb-host passthrough below
    users.groups.usb = {};
    users.users.${username}.extraGroups = ["kvm" "usb"];

    # usb-host passthrough needs write access to /dev/bus/usb/BBB/DDD, which
    # is 0664 root:root by default. Note: not TAG+="uaccess" — the uaccess
    # builtin runs from 73-seat-late.rules, while services.udev.extraRules
    # lands in 99-local.rules, i.e. too late for the ACL to be applied.
    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0660", GROUP="usb"
    '';

    environment.systemPackages = lib.mapAttrsToList mkLauncher vm.live;
  };
}
