{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  autheliaVersion = "4.39.4";
in {
  virtualisation.oci-containers.containers = {
    authelia = {
      image = "authelia/authelia:${autheliaVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "9091:9091"
      ];

      volumes = [
        "authelia_config:/config"
      ];

      environment = {
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
