{
  inputs,
  hostname,
  lib,
  mylib,
  config,
  pkgs,
  system,
  username,
  headless,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../modules

    # My own services
    ../services/heidi.nix
    ../services/formula10.nix
    ../services/formula11.nix

    # General services
    ../services/authelia.nix
    ../services/gitea.nix
    ../services/gitea-runner.nix
    ../services/immich.nix
    ../services/jellyfin.nix
    ../services/kopia.nix
    ../services/nextcloud.nix
    ../services/nginx-proxy-manager.nix
    ../services/paperless.nix
    ../services/portainer.nix
    ../services/whats-up-docker.nix
  ];

  modules = {
    network = {
      useNetworkManager = false;

      networks = {
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "ens18";
          ips = ["192.168.86.25/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26"];
          routable = true;
        };
      };

      allowedTCPPorts = [
        53 # DNS
        80 # HTTP
        3000 # Gitea runner needs to reach local gitea instance
      ];

      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
        3000 # Gitea runner needs to reach local gitea instance
      ];
    };

    sops-nix.secrets.${username} = [
      "heidi-discord-token"
      "kopia-server-username"
      "kopia-server-password"
      "kopia-user-password"
    ];
  };

  networking.firewall.trustedInterfaces = ["docker0" "podman0"];

  systemd.services.init-behind-nginx-docker-network = {
    description = "Create a docker network bridge for all services behind nginx-proxy-manager.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig.Type = "oneshot";
    script = let
      cli = "${config.virtualisation.docker.package}/bin/docker";
      network = "behind-nginx";
    in ''
      # Put a true at the end to prevent getting non-zero return code, which will
      # crash the whole service.
      check=$(${cli} network ls | grep ${network} || true)
      if [ -z "$check" ]; then
        # TODO: Disable IP masquerading to show individual containers in AdGuard/Pi-Hole
        #       - Disabling this prevents containers from having internet connection. DNS issue?
        # ${cli} network create -o "com.docker.network.bridge.enable_ip_masquerade"="false" ${network}

        # ${cli} network create --ipv6 --gateway="2000::1" --subnet="2000::/80" ${network}
        ${cli} network create ${network}
      else
        echo "${network} already exists in docker"
      fi
    '';
  };

  # List services that you want to enable:
  services = {
    # Configure keymap in X11
    xserver = {
      layout = "us";
      xkbVariant = "altgr-intl";
      videoDrivers = ["nvidia"];
    };

    qemuGuest.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
