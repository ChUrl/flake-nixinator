{
  config,
  lib,
  pkgs,
  ...
}: {
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

  virtualisation.oci-containers.containers.gitea-db = {
    image = "postgres:14";
    autoStart = true;

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

  virtualisation.oci-containers.containers.gitea = {
    image = "gitea/gitea:latest";
    autoStart = true;

    dependsOn = [
      "gitea-db"
    ];

    ports = [
      "3000:3000"

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
}
