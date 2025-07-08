{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.formula10 = {
    image = "gitea.vps.chriphost.de/christoph/formula10:latest";
    autoStart = true;

    dependsOn = [];

    ports = [
      "55555:5000"
    ];

    volumes = [
      "formula10_data:/app/instance"
      "formula10_cache:/cache"
    ];

    environment = {
      TZ = "Europe/Berlin";
    };

    extraOptions = [
      "--init" # Make an init process take up PID 1, to make python receive the SIGTERM
      "--net=behind-nginx"
    ];
  };
}
