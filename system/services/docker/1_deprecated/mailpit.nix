{
  mylib,
  config,
  lib,
  pkgs,
  ...
}: let
  mailpitVersion = "v1.33.0";
in {
  virtualisation.oci-containers.containers = {
    mailpit = {
      image = "docker.io/axllent/mailpit:${mailpitVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      dependsOn = [];

      ports = [
        # "1025:1025" # SMTP
        "127.0.0.1:8025:8025" # WebUI
      ];

      volumes = ["mailpit_data:/data"];

      environment = {
        MP_DATABASE = "/data/mailpit.db";
        MP_MAX_MESSAGES = "5000";
        TZ = "Europe/Berlin";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };
  };
}
