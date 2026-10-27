{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  actualbudgetVersion = "26.10.0";
in {
  virtualisation.oci-containers.containers = {
    actual-budget = {
      image = "actualbudget/actual-server:${actualbudgetVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "5006:5006"
      ];

      volumes = [
        "actual-budget_data:/data"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        "--net=behind-nginx"
      ];
    };
  };
}
