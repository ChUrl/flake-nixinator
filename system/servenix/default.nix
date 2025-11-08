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
    ../services/statespaces.nix

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
    ../services/portainer-agent.nix
    ../services/tinymediamanager.nix
    ../services/whats-up-docker.nix
  ];

  modules = {
    docker.networks = [
      {
        name = "behind-nginx";
        disable_masquerade = false;
        ipv6.enable = false;
      }
    ];

    network = {
      useNetworkManager = false;

      networks = {
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "ens18";
          ips = ["192.168.86.25/24"];
          routers = ["192.168.86.5"];
          nameservers = ["8.8.8.8"]; # NOTE: Use reliable DNS for servers instead of 192.168.86.26
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
      "paperless-nextcloud-sync-password"
    ];
  };

  # List services that you want to enable:
  services = {
    # Configure keymap in X11
    xserver = {
      xkb.layout = "us";
      xkb.variant = "altgr-intl";
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
