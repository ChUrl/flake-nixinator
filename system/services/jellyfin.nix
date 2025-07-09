{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.jellyfin = {
    image = "linuxserver/jellyfin:latest";
    autoStart = true;

    dependsOn = [
      # "pihole"
    ];

    ports = [
      "8096:8096"
    ];

    volumes = [
      "/media/Show:/data/tvshows"
      "/media/Movie:/data/movies"
      "/media/TV-Music:/data/music"

      "jellyfin_config:/config"
    ];

    environment = {
      PUID = "3000";
      PGID = "3000";
      TZ = "Europe/Berlin";

      NVIDIA_VISIBLE_DEVICES = "all";
      NVIDIA_DRIVER_CAPABILITIES = "all";
    };

    extraOptions = [
      "--privileged"
      "--gpus=all"
      "--net=behind-nginx"
    ];
  };
}
