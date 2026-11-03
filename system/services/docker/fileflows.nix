{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  version = "26.10";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.fileflows = {port = 5000;};

  virtualisation.oci-containers.containers = {
    fileflows = {
      image = "revenz/fileflows:${version}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = ["127.0.0.1:5000:5000"];

      volumes = [
        "fileflows_temp:/temp"
        "fileflows_data:/app/Data"
        "fileflows_logs:/app/Logs"

        "/media/Movie:/media/movies"
        "/media/Show:/media/tvshows"
        "/media/MusicVideos:/media/musicvideos"

        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        # Docker API access via the socket is enough; the GPU comes from CDI.
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
