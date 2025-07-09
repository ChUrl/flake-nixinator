{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.gitea-runner = {
    image = "gitea/act_runner:latest"; # NOTE: vegardit has other runner images
    autoStart = true;

    login = {
      # Uses DockerHub by default
      # registry = "";

      # DockerHub Credentials
      username = "christoph.urlacher@protonmail.com";
      passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    };

    dependsOn = [];

    ports = [];

    volumes = [
      "gitea-runner_data:/data"
      "gitea-runner_config:/config" # Managed by env variables for vegardit image

      "/var/run/docker.sock:/var/run/docker.sock" # Disable for dind
    ];

    environment = {
      # NOTE: gitlab.local.chriphost.de doesn't work, because it gets resolved to 192.168.86.25:443, which is nginx
      GITEA_INSTANCE_URL = "http://192.168.86.25:3000";
      GITEA_RUNNER_NAME = "servenix";

      # Can be generated from inside the container using act_runner generate-config > /config/config.yaml
      CONFIG_FILE = "/config/config.yaml";

      # NOTE: This token is invalid, when re-registering is needed it has to be refreshed
      GITEA_RUNNER_REGISTRATION_TOKEN = "Mq6wr0dPthqDij3iaryP8s5VYZA5kPfOQbHA6wm6";
    };

    extraOptions = [
      # "--privileged" # Enable for dind
      "--net=behind-nginx"
    ];
  };
}
