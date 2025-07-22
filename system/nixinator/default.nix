{
  mylib,
  pkgs,
  username,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disks.nix

    ../modules
  ];

  modules = {
    impermanence.enable = true;

    network = {
      useNetworkManager = true;

      # Systemd-networkd configs
      networks = {
        # This should override the default network 50-ether
        "10-ether-2_5G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp8s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = true;
        };
        "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
          interface = "enp5s0";
          ips = ["192.168.86.50/24"];
          routers = ["192.168.86.5"];
          nameservers = ["192.168.86.26" "8.8.8.8"];
          routable = false;
        };
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {...};
      };

      # NetworkManager profiles
      # Run "nix run github:Janik-Haag/nm2nix | nix run github:kamadorueda/alejandra"
      # in /etc/NetworkManager/system-connections/
      profiles = {
        "10-ether-2_5G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 2.5G";
          interface = "enp8s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26;8.8.8.8;";
          priority = 10; # Rather connect to 2.5G than to 1G
        };
        "10-ether-1G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 1G";
          interface = "enp5s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          nameserver = "192.168.86.26;8.8.8.8;";
        };
      };

      allowedTCPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];

      allowedUDPPorts = [
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        4242 # Lan-Mouse
      ];
    };

    sops-nix.secrets.${username} = [
      "makemkv-app-key"
      "restic-repo-key"
    ];
  };

  sops.templates."makemkv-settings.conf" = {
    owner = config.users.users.${username}.name;
    content = ''
      app_Key = "${config.sops.placeholder.makemkv-app-key}"
      sdf_Stop = ""
    '';
  };

  boot = {
    # kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "loglevel=4" # 0 (critical) - 7 (debug)
      "udev.log_level=0" # 0 (debug) - 3 (critical)
      # "quiet"
    ];
    # plymouth.enable = true;
  };

  # environment.systemPackages = with pkgs; [];

  programs = {
    ausweisapp = {
      enable = true;
      openFirewall = true; # Directly set port in firewall
    };
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };

    # Keep this as a system service because we're backing up /persist as root
    restic.backups."synology" = {
      # user = "${username}"; # Keep default (root), so restic can read everything

      repository = "/home/${username}/Restic";
      initialize = true;
      passwordFile = config.sops.secrets.restic-repo-key.path;
      createWrapper = true;

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "5h";
      };

      runCheck = true;
      checkOpts = [
        "--with-cache"
      ];

      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 2"
        # "--keep-monthly 0"
        # "--keep-yearly 0"

        "--prune" # Automatically remove dangling files not referenced by any snapshot
        "--repack-uncompressed"
      ];

      paths = ["/persist"];
      exclude = [
        # The backup is just supposed to allow a system restore
        "/persist/old_homes"
        "/persist/old_roots"

        # Those are synced by nextcloud, no need to backup them 50 times
        "/persist/home/${username}/Documents"
        "/persist/home/${username}/NixFlake"
        "/persist/home/${username}/Notes"
        "/persist/home/${username}/Projects"
        "/persist/home/${username}/Public"

        # Some more caches
        ".cache"
        "cache2" # firefox
        "Cache"
      ];
      extraBackupArgs = [
        "--exclude-caches" # Excludes marked cache directories
        "--one-file-system" # Only stay on /persist (in case symlinks lead elsewhere)
        "--cleanup-cache" # Auto remove old cache directories
      ];
    };

    xserver = {
      # Configure keymap in X11
      xkb.layout = "us";
      xkb.variant = "altgr-intl";

      videoDrivers = ["nvidia"]; # NVIDIA
    };
  };

  # The current system was installed on 22.05, do not change.
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
