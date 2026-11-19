# NixOS-WSL host of the home machine (the one with the NVIDIA RTX 4070).
# Everything shared with wslren lives in system/wsl; this host adds the NFS
# media shares of the TrueNAS and its own secrets file.
{
  username,
  ...
}: let
  # TrueNAS shares, the same exports and options as on the other hosts (see
  # system/nixinator/hardware-configuration.nix). `_netdev` is deliberately left
  # out: WSL sets up its network before systemd starts, and network-online.target
  # is never reached in WSL, so waiting for it would keep the mounts from starting.
  # `bg` keeps a boot from hanging when the NAS is unreachable.
  nfsMount = dir: {
    device = "192.168.86.20:/mnt/Seagate4TB/${dir}";
    fsType = "nfs";
    options = ["defaults" "rw" "noatime" "bg" "hard"];
  };
in {
  imports = [../wsl];

  # The Windows machine has two adapters (NVIDIA RTX 4070 + AMD iGPU), so the
  # adapter has to be picked by name, otherwise dxcore chooses the iGPU and the
  # D3D12 screen fails to initialize.
  environment.sessionVariables.MESA_D3D12_DEFAULT_ADAPTER_NAME = "Nvidia";

  # Secrets of this host only, see system/wsl for the age setup. The password
  # hash is installed before the user is created, which makes sudo ask for it.
  sops.secrets."user-password" = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  # NFS client for the TrueNAS media shares. The WSL kernel ships the NFS client
  # as modules; declaring the mounts pulls in nfs-utils (system.fsPackages) and
  # adds "nfs" to boot.supportedFilesystems.
  boot.supportedFilesystems = ["nfs"];

  fileSystems = {
    "/home/${username}/Movies" = nfsMount "Movies";
    "/home/${username}/Shows" = nfsMount "Shows";
    "/home/${username}/Music" = nfsMount "Music";
  };
}
