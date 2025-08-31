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
        "5173:3111"
      ];

      volumes = [];

      environment = {};

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
