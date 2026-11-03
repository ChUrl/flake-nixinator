{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  cadvisorVersion = "v0.60.6";
in {
  virtualisation.oci-containers.containers.cadvisor = {
    image = "gcr.io/cadvisor/cadvisor:${cadvisorVersion}";
    autoStart = true;

    # Scraped by Prometheus on the same host. Docker binds this to the
    # loopback, so it is not reachable from the LAN.
    ports = ["127.0.0.1:8083:8080"];

    volumes = [
      "/:/rootfs:ro"
      "/var/run:/var/run:ro"
      "/sys:/sys:ro"
      "/var/lib/docker/:/var/lib/docker:ro"
      "/dev/disk/:/dev/disk:ro"
    ];

    environment = {
      TZ = "Europe/Berlin";
    };

    extraOptions = [
      "--privileged"
      "--device=/dev/kmsg"
    ];
  };
}
