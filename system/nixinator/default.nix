{
  lib,
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

    # General services
    ../services/docker/fileflows-node.nix
    (import ../services/docker/arcane-agent.nix {
      tokenSecret = "arcane-agent-nixinator-key";
      backupsPath = "/home/${username}/Arcane";
    })
  ];

  # Append this to the default config set from mkCommonNixSettings
  # in lib/nixos. The gccarch-znver4 is required for the host-specific
  # platform config (gcc.arch = znver4) in flake.nix
  nix.settings.system-features = [
    "nixos-test"
    "benchmark"
    "big-parallel"
    "kvm"
    "gccarch-znver4"
  ];

  systemmodules = {
    bootloader = {
      # Secure boot
      loader = "lanzaboote";
    };

    impermanence.enable = true;

    # Binary cache for servenix and thinknix
    nix-cache.enable = true;

    network = {
      useNetworkManager = true;

      # Systemd-networkd configs
      networks = let
        # TODO: mylib.networking.mkStaticSystemdNetwork needs improvement to accomodate for this
        mkConfig = name: routable: rec {
          enable = true;

          # See man systemd.link, man systemd.netdev, man systemd.network
          matchConfig = {
            # This corresponds to the [MATCH] section
            Name = name; # Match ethernet interface
          };

          # Static IP + DNS + Gateway
          address = ["192.168.86.50/24"];
          gateway = ["192.168.86.5"]; # Don't add "fd00::5", rely on router advertisement instead
          dns = ["192.168.86.26" "fd00::1a" "8.8.8.8" "8.8.4.4" "2001:4860:4860::8888" "2001:4860:4860::8844"];
          routes = builtins.map (r: {Gateway = r;}) gateway;

          # See man systemd.network
          networkConfig = {
            # This corresponds to the [NETWORK] section
            DHCP = "no";

            IPv6AcceptRA = "yes"; # Accept Router Advertisements
            # MulticastDNS = "no";
            # LLMNR = "no";
            # LinkLocalAddressing = "ipv6";
          };

          addresses = [
            {
              # Don't add this to address, we don't want to create any routes with this
              Address = "fd00::32/64"; # IPv6 Unique-Local Address (ULA)
            }
          ];

          linkConfig = {
            # This corresponds to the [LINK] section
            RequiredForOnline = routable;
          };
        };
      in {
        # "10-ether-2_5G" = mylib.networking.mkStaticSystemdNetwork {
        #   interface = "enp8s0";
        #   ips = ["192.168.86.50/24"];
        #   routers = ["192.168.86.5"];
        #   nameservers = ["192.168.86.26" "8.8.8.8"];
        #   routable = true;
        # };
        # "10-ether-1G" = mylib.networking.mkStaticSystemdNetwork {
        #   interface = "enp5s0";
        #   ips = ["192.168.86.50/24"];
        #   routers = ["192.168.86.5"];
        #   nameservers = ["192.168.86.26" "8.8.8.8"];
        #   routable = false;
        # };

        # This should override the default network 50-ether
        "10-ether-1G" = mkConfig "enp5s0" "no";
        "10-ether-2_5G" = mkConfig "enp8s0" "routable";
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
          # nameserver = "192.168.86.26;8.8.8.8;"; # Google fallback
          nameserver = "192.168.86.26;";
          ip6 = "fd00::32/64";
          # router6 = "fd00::5"; # Should be configured automatically
          # nameserver6 = "2001:4860:4860::8888;2001:4860:4860::8844;"; # Google
          nameserver6 = "fd00::1a;";
          priority = 10; # Rather connect to 2.5G than to 1G
        };
        "10-ether-1G" = mylib.networking.mkStaticNetworkManagerProfile {
          id = "Wired 1G";
          interface = "enp5s0";
          ip = "192.168.86.50/24";
          router = "192.168.86.5";
          # nameserver = "192.168.86.26;8.8.8.8;"; # Google fallback
          nameserver = "192.168.86.26;";
          ip6 = "fd00::32/64";
          # router6 = "fd00::5"; # Should be configured automatically
          # nameserver6 = "2001:4860:4860::8888;2001:4860:4860::8844;"; # Google
          nameserver6 = "fd00::1a;";
        };
      };

      allowedTCPPorts = [
        1111 # FAIL*
        # 4242 # Lan-Mouse
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        53317 # LocalSend
      ];

      allowedUDPPorts = [
        1111 # FAIL*
        # 4242 # Lan-Mouse
        # 7777 # AvaTalk
        # 12777 # AvaTalk
        # 31431 # Parsec
        5173 # SvelteKit
        8090 # PocketBase
        53317 # LocalSend
      ];
    };

    restic = {
      enable = true;

      paths = ["/persist"];

      extraBackupArgs = [
        "--one-file-system" # Nothing outside /persist
        "--exclude-caches" # Excludes marked cache directories
        "--cleanup-cache" # Auto remove old cache directories
        "--exclude=/persist/home/${username}/.var/app" # flatpak
        "--exclude=/persist/home/${username}/.lmstudio/models"
        "--exclude=/persist/home/${username}/.cache"
        "--exclude=/persist/var/cache"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];

      randomizedDelaySec = "5h";
      createWrapper = true;
    };

    # When connecting from outside, do a proxyjump to this port
    ssh.port = 5432;

    # Every external SSH client arrives as 10.10.10.1 through WireGuard,
    # so fail2ban and OpenSSH's PerSourcePenalties cannot distinguish a bot
    # from a legitimate login and ban the proxy itself.
    # Because the VPS already runs fail2ban, bots should not reach nixinator,
    # So keep this disabled for now.
    # ssh.trustedSources = ["10.10.10.1/32"];
  };

  # Dedicated key for the Nix remote builder used by servenix/thinknix.
  # Restricted to the store-serving protocol.
  users.users.christoph.openssh.authorizedKeys.keys = [
    ''command="nix-store --serve --write",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfoH83jY9OGFSnDhy8oOnJ2mZAyxpOAE4mJ96iHZJWi builder@nixos''
  ];

  # NOTE: Sops needs the keys before impermanence kicks in
  #       so we have to link to /persist directly...
  sops.age.keyFile = "/persist/home/${username}/.secrets/age/age.key";

  sops.secrets."makemkv-app-key" = {};

  sops.templates."makemkv-settings.conf" = {
    owner = config.users.users.${username}.name;
    content = ''
      app_Key = "${config.sops.placeholder.makemkv-app-key}"
      sdf_Stop = ""
    '';
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_latest;

    # Why do I need to know if something fails during boot???
    # consoleLogLevel = 3;
    # initrd.verbose = false;
    # initrd.systemd.enable = true;
    kernelParams = [
      # Doesn't work, there is only a single framebuffer,
      # so the smallest monitor determines the size
      # "video=DP-1:3440x1440"
      # "video=DP-2:1920x1080"

      # "quiet"
      # "splash"
      # "intremap=on"
      # "boot.shell_on_fail"
      # "udev.log_priority=3"
      # "rd.systemd.show_status=auto"
    ];
    # plymouth = {
    #   enable = false;
    #   font = "${pkgs.monolisa}/share/fonts/truetype/MonoLisa-AltPars-Straight.ttf";
    #   logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
    #
    #   theme = "colorful_sliced";
    #   themePackages = with pkgs; [
    #     # By default we would install all themes
    #     (adi1090x-plymouth-themes.override {
    #       selected_themes = ["colorful_sliced"];
    #     })
    #   ];
    # };
  };

  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
  ];

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # TODO: Duplicated from fonts module (set this inside fonts module?)
    fonts = {
      serif = {
        package = pkgs.noto-fonts-cjk-serif;
        name = "Noto Serif CJK SC";
      };
      sansSerif = {
        package = pkgs.noto-fonts-cjk-sans;
        name = "Noto Sans CJK SC";
      };
      monospace = {
        package = pkgs.monolisa;
        name = "MonoLisa Alt Script";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    targets = {};
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        # ovmf.enable = true; # deprecated
        swtpm.enable = true;
        runAsRoot = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  networking.firewall.trustedInterfaces = ["virbr0"]; # libvirt

  programs = {
    ausweisapp = {
      enable = true;
      openFirewall = true; # Directly set port in firewall
    };

    # TODO: Doesn't work with steam flatpak
    # gamescope = {
    #   enable = true;
    #   enableWsi = true;
    # };

    ghidra = {
      enable = true;
      gdb = true;
    };

    gphoto2.enable = true;

    steam.platformOptimizations.enable = true; # From nix-gaming module
    virt-manager.enable = true;
  };

  services = {
    # desktopManager.plasma6.enable = true;
    # displayManager.gdm.enable = true; # Somehow, Plasma's own manager didn't work

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };

    kmscon = {
      enable = false;
      useXkbConfig = true;
      # autologinUser = username;

      config = let
        color = config.home-manager.users.${username}.homemodules.color;
      in {
        # term=xterm-256color

        hwaccel = true;

        font-name = color.font;
        font-size = 14;

        mode = "3440x1440";
        palette = "custom";

        palette-black = "0,0,0";
        pallette-white = "255,255,255";

        palette-red = color.rgbS.red;
        palette-light-red = color.rgbS.red;

        palette-green = color.rgbS.green;
        palette-light-green = color.rgbS.green;

        palette-yellow = color.rgbS.yellow;
        palette-light-yellow = color.rgbS.yellow;

        palette-blue = color.rgbS.blue;
        palette-light-blue = color.rgbS.blue;

        palette-magenta = color.rgbS.pink;
        palette-light-magenta = color.rgbS.pink;

        palette-cyan = color.rgbS.teal;
        palette-light-cyan = color.rgbS.teal;

        palette-foreground = color.rgbS.text;
        palette-background = "0,0,0";
      };

      # NOTE: Do NOT use multline strings here!
      #       This will create a linebreak in the systemd service and break login!
      extraOptions = "";
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
      dataDir = "/persist/var/lib/mysql";
      settings.mysqld = {
        bind-address = "127.0.0.1";
        port = 3307; # 3306 is taken by the Mars SSH tunnel
      };
      initialScript = pkgs.writeText "mysql-initial.sql" ''
        CREATE USER IF NOT EXISTS 'smchurla'@'127.0.0.1' IDENTIFIED BY 'abcdefg';
        GRANT ALL PRIVILEGES ON *.* TO 'smchurla'@'127.0.0.1';
        FLUSH PRIVILEGES;
      '';
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
