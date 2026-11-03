{config, ...}: {
  # Backed up by systemmodules/restic
  systemmodules.restic.servicePaths = [config.services.immich.mediaLocation];

  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.immich = {
    port = config.services.immich.port;
    aliases = ["immich.vps.chriphost.gay"];
  };

  services.immich = {
    enable = true;

    host = "127.0.0.1";
    port = 2283;

    # /photos from the old container maps 1:1 (library, upload, thumbs, ...)
    mediaLocation = "/var/lib/immich";

    # Transcoding only — machine learning stays on the CPU (no CUDA build).
    # NVENC via the 1070, VAAPI/QSV via the iGPU as fallback.
    accelerationDevices = [
      "/dev/nvidia0"
      "/dev/nvidiactl"
      "/dev/nvidia-uvm"
      "/dev/nvidia-uvm-tools"
      "/dev/nvidia-modeset"
      "/dev/dri/renderD128"
    ];
  };
}
