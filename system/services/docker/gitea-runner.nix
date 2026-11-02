{
  mylib,
  config,
  ...
}: let
  runnerVersion = "0.6.1";
in {
  # Runner stays a container for now: it needs the docker socket to launch jobs.
  virtualisation.oci-containers.containers = {
    gitea-runner = {
      image = "gitea/act_runner:${runnerVersion}";
      autoStart = true;

      login = mylib.containers.mkDockerLogin config;

      ports = [];

      volumes = [
        "gitea-runner_data:/data"
        "gitea-runner_config:/config" # Managed by env variables for vegardit image

        "/var/run/docker.sock:/var/run/docker.sock" # Disable for dind
      ];

      environment = {
        # gitea is no longer a container, so it is reached through the host.
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
