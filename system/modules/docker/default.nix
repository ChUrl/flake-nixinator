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
    environment.variables = lib.mkMerge [
      (lib.mkIf ((!docker.podman) && docker.docker.buildkit) {
        DOCKER_BUILDKIT = 1;
      })
    ];

    networking.firewall.trustedInterfaces = ["docker0" "podman0"];

    virtualisation = {
      docker = {
        enable = !docker.podman;
        autoPrune.enable = true;

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

      oci-containers.backend =
        if docker.podman
        then "podman"
        else "docker"; # "docker" or "podman"
      libvirtd.enable = true;
    };

    systemd.services = let
      cli =
        if docker.podman
        then "${config.virtualisation.podman.package}/bin/podman"
        else "${config.virtualisation.docker.package}/bin/docker";

      mkDockerNetwork = options:
        builtins.concatStringsSep "\n" [
          # Make sure to return true on fail to not crash
          ''
            check=$(${cli} network inspect ${options.name} || true)
            if [ -z "$check" ]; then
          ''

          (builtins.concatStringsSep " " [
            "${cli} network create"

            # Disable masquerading
            (lib.optionalString
              options.disable_masquerade
              ''-o "com.docker.network.bridge.enable_ip_masquerade"="false"'')

            # Enable ipv6
            (lib.optionalString
              options.ipv6.enable
              "--ipv6")
            (lib.optionalString
              (!(builtins.isNull options.ipv6.gateway))
              ''--gateway="${options.ipv6.gateway}"'')
            (lib.optionalString
              (!(builtins.isNull options.ipv6.subnet))
              ''--subnet="${options.ipv6.subnet}"'')

            "${options.name}"
          ])

          ''
            else
              echo "Network ${options.name} already exists!"
            fi
          ''
        ];

      mkPodmanNetwork = options:
        builtins.concatStringsSep "\n" [
          ''
            echo "Can't create Podman networks (yet)!"
          ''
        ];

      mkSystemdNetworkService = options: let
        toolName =
          if docker.podman
          then "podman"
          else "docker";
      in {
        "${toolName}-create-${options.name}-network" = {
          description = "Creates the ${toolName} network \"${options.name}\"";
          after = ["network.target"];
          wantedBy = ["multi-user.target"];

          serviceConfig.Type = "oneshot";
          script =
            if docker.podman
            then (mkPodmanNetwork options)
            else (mkDockerNetwork options);
        };
      };
    in
      lib.mkMerge (builtins.map mkSystemdNetworkService docker.networks);
  };
}
