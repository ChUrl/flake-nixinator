{
  config,
  lib,
  pkgs,
  ...
}: let
  statespacesVersion = "latest";
in {
  virtualisation.oci-containers.containers = {
    statespaces = {
      image = "gitea.vps.chriphost.de/christoph/statespaces:${statespacesVersion}";
      autoStart = true;

      ports = [
        # "8080:8090"
        # "3111:5173"
        "3111:8080" # Bind for VPS
      ];

      volumes = [];

      environment = {};

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
