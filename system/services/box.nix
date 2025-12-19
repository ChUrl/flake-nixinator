{
  config,
  lib,
  pkgs,
  ...
}: let
  boxVersion = "v0.30.1";
in {
  virtualisation.oci-containers.containers = {
    box = {
      image = "stashapp/stash:${boxVersion}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [];

      ports = [
        # "9999:9999"
      ];

      volumes = [
        "/etc/localtime:/etc/localtime:ro"

        "/media/Box:/data"

        "box_config:/root/.stash"
        "box_metadata:/metadata"
        "box_cache:/cache"
        "box_blobs:/blobs"
        "box_generated:/generated"
      ];

      environment = {
        PUID = "3000";
        PGID = "3000";
        TZ = "Europe/Berlin";

        STASH_STASH = "/data/";
        STASH_GENERATED = "/generated/";
        STASH_METADATA = "/metadata/";
        STASH_CACHE = "/cache/";
      };

      extraOptions = [
        "--privileged"
        "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
