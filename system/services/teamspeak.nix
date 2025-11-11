{
  config,
  lib,
  pkgs,
  ...
}: let
  teamspeakVersion = "v6.0.0-beta7";
in {
  virtualisation.oci-containers.containers = {
    teamspeak = {
      image = "teamspeaksystems/teamspeak6-server:${teamspeakVersion}";
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
        # Bind for VPS
        "9987:9987/udp" # Voice port
        "30033:30033" # File transfer
        "10080:10080/tcp" # Web query
      ];

      volumes = [
        "teamspeak_data:/var/tsserver"
      ];

      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Berlin";

        TSSERVER_LICENSE_ACCEPTED = "accept";
      };

      extraOptions = [
        # "--privileged"
        # "--device=nvidia.com/gpu=all"
        # "--net=behind-nginx"
      ];
    };
  };
}
