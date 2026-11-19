# Shared configuration of the NixOS-WSL hosts (`wslix` and `wslren`).
#
# Windows provides the kernel and starts the distro, so the bootloader, the
# kernel build and a few bare-metal modules from system/default.nix are turned
# off here. The terminal environment itself comes from home-manager and is the
# same as on the other headless hosts.
#
# Both hosts are separate WSL2 installations on different Windows machines
# (`wslix` at home, `wslren` at work). Everything they have in common lives
# here; the host directories only add their own packages, secrets and
# environment differences (see system/wslix and system/wslren).
{
  config,
  lib,
  pkgs,
  username,
  ...
}: let
  # `.wslconfig` sizes the WSL 2 VM (memory, processors, ...) and is global to
  # all distros of a Windows installation. It lives on the Windows side in
  # %USERPROFILE%\.wslconfig, so wsl.wslConf (which renders the per-distro
  # /etc/wsl.conf) cannot set it. The service below mirrors this file into the
  # Windows profile instead. Changes take effect after "wsl --shutdown".
  wslconfig = pkgs.writeText "wslconfig" ''
    # Managed by system/wsl/default.nix, changes are overwritten.
    [wsl2]
    memory=8GB
    processors=8
  '';
in {
  # There is no tty in WSL; the unit fails and makes `switch` report an error.
  # `enable = false` masks the unit (symlink to /dev/null).
  systemd.services."getty@tty1".enable = false;

  wsl = {
    enable = true;

    # NixOS-WSL creates this user (uid 1000) and starts the distro as it.
    # It has to be the regular user, otherwise a second uid 1000 account is
    # created and logging in breaks.
    defaultUser = username;

    # Run Windows executables from the Linux shell (explorer.exe, winget, ...)
    # and pass the WSL environment to them.
    interop.register = true;

    # WSLg renders through the graphics driver of the Windows host: there is no
    # /dev/dri, only /dev/dxg plus the libd3d12/libdxcore libraries in
    # /usr/lib/wsl/lib. This symlinks those into a store package in
    # /run/opengl-driver, which is where mesa looks for them (it needs the
    # LD_LIBRARY_PATH below to actually find that directory, see there).
    useWindowsDriver = true;

    # No ssh-agent passthrough: the key lives in ~/.ssh/id_ed25519 and is
    # unlocked by programs.keychain like on the other hosts.
  };

  # Hardware acceleration inside WSLg. This is the equivalent of what a normal
  # WSL distro gets from ldconfig, which does not exist on NixOS:
  #
  # - Mesa dlopens libd3d12/libdxcore by soname, so the directory with the
  #   Windows driver libraries has to be on the loader path.
  # - Mesa only picks the D3D12 backend on WSL when it is forced; its normal
  #   device probing needs /dev/dri nodes.
  # - The adapter has to be picked by name, otherwise dxcore chooses the wrong
  #   one and the D3D12 screen fails to initialize. Which adapter that is
  #   differs per machine, so each host sets
  #   environment.sessionVariables.MESA_D3D12_DEFAULT_ADAPTER_NAME itself.
  # Drop these variables to go back to software rendering (llvmpipe) if the
  # D3D12 path ever gets in the way.
  environment.sessionVariables = {
    LD_LIBRARY_PATH = ["/run/opengl-driver/lib"];
    GALLIUM_DRIVER = "d3d12";
  };

  # Secrets: every WSL host has its own secrets.yaml next to its host module,
  # both encrypted with the age key in ~/.secrets/age/age.key (the same key on
  # both machines). The shared secrets.yaml of systemmodules.sops-nix stays
  # unused because systemmodules.sops-nix is disabled on the WSL hosts; the
  # user password and the host specific tokens are declared by the host
  # modules themselves.
  sops.age = {
    keyFile = "/home/${username}/.secrets/age/age.key";
    generateKey = false;
    sshKeyPaths = [];
  };

  # Let `sops system/<host>/secrets.yaml` find the key (systemmodules.sops-nix,
  # which sets this on the other hosts, is disabled here).
  environment.variables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;

  system.stateVersion = "26.11";

  # NixOS-WSL makes sudo passwordless. The password hash comes from the host's
  # secrets file (see users.users.<name>.hashedPasswordFile in system/default.nix),
  # so sudo should ask for it like on every other host.
  security.sudo.wheelNeedsPassword = lib.mkForce true;

  systemmodules = {
    # Windows boots the distro, there is no boot loader and no ESP to write.
    bootloader.enable = lib.mkForce false;

    # MonoLisa, Nerd Fonts and Noto are referenced by name in the kitty and
    # neovim configs. Without them everything falls back to DejaVu.
    fonts.enable = lib.mkForce true;

    # The terminal environment does not use containers, and the daemon pulls a
    # large closure plus a service that expects a persistent /var/lib/docker.
    docker.enable = lib.mkForce false;

    # No Prometheus/Loki on a laptop VM.
    monitoring-agent.enable = lib.mkForce false;

    # The WSL hosts use their own secrets file per host (see below); the shared
    # secrets.yaml of systemmodules.sops-nix and its consumers (user password,
    # nix.conf, ssh key) are not used, so home/christoph/default.nix keeps
    # ~/.ssh/id_ed25519 as a plain file instead of linking it to a secret.
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
    bootvine.enable = lib.mkForce false;

    # The Windows host keeps the clock in sync, chrony would fight it.
    chrony.enable = lib.mkForce false;
    fwupd.enable = lib.mkForce false;

    # WSL generates /etc/resolv.conf from the Windows host, there is no local
    # resolver to run (the network module would enable systemd-resolved).
    resolved.enable = lib.mkForce false;

    # WSLg runs its own PulseAudio server for the Windows audio devices and
    # exports it as PULSE_SERVER=/mnt/wslg/PulseServer, so no pipewire/pulseaudio
    # is started in the distro (system/default.nix would enable pipewire if this
    # host were not headless).
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
