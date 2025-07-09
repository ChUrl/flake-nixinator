{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers.containers.heidi = {
    image = "gitea.vps.chriphost.de/christoph/discord-heidi:latest";
    autoStart = true;

    # login = {
    #   # Uses DockerHub by default
    #   # registry = "";
    #
    #   # DockerHub Credentials
    #   username = "christoph.urlacher@protonmail.com";
    #   passwordFile = "${config.age.secrets.dockerhub-pasword.path}";
    # };

    dependsOn = [];

    ports = [];

    volumes = [
      "heidi_config:/config"

      "/home/christoph/heidi-sounds:/sounds:ro"
    ];

    environment = {
      # TODO: I can't do this because readFile obviously doesn't
      #       read at runtime but at buildtime, duh...
      DISCORD_TOKEN = builtins.readFile config.age.secrets.heidi-discord-token.path;
      DOCKER = "True";
    };

    extraOptions = [
      "--init" # Make an init process take up PID 1, to make python receive the SIGTERM
      "--net=behind-nginx"
    ];
  };
}
