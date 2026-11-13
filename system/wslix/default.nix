# NixOS as a WSL2 distribution (see inputs.nixos-wsl).
# Windows provides the kernel and starts the distro, so the bootloader, the
# kernel build and a few bare-metal modules from system/default.nix are turned
# off here. The terminal environment itself comes from home-manager and is the
# same as on the other headless hosts.
{
  lib,
  pkgs,
  username,
  ...
}: let
  # `.wslconfig` sizes the WSL 2 VM (memory, processors, ...) and is global to
  # all distros. It lives on the Windows side in %USERPROFILE%\.wslconfig, so
  # wsl.wslConf (which renders the per-distro /etc/wsl.conf) cannot set it.
  # The service below mirrors this file into the Windows profile instead.
  # Changes take effect after "wsl --shutdown".
  wslconfig = pkgs.writeText "wslconfig" ''
    # Managed by wslix (system/wslix/default.nix), changes are overwritten.
    [wsl2]
    memory=8GB
    processors=8
  '';
in {
  wsl = {
    enable = true;

    # NixOS-WSL creates this user (uid 1000) and starts the distro as it.
    # It has to be the regular user, otherwise a second uid 1000 account is
    # created and logging in breaks.
    defaultUser = username;

    # Run Windows executables from the Linux shell (explorer.exe, winget, ...)
    # and pass the WSL environment to them.
    interop.register = true;

    # No ssh-agent passthrough: the key lives in ~/.ssh/id_ed25519 and is
    # unlocked by programs.keychain like on the other hosts.
  };

  system.stateVersion = "26.11";

  systemmodules = {
    # Windows boots the distro, there is no boot loader and no ESP to write.
    bootloader.enable = lib.mkForce false;

    # The terminal environment does not use containers, and the daemon pulls a
    # large closure plus a service that expects a persistent /var/lib/docker.
    docker.enable = lib.mkForce false;

    # No Prometheus/Loki on a laptop VM.
    monitoring-agent.enable = lib.mkForce false;

    # This host has no age key, so it cannot decrypt the sops secrets.
    # system/default.nix skips its sops consumers (user password, nix.conf,
    # GitHub token) and home/christoph/default.nix skips the managed ssh key
    # and nix.conf links along with this.
    sops-nix.enable = lib.mkForce false;

    network = {
      # WSL assigns eth0's address, default route and DNS itself (and the
      # network namespace is shared by all distros). A .network file with
      # DHCP=yes makes networkd flush that configuration when it takes the
      # link over (KeepConfiguration defaults to "no") and there is no DHCP
      # server to acquire a new lease from.
      networks = lib.mkForce {};
    };
  };

  services = {
    # WSL generates /etc/resolv.conf from the Windows host, there is no local
    # resolver to run (the network module would enable systemd-resolved).
    resolved.enable = lib.mkForce false;

    # The Windows host keeps the clock in sync, chrony would fight it.
    chrony.enable = lib.mkForce false;

    # No firmware to update inside WSL.
    fwupd.enable = lib.mkForce false;
  };

  # WSL has no TTY consoles. NixOS-WSL turns console.enable off already, the
  # font/color settings from system/default.nix are simply unused.

  # WSL reads %USERPROFILE%\.wslconfig from the Windows side when the VM
  # starts, so the file has to be written there instead of into the store.
  # Runs at boot and after every rebuild (the unit changes with its content).
  systemd.services.wslconfig = {
    description = "Write the Windows-side .wslconfig of the WSL 2 VM";
    wantedBy = ["multi-user.target"];
    path = [pkgs.coreutils pkgs.diffutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -eu

      # Only NixOS-WSL runs on Windows; nowhere else is there anything to do.
      if [ ! -d /mnt/c/Users ]; then
        echo "Windows drives are not mounted, not writing .wslconfig"
        exit 0
      fi

      cmd=""
      for candidate in /mnt/*/Windows/System32/cmd.exe; do
        if [ -x "$candidate" ]; then
          cmd="$candidate"
          break
        fi
      done

      if [ -z "$cmd" ]; then
        echo "cmd.exe not found, not writing .wslconfig"
        exit 0
      fi

      winhome=$("$cmd" /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r' || true)
      target=$(/bin/wslpath -u "$winhome" 2>/dev/null || true)

      if [ -z "$target" ] || [ ! -d "$target" ]; then
        echo "could not resolve the Windows profile from '$winhome'" >&2
        exit 1
      fi

      if cmp -s ${wslconfig} "$target/.wslconfig"; then
        exit 0
      fi

      install -m 0644 ${wslconfig} "$target/.wslconfig"
      echo "wrote $target/.wslconfig, run 'wsl --shutdown' to apply"
    '';
  };
}
