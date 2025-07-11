{
  config,
  lib,
  pkgs,
  ...
}: let
  heidiVersion = "latest";
in {
  # If we need to pass secrets to containers we can't use plain env variables.
  sops.templates."heidi_secrets.env".content = ''
    DISCORD_TOKEN=${config.sops.placeholder.heidi-discord-token}
  '';

  virtualisation.oci-containers.containers = {
    heidi = {
      image = "gitea.vps.chriphost.de/christoph/discord-heidi:${heidiVersion}";
      autoStart = true;

      dependsOn = [];

      ports = [];

      volumes = [
        "heidi_config:/config"

        "/home/christoph/heidi-sounds:/sounds:ro"
      ];

      environment = {
        DOCKER = "True";
      };

      environmentFiles = [
        config.sops.templates."heidi_secrets.env".path
      ];

      extraOptions = [
        "--init" # Make an init process take up PID 1, to make python receive the SIGTERM
        "--net=behind-nginx"
      ];
    };
  };
}
