{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  TEMPLATEVersion = "";
in {
  # Secrets can't be passed as plain env variables. Declare the secret here so
  # it's installed (root-owned is enough, the file is read by root).
  sops.secrets."SECRET" = {};

  sops.templates."TEMPLATE_secrets.env".content = ''
    SECRET=${config.sops.placeholder.SECRET}
  '';

  virtualisation.oci-containers.containers = {
    TEMPLATE = {
      image = "TEMPLATE:${TEMPLATEVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [];

      volumes = [];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      environmentFiles = [
        config.sops.templates."TEMPLATE_secrets.env".path
      ];

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
