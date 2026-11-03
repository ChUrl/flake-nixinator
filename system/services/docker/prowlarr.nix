{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  prowlarrVersion = "2.6.5";
in {
  # Served by systemmodules/caddy
  systemmodules.caddy.vhosts.prowlarr = {port = 9696;};

  virtualisation.oci-containers.containers = {
    prowlarr = {
      image = "linuxserver/prowlarr:${prowlarrVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = ["127.0.0.1:9696:9696"];

      volumes = [
        "prowlarr_config:/config"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
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
