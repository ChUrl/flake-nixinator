{
  config,
  lib,
  pkgs,
  ...
}: let
  jellyfinVersion = "10.11.2";
in {
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "linuxserver/jellyfin:${jellyfinVersion}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [
        # "pihole"
      ];

      ports = [
        "8096:8096" # Bind for VPS
      ];

      volumes = [
        "/media/Show:/data/tvshows"
        "/media/Movie:/data/movies"
        "/media/TV-Music:/data/music"
        "/media/MusicVideos:/data/musicvideos"

        "jellyfin_config:/config"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
