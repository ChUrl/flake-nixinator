{
  config,
  lib,
  pkgs,
  ...
}: let
  sabnzbdVersion = "4.5.5";
in {
  virtualisation.oci-containers.containers = {
    sabnzbd-shows = {
      image = "linuxserver/sabnzbd:${sabnzbdVersion}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [];

      ports = [
        # NOTE: On initial start, the gui won't be reachable via reverse proxy,
        #       because the hostname has to be whitelisted.
        #       Edit the "sabnzbd.ini" in the docker volume and add the reverse-proxy address
        #       to the host_whitelist variable.
        # "8080:8080"
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
