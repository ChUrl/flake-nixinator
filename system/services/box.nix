{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  boxVersion = "v0.31.0";
in {
  virtualisation.oci-containers.containers = {
    box = {
      image = "stashapp/stash:${boxVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

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
