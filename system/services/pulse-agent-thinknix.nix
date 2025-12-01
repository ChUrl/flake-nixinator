{
  config,
  lib,
  pkgs,
  ...
}: let
  pulseAgentThinknixVersion = "4.35.0";
in {
  virtualisation.oci-containers.containers = {
    pulse-agent-thinknix = {
      image = "ghcr.io/rcourtman/pulse-docker-agent:${pulseAgentThinknixVersion}";
      autoStart = true;

      dependsOn = [
        "pulse"
      ];

      ports = [];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        PULSE_URL = "https://pulse.think.chriphost.de";
        PULSE_TOKEN = "6ab80ff7336a0cd7e0edcf3cd270a72bf6e075bcff337235ab011d1f70231e2f";
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
