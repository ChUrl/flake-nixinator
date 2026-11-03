{
  config,
  lib,
  ...
}: {
  # Only the config dir is worth backing up, data/cache/log are rebuildable
  systemmodules.restic.servicePaths = [config.services.jellyfin.configDir];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.jellyfin = {
    port = 8096;
    aliases = ["jellyfin.vps.chriphost.gay"];
  };

  # The old LinuxServer container used a single /config directory. The NixOS
  # module requires dataDir ≠ configDir, so the data is split during migration:
  #   <volume>/data, cache, log  → /var/lib/jellyfin/{data,cache,log}
  #   <volume>/*.xml, users, …   → /var/lib/jellyfin/config
  services.jellyfin = {
    enable = true;

    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
    cacheDir = "/var/lib/jellyfin/cache";
    logDir = "/var/lib/jellyfin/log";

    # Apply the transcoding settings below on every start (the old
    # encoding.xml points at the container's ffmpeg path).
    forceEncodingConfig = true;

    hardwareAcceleration = {
      enable = true;
      type = "nvenc";
      device = "/dev/nvidia0";
    };

    transcoding = {
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
      };
      hardwareEncodingCodecs.hevc = true;
    };
  };

  # Matches PUID of the old container, so the copied data stays usable.
  users.users.jellyfin.uid = 3000;

  # NVENC needs more than the single device the module allows.
  # Requires hardware.nvidia.nvidiaPersistenced so the nodes exist at start.
  systemd.services.jellyfin.serviceConfig.DeviceAllow = lib.mkForce [
    "/dev/nvidia0 rw"
    "/dev/nvidiactl rw"
    "/dev/nvidia-uvm rw"
    "/dev/nvidia-uvm-tools rw"
    "/dev/nvidia-modeset rw"
    "/dev/dri/card0 rw"
    "/dev/dri/renderD128 rw"
  ];
}
