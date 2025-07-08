{
  config,
  lib,
  mylib,
  ...
}: let
  inherit (config.modules) docker;
in {
  options.modules.docker = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf docker.enable {
    virtualisation = {
      docker = {
        enable = !docker.podman;
        autoPrune.enable = true;
        enableNvidia = true;

        rootless = {
          enable = docker.docker.rootless;
          setSocketVariable = true;
        };

        daemon.settings = {
          # ipv6 = true;
          # fixed-cidr-v6 = "2001::/80";

          dns = [
            "8.8.8.8"
            # "2001:4860:4860::8888"

            # "127.0.0.1"
            # "192.168.86.25"
          ];

          hosts = [
            # Allow access to docker socket
            "tcp://0.0.0.0:2375"
            "unix:///var/run/docker.sock"
          ];
        };
      };

      podman = {
        enable = docker.podman;
        autoPrune.enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;

        # extraPackages = with pkgs; [];
      };

      oci-containers.backend = "podman"; # "docker" or "podman"
      libvirtd.enable = true;
    };
  };
}
