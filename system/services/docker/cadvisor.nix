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
    image = "ghcr.io/google/cadvisor:${cadvisorVersion}";
    autoStart = true;

    # Host networking on purpose: cAdvisor only needs to be scraped from
    # 127.0.0.1, and this avoids Docker's DNAT rules. A NixOS firewall reload
    # can flush the DOCKER chain, after which new port mappings fail with
    # "iptables: No chain/target/match by that name".
    ports = [];

    cmd = [
      "--listen_ip=127.0.0.1"
      "--port=8083"
      "--docker_only=true"
      "--housekeeping_interval=30s"
      "--logtostderr"
    ];

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
      "--net=host"
      "--privileged"
      "--device=/dev/kmsg"
    ];
  };
}
