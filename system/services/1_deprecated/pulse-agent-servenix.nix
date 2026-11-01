{
  config,
  lib,
  pkgs,
  ...
}: let
  pulseAgentServenixVersion = "4.35.0";
in {
  virtualisation.oci-containers.containers = {
    pulse-agent-servenix = {
      image = "ghcr.io/rcourtman/pulse-docker-agent:${pulseAgentServenixVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        PULSE_URL = "https://pulse.think.chriphost.de";
        PULSE_TOKEN = "6a72f3951990d6724f09106d052302f6f60fc9e94f71720bf8e8a1fe4a27d4a2";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
        "--pid=host"
        "--uts=host"
      ];
    };
  };
}
