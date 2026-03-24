{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  # Match this with the portainer-ce version
  portainerVersion = "2.33.3";
in {
  # Use the agent to connect clients to a main portainer instance
  virtualisation.oci-containers.containers = {
    portainer-agent = {
      image = "portainer/agent:${portainerVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "9001:9001"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/docker/volumes:/var/lib/docker/volumes"
      ];

      environment = {};

      extraOptions = [
        # This container needs to be accessible from another machine inside the LAN
        # "--net=behind-nginx"
      ];
    };
  };
}
