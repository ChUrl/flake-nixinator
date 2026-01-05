{
  config,
  lib,
  pkgs,
  ...
}: let
  plexVersion = "1.42.2.10156-f737b826c";
in {
  virtualisation.oci-containers.containers = {
    plex = {
      image = "plexinc/pms-docker:${plexVersion}";
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
        "32400:32400" # Bind for VPS

        # "8324:8324/tcp" # Controlling Plex for Roku via Plex Companion
        # "32469:32469/tcp" # Plex DLNA server
        # "1900:1900/udp" # Plex DLNA server
        # "32410:32410/udp" # GDM network discovery
        # "32412:32412/udp" # GDM network discovery
        # "32413:32413/udp" # GDM network discovery
        # "32414:32414/udp" # GDM network discovery
      ];

      volumes = [
        "/media/Show:/data/tvshows"
        "/media/Movie:/data/movies"
        "/media/TV-Music:/data/music"
        "/media/MusicVideos:/data/musicvideos"

        "plex_config:/config"
        "plex_transcode:/transcode"
      ];

      environment = {
        PLEX_UID = "3000";
        PLEX_GID = "3000";
        TZ = "Europe/Berlin";

        # PLEX_CLAIM = "";
        # ADVERTISE_IP = "https://plex.vps.chriphost.de:32400";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
