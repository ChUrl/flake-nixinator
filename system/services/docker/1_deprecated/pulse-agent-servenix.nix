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

        PULSE_URL = "https://pulse.think.chriphost.gay";
        PULSE_TOKEN = "<redacted>"; # was committed in plaintext — revoke if the service ever returns
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
