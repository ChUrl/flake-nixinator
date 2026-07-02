{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  arcaneVersion = "v2.3.0";
in {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."arcane-agent_secrets.env".content = ''
    AGENT_TOKEN=${config.sops.placeholder.agent-token}
  '';

  virtualisation.oci-containers.containers = {
    arcane-agent = {
      image = "ghcr.io/getarcaneapp/arcane-headless:${arcaneVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        "3553:3553"
      ];

      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"

        "arcane-agent_data:/app/data"
      ];

      environment = {
        MANAGER_API_URL = "https://arcane.think.chriphost.de";
        AGENT_MODE = "true";
        EDGE_TRANSPORT = "poll";

        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      environmentFiles = [
        config.sops.templates."arcane-agent_secrets.env".path
      ];

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
