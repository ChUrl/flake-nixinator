{config, ...}: {
  sops.secrets."gitea-runner-token" = {};

  services.gitea-actions-runner.instances.servenix = {
    enable = true;
    name = "servenix";

    # gitea runs on this host; jobs still clone through the public URL because
    # that is what the instance hands out (ROOT_URL).
    url = "http://127.0.0.1:3000";
    tokenFile = config.sops.secrets."gitea-runner-token".path;

    # Same labels as the container that is being replaced
    labels = [
      # "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:custom-22.04"
      "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:custom-24.04"
      # "ubuntu-26.04:docker://ghcr.io/catthehacker/ubuntu:custom-26.04-dev"
    ];

    settings = {
      runner = {
        capacity = 1;
        timeout = "3h";
      };

      metrics = {
        enabled = true;
        addr = "127.0.0.1:9101";
      };

      # Jobs run in containers on the same docker network as before.
      # The module adds the docker group + socket automatically because the
      # labels use the docker:// prefix.
      container.network = "behind-nginx";
    };
  };
}
