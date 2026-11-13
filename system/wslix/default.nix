# NixOS as a WSL2 distribution (see inputs.nixos-wsl).
# Windows provides the kernel and starts the distro, so the bootloader, the
# kernel build and a few bare-metal modules from system/default.nix are turned
# off here. The terminal environment itself comes from home-manager and is the
# same as on the other headless hosts.
{
  lib,
  mylib,
  username,
  ...
}: {
  wsl = {
    enable = true;

    # NixOS-WSL creates this user (uid 1000) and starts the distro as it.
    # It has to be the regular user, otherwise a second uid 1000 account is
    # created and logging in breaks.
    defaultUser = username;

    # Run Windows executables from the Linux shell (explorer.exe, winget, ...)
    # and pass the WSL environment to them.
    interop.register = true;

    # Use the Windows ssh-agent (OpenSSH Authentication Agent service) instead
    # of managing keys inside the VM.
    ssh-agent.enable = true;
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
      # WSL hands out the address over DHCP on eth0. Replace the wildcard
      # ethernet network of the physical hosts, there is no enp* here.
      networks = lib.mkForce {
        "10-eth0" = mylib.networking.mkSystemdNetwork "eth0" false;
      };
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
}
