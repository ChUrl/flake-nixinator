{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia:latest";
    autoStart = true;

    dependsOn = [
      # "pihole"
    ];

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
}
