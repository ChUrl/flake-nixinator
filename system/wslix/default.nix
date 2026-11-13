# NixOS as a WSL2 distribution (see inputs.nixos-wsl).
# Windows provides the kernel and starts the distro, so the bootloader, the
# kernel build and a few bare-metal modules from system/default.nix are turned
# off here. The terminal environment itself comes from home-manager and is the
# same as on the other headless hosts.
#
# On top of that, this host runs niri nested into WSLg. WSLg starts a Weston
# compositor in its own distro and exports it as WAYLAND_DISPLAY to every WSL
# distro; niri notices that and uses its winit backend instead of the TTY
# backend, so the whole session shows up as one window on the Windows desktop.
# Start it with `niri-session` from a WSL shell.
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
  # - This Windows machine has two adapters (NVIDIA RTX 4070 + AMD iGPU), so the
  #   adapter has to be picked by name, otherwise dxcore chooses the iGPU and
  #   the D3D12 screen fails to initialize. Drop the two variables below to go
  #   back to software rendering (llvmpipe) if that ever gets in the way.
  environment.sessionVariables = {
    LD_LIBRARY_PATH = ["/run/opengl-driver/lib"];
    GALLIUM_DRIVER = "d3d12";
    MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";
  };

  system.stateVersion = "26.11";

  systemmodules = {
    # Windows boots the distro, there is no boot loader and no ESP to write.
    bootloader.enable = lib.mkForce false;

    # Portals for the niri session: the GTK/GNOME fallbacks, the terminal file
    # chooser (yazi) and the per-application routing that system/default.nix
    # derives from programs.niri.enable.
    desktopportal.enable = lib.mkForce true;

    # MonoLisa, Nerd Fonts and Noto are referenced by name in the niri, kitty
    # and walker configs. Without them everything falls back to DejaVu.
    fonts.enable = lib.mkForce true;

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

  # The niri session. WSLg already exports WAYLAND_DISPLAY, so `niri-session`
  # starts niri with its winit backend and opens the session in a WSLg window
  # instead of taking over a TTY. The rest of the session comes from the niri
  # home-manager module, which is enabled together with the system module.
  programs = {
    niri.enable = lib.mkForce true;

    # niri starts xwayland-satellite (installed by the niri HM module) for X11
    # apps, which needs an Xwayland binary. WSLg's own X server on DISPLAY=:0
    # is not used for that.
    xwayland.enable = lib.mkForce true;

    # The GTK settings of home/homemodules/niri are stored in dconf.
    dconf.enable = lib.mkForce true;
  };

  services = {
    # WSL generates /etc/resolv.conf from the Windows host, there is no local
    # resolver to run (the network module would enable systemd-resolved).
    resolved.enable = lib.mkForce false;

    # The Windows host keeps the clock in sync, chrony would fight it.
    chrony.enable = lib.mkForce false;

    # No firmware to update inside WSL.
    fwupd.enable = lib.mkForce false;

    # WSLg runs its own PulseAudio server for the Windows audio devices and
    # exports it as PULSE_SERVER=/mnt/wslg/PulseServer, so no pipewire/pulseaudio
    # is started in the distro (system/default.nix would enable pipewire if this
    # host were not headless).
  };

  # WSLg mounts /tmp/.X11-unix as a read-only tmpfs with mode 0777. Niri refuses
  # to set up xwayland-satellite unless that directory is world-writable *and*
  # sticky, because it creates its own socket (and the display lock file) there
  # for X11 apps, next to WSLg's X0. Remount it writable and fix the mode before
  # any session starts.
  systemd.services.wslg-x11-unix = {
    description = "Make WSLg's X11 socket directory usable for xwayland-satellite";
    wantedBy = ["multi-user.target"];
    before = ["systemd-user-sessions.service"];
    path = [pkgs.util-linux pkgs.coreutils];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -eu
      mkdir -p /tmp/.X11-unix

      # Only WSL mounts it (read-only); on a normal host nothing is mounted.
      if mountpoint -q /tmp/.X11-unix; then
        mount -o remount,rw /tmp/.X11-unix
      fi

      chmod 1777 /tmp/.X11-unix
    '';
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
