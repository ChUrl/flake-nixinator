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
      (lib.mkIf (!docker.podman) {
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

      mkDockerNetwork = name: options:
        builtins.concatStringsSep "\n" [
          # Make sure to return true on fail to not crash
          ''
            check=$(${cli} network inspect ${name} || true)
            if [ -z "$check" ]; then
          ''

          (builtins.concatStringsSep " " [
            "${cli} network create"

            # Disable masquerading
            (lib.mkIf
              options.disable_masquerade
              ''-o "com.docker.network.bridge.enable_ip_masquerade"="false"'')

            # Enable ipv6
            (lib.mkIf
              options.ipv6.enable
              "--ipv6")
            (lib.mkIf
              (builtins.hasAttr "gateway" options.ipv6)
              ''--gateway="${options.ipv6.gateway}"'')
            (lib.mkIf
              (builtins.hasAttrs "subnet" options.ipv6)
              ''--subnet="${options.ipv6.subnet}"'')

            "${name}"
          ])

          ''
            else
              echo "${name} already exists!"
            fi
          ''
        ];

      mkPodmanNetwork = name: options:
        builtins.concatStringsSep "\n" [
          ''
            ehco "Can't create Podman networks (yet)!"
          ''
        ];

      mkSystemdNetworkService = name: options: let
        toolName =
          if docker.podman
          then "Podman"
          else "Docker";
      in {
        description = "Creates the ${toolName} network \"${name}\"";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig.Type = "oneshot";
        script =
          if docker.podman
          then (mkPodmanNetwork name options)
          else (mkDockerNetwork name options);
      };
    in
      lib.mkMerge (builtins.mapAttrs mkSystemdNetworkService docker.networks);
  };
}
