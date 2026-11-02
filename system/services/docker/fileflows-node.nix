{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  fileflowsVersion = "26.10";
in {
  virtualisation.oci-containers.containers = {
    fileflows-node = {
      image = "revenz/fileflows:${fileflowsVersion}";
      autoStart = false;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [];

      volumes = [
        "/home/christoph/Movies:/media/movies"
        "/home/christoph/Shows:/media/tvshows"
        # "/home/christoph/MusicVideos:/media/musicvideos" # NOTE: Not mounted on Nixinator

        "fileflows_temp:/temp"

        # The node is only started manually and never needed the API socket;
        # the mount path was also misspelled (docker.socl).
        # "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      hostname = "Nixinator";

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";

        FFNODE = "1";
        ServerUrl = "https://fileflows.local.chriphost.de";
      };

      extraOptions = [
        "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
