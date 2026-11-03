{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  backrestVersion = "v1.14.1";

  # Repositories are mounted read-only, so restic must not try
  # to create locks: `--no-lock` per repo.
  #
  # `guid` is the `id` field of `<repo>/config` ("restic cat config --json").
  # Get it with (from a host that can reach the repo):
  #   RESTIC_REPOSITORY=sftp:backup@192.168.86.15:/Restic/<host> \
  #   RESTIC_PASSWORD_FILE=/run/secrets/restic-repo-key \
  #   restic cat config --json | jq -r .id
  #
  # `version` is Backrest's config format version (6 for 1.14.x). Bump
  # it together with `backrestVersion`.
  backrestConfig = ''
    {
      "version": 6,
      "instance": "thinknix",
      "repos": [
        {
          "id": "nixinator",
          "guid": "f640bcad5c4779dc479b9623ba2d24095546151c8f8411792e1b2c2bade3aa53",
          "uri": "local:/repos/nixinator",
          "password": "",
          "env": ["RESTIC_PASSWORD_FILE=/run/secrets/restic-repo-key"],
          "flags": ["--no-lock"],
          "autoInitialize": false
        },
        {
          "id": "servenix",
          "guid": "399aa28b976246a6f1ab9cca6d053bf985f1811a7ffe72ce142f53c9e4ac1e68",
          "uri": "local:/repos/servenix",
          "password": "",
          "env": ["RESTIC_PASSWORD_FILE=/run/secrets/restic-repo-key"],
          "flags": ["--no-lock"],
          "autoInitialize": false
        },
        {
          "id": "thinknix",
          "guid": "190bdfc06bfb1ab1da857bb9842054524118fd5cebac395b5b3130713608a1d9",
          "uri": "local:/repos/thinknix",
          "password": "",
          "env": ["RESTIC_PASSWORD_FILE=/run/secrets/restic-repo-key"],
          "flags": ["--no-lock"],
          "autoInitialize": false
        }
      ],
      "plans": []
    }
  '';

  # Backrest stores its config plus the generated auth secret and its state.
  # Seed the config once so UI/login changes survive restarts.
  backrestConfigFile = pkgs.writeText "backrest-config.json" backrestConfig;
in {
  # Repo password, also used by systemmodules/restic. Declared here as well so
  # this service does not depend on restic being enabled on the host.
  sops.secrets."restic-repo-key" = {};

  systemd.services.backrest-config = {
    description = "Seed the Backrest configuration";
    wantedBy = ["multi-user.target"];
    after = ["sops-install-secrets.service"];
    before = ["docker-backrest.service"];
    serviceConfig.Type = "oneshot";
    script = ''
      install -d -m 0700 /var/lib/backrest/config
      if [ ! -e /var/lib/backrest/config/config.json ]; then
        install -m 0600 ${backrestConfigFile} /var/lib/backrest/config/config.json
      fi
    '';
  };

  systemd.services."docker-backrest" = {
    requires = ["media-Restic.mount"];
    after = ["media-Restic.mount" "backrest-config.service"];
  };

  virtualisation.oci-containers.containers.backrest = {
    image = "ghcr.io/garethgeorge/backrest:${backrestVersion}";
    autoStart = true;

    login = mylib.containers.mkDockerLogin config;

    dependsOn = [];

    ports = ["127.0.0.1:9898:9898"];

    volumes = [
      "backrest_data:/data"
      "/var/lib/backrest/config:/config"
      # Read-only view of the repositories (Synology NFS export)
      "/media/Restic:/repos:ro"
      # Repo password for restic (`RESTIC_PASSWORD_FILE` in the repo `env`)
      "${config.sops.secrets."restic-repo-key".path}:/run/secrets/restic-repo-key:ro"
    ];

    environment = {
      BACKREST_DATA = "/data";
      BACKREST_CONFIG = "/config/config.json";
      TZ = "Europe/Berlin";
    };

    extraOptions = [
      "--net=behind-nginx"
    ];
  };
}
