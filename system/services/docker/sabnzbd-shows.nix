{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  sabnzbdVersion = "5.1.3";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.sabnzbd-shows = {port = 8085;};

  virtualisation.oci-containers.containers = {
    sabnzbd-shows = {
      image = "linuxserver/sabnzbd:${sabnzbdVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # NOTE: On initial start, the gui won't be reachable via reverse proxy,
        #       because the hostname has to be whitelisted.
        #       Edit the "sabnzbd.ini" in the docker volume and add the reverse-proxy address
        #       to the host_whitelist variable.
        "127.0.0.1:8085:8080"
      ];

      volumes = [
        "/media/Show/.sabnzbd:/media/shows/incomplete"
        "/media/Show/.sabnzbd-complete:/media/shows/complete"

        "sabnzbd-shows_config:/config"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
