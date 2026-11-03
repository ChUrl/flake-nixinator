# Usage (host default.nix):
#   imports = [
#     (import ../services/docker/arcane-agent.nix {tokenSecret = "some-sops-secret";})
#   ];
{
  # sops secret holding this host's AGENT_TOKEN
  tokenSecret,
  # docker network to join, e.g. "behind-nginx"
  network ? null,
  # optional host path mounted at /backups
  backupsPath ? null,
}: {
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  arcaneVersion = "v2.17.0";
in {
  # Secret holding this host's AGENT_TOKEN
  sops.secrets.${tokenSecret} = {};

  # Secrets can't be passed as plain environment variables.
  sops.templates."arcane-agent_secrets.env".content = ''
    AGENT_TOKEN=${config.sops.placeholder.${tokenSecret}}
  '';

  virtualisation.oci-containers.containers.arcane-agent = {
    image = "ghcr.io/getarcaneapp/arcane-headless:${arcaneVersion}";
    autoStart = true;

    login = mylib.containers.mkDockerLogin config;

    dependsOn = [];

    # Edge mode: the agent connects out to the manager, so nothing is published.
    ports = [];

    volumes =
      [
        "/var/run/docker.sock:/var/run/docker.sock"
        "arcane-agent_data:/app/data"
      ]
      ++ lib.optional (backupsPath != null) "${backupsPath}:/backups";

    environment = {
      MANAGER_API_URL = "https://arcane.local.chriphost.gay";

      # AGENT_MODE=true would select Direct mode, which requires the
      # manager to reach :3553 on this host.
      EDGE_AGENT = "true";
      EDGE_TRANSPORT = "auto";

      PUID = "1000";
      PGID = "1000";
      TZ = "Europe/Berlin";
    };

    environmentFiles = [
      config.sops.templates."arcane-agent_secrets.env".path
    ];

    extraOptions = lib.optional (network != null) "--net=${network}";
  };
}
