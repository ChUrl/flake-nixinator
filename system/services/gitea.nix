{
  config,
  lib,
  pkgs,
  ...
}: let
  giteaVersion = "1.24.2";
  runnerVersion = "0.2.12";
in {
  users = {
    groups.git = {};

    # Extra git user for Gitea
    users.git = {
      uid = 500;
      group = "git";
      isNormalUser = false;
      isSystemUser = true;
      description = "Gitea User";
      extraGroups = ["docker" "podman"];
      shell = pkgs.fish;
    };
  };

  virtualisation.oci-containers.containers = {
    gitea-db = {
      image = "postgres:14";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [];

      ports = [];

      volumes = [
        "gitea-db_data:/var/lib/postgresql/data"
      ];

      environment = {
        POSTGRES_USER = "gitea";
        POSTGRES_PASSWORD = "gitea";
        POSTGRES_DB = "gitea";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    gitea = {
      image = "gitea/gitea:${giteaVersion}";
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [
        "gitea-db"
      ];

      ports = [
        "3000:3000" # Bind for VPS

        # NOTE: Set .git/config url to ssh://christoph@gitea.local.chriphost.de:222/christoph/<repo>.git
        "222:222" # Gitea SSH
      ];

      volumes = [
        "/etc/timezone:/etc/timezone:ro"
        "/etc/localtime:/etc/localtime:ro"

        "gitea_data:/data"
      ];

      environment = {
        USER = "git";
        USER_UID = "500";
        # USER_GID = "100";

        GITEA__database__DB_TYPE = "postgres";
        GITEA__database__HOST = "gitea-db:5432";
        GITEA__database__NAME = "gitea";
        GITEA__database__USER = "gitea";
        GITEA__database__PASSWD = "gitea";
      };

      extraOptions = [
        "--net=behind-nginx"
      ];
    };

    gitea-runner = {
      image = "gitea/act_runner:${runnerVersion}"; # NOTE: vegardit has other runner images
      autoStart = true;

      login = {
        # Uses DockerHub by default
        # registry = "";

        # DockerHub Credentials
        username = "christoph.urlacher@protonmail.com";
        passwordFile = "${config.sops.secrets.docker-password.path}";
      };

      dependsOn = [
        "gitea"
      ];

      ports = [];

      volumes = [
        "gitea-runner_data:/data"
        "gitea-runner_config:/config" # Managed by env variables for vegardit image

        "/var/run/docker.sock:/var/run/docker.sock" # Disable for dind
      ];

      environment = {
        # gitlab.local.chriphost.de doesn't work, because it gets resolved to 192.168.86.25:443, which is nginx
        GITEA_INSTANCE_URL = "http://192.168.86.25:3000";
        GITEA_RUNNER_NAME = "servenix";

        # Can be generated from inside the container using act_runner generate-config > /config/config.yaml
        CONFIG_FILE = "/config/config.yaml";

        # This token is invalid, when re-registering is needed it has to be refreshed
        GITEA_RUNNER_REGISTRATION_TOKEN = "Mq6wr0dPthqDij3iaryP8s5VYZA5kPfOQbHA6wm6";
      };

      extraOptions = [
        # "--privileged" # Enable for dind
        "--net=behind-nginx"
      ];
    };
  };
}
