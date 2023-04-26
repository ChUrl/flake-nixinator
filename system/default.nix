# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  hostname,
  lib,
  mylib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import the host-specific system config
    ./${hostname}

    ./cachix.nix
  ];

  # Enable flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-users = ["root" "christoph"];

    # Keep nix-shell from garbage collection for direnv (keep-outputs + keep-derivations)
    # NOTE: nix-direnv use nix or use flake should do this automatically
    # keep-outputs = true
    # keep-derivations = true

    # Auto garbage-collect and optimize store
    gc.automatic = true;
    gc.options = "--delete-older-than 5d";
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    # TODO: I do not understand this
    # This will add your inputs as registries, making operations with them (such
    # as nix shell nixpkgs#name) consistent with your flake inputs.
    # (Registry contains flakes)
    registry = lib.mapAttrs' (n: v: lib.nameValuePair n {flake = v;}) inputs;
  };

  # Bootloader/Kernel stuff
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages_latest; # The package set that includes the kernel and modules
    kernelParams = ["mitigations=off"]; # I don't care about security regarding spectre/meltdown

    # plymouth.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.systemd-boot.editor = false;
    loader.systemd-boot.consoleMode = "max";
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";

    # Make /tmp volatile
    tmp.useTmpfs = true;
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    polkit.enable = true;

    sudo.enable = true;
    sudo.extraRules = [
      {
        users = ["christoph"];
        commands = [
          # Launch gamemode without password because it is annoying
          # {
          #   command = "/etc/profiles/per-user/christoph/bin/gamemoderun";
          #   options = [ "SETENV" "NOPASSWD" ];
          # }
          # {
          #   command = "${pkgs.gamemode}/libexec/cpugovctl";
          #   options = [ "SETENV" "NOPASSWD" ];
          # }

          # We allow running flatpak without password so flatpaks can be installed from the hm config (needs sudo)
          {
            command = "/run/current-system/sw/bin/flatpak";
            options = ["SETENV" "NOPASSWD"];
          }
        ];
      }
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # https://github.com/NixOS/nixpkgs/issues/179486
  i18n.supportedLocales = ["en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8"];

  # TODO: Networking system module
  # NOTE: The systemd networking options are not very flexible, so this will be a problem for the laptop. (=> Use IWD for WiFi)
  systemd = {
    network = let
      eth-interface = "enp0s31f6";
      wireless-interface = "";
    in {
      enable = true;

      # LAN
      networks."50-ether" = {
        # name = "enp0s31f6"; # Network interface name?
        enable = true;

        # See man systemd.link, man systemd.netdev, man systemd.network
        matchConfig = {
          # This corresponds to the [MATCH] section
          Name = eth-interface; # Match ethernet interface
        };

        # See man systemd.network
        networkConfig = {
          # This corresponds to the [NETWORK] section
          DHCP = "yes";

          # TODO: What does this all do?
          # IPv6AcceptRA = true;
          # MulticastDNS = "yes"; # Needed?
          # LLMNR = "no"; # Needed?
          # LinkLocalAddressing = "no"; # Needed?
        };

        linkConfig = {
          # This corresponds to the [LINK] section
          # RequiredForOnline = "routable";
        };
      };

      # TODO: WiFi Hotspot?
    };

    services = let
      # TODO: IPv6 Configuration
      wgup = interface: privatekey: publickey: endpoint: ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.iproute}/bin/ip link add ${interface} type wireguard
        ${pkgs.iproute}/bin/ip link set ${interface} netns vpn
        ${pkgs.iproute}/bin/ip netns exec vpn ${pkgs.wireguard-tools}/bin/wg set ${interface} \
          private-key /home/christoph/.secrets/wireguard/${privatekey} \
          peer ${publickey} \
          allowed-ips 0.0.0.0/0 \
          endpoint ${endpoint}:51820
        ${pkgs.iproute}/bin/ip -n vpn addr add 10.2.0.2/32 dev wg0
        ${pkgs.iproute}/bin/ip -n vpn link set wg0 up
        ${pkgs.iproute}/bin/ip -n vpn route add default dev wg0
      '';

      wgdown = interface: ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.iproute}/bin/ip -n vpn link del ${interface}
      '';
    in {
      # See https://reflexivereflection.com/posts/2018-12-18-wireguard-vpn-with-network-namespace-on-nixos.html
      # See https://try.popho.be/vpn-netns.html#automatic-with-a-systemd.service5
      # This namespace contains the WireGuard virtual network device, because this should be the only interface available for apps that should run through VPN
      netns-vpn = {
        description = "Network namespace for ProtonVPN using Wireguard";
        wantedBy = ["default.target"];
        before = ["display-manager.service" "network.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = pkgs.writeScript "create-vpn-netns" ''
            #! ${pkgs.bash}/bin/bash
            ${pkgs.iproute}/bin/ip netns add vpn # Create the Namespace
            ${pkgs.iproute}/bin/ip -n vpn link set lo up # Enable the Loopback device
          '';

          ExecStop = "${pkgs.iproute}/bin/ip netns del vpn";
        };
      };

      # TODO: This should be parametrized
      #       - Each server should get its own link?
      #       - The endpoints/public keys should be in a map?
      wg0-DE-115 = {
        description = "Wireguard ProtonVPN Server DE-115";
        requires = ["netns-vpn.service"];
        after = ["netns-vpn.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeScript "DE-115-up" (wgup "wg0-de-115" "proton-de-115.key" "9+CorlxrTsQR7qjIOVKsEkk8Z7UUS5WT3R1ccF7a0ic=" "194.126.177.14");
          ExecStop = pkgs.writeScript "DE-115-down" (wgdown "wg0-de-115");
        };
      };
    };
  };
  services.resolved.enable = true;
  services.resolved.llmnr = "false";

  # Open ports in the firewall.
  networking = {
    # Gets inherited from flake in nixos mylib
    hostName = hostname; # Define your hostname.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    enableIPv6 = true;
    networkmanager.enable = false;
    useDHCP = false; # Default: true, don't use with networkd
    dhcpcd.enable = false; # Don't use with networkd
    useNetworkd = false; # Only use this if the configuration can't be written in systemd.network completely. It translates some of the networking... options to systemd
    # resolvconf.enable = true;

    # TODO
    wireless = {
      enable = false; # Enables wireless support via wpa_supplicant.
      iwd.enable = false; # Use iwd instead of NetworkManager
    };

    firewall = {
      enable = true;
      # networking.firewall.checkReversePath = "loose";

      trustedInterfaces = [
        "podman0"
        "docker0"
      ];

      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS

        # Containers
        # 5800 # Picard
        # 8096 # Jellyfin
        # 8097 # Emby
        # 8123 # Home-Assistant
        # 32400 # Plex
      ];
      allowedTCPPortRanges = [];

      allowedUDPPorts = [
        9918 # Wireguard
        18000 # Anno 1800
        24727 # AusweisApp2, alternative: programs.ausweisapp.openFirewall
      ];
      allowedUDPPortRanges = [];
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Startx replaces the displaymanager so default (lightdm) isn't used, start to shell
    # Sadly using this with gnome-session doesn't really work
    displayManager.startx.enable = true;

    # Plasma
    # TODO: Had problems with wayland last time, hopefully I get it to work now
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;
    # desktopManager.plasma5.runUsingSystemd = true;

    # Gnome (Wayland)
    # NOTE: Not a fan of the overly simplistic nature, also made problems with the audio devices...
    # displayManager.gdm.enable = true;
    # I had problems with gdm defaulting to X11, after I added this it stopped although I don't know if this was the sole reason
    # displayManager.defaultSession = "gnome";
    # displayManager.gdm.wayland = true; # This is actually the default
    # desktopManager.gnome.enable = true;

    wacom.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  programs.hyprland = {
    enable = true;
    nvidiaPatches = false;
  };

  # XDG
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-wlr # For wlroots based desktops
      # xdg-desktop-portal-hyprland # Already enabled by hyprland system module
      # xdg-desktop-portal-kde
      xdg-desktop-portal-gtk # TODO: Keep for GTK apps? E.g. for font antialiasing? Might be required for flatpak GTK apps?
      # xdg-desktop-portal-gnome # Gnome
      # xdg-desktop-portal-termfilechooser # Filepicker using nnn
    ];
    # gtkUsePortal = true; # Deprecated, don't use (gdm takes ages to load and other fishy stuff)
  };

  # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
  xdg.mime = {
    enable = true;

    removedAssociations = {
      "application/pdf" = "chromium-browser.desktop";
    };

    # TODO: This stuff depends on the used desktop...should I use a complementary system module for each DE?
    addedAssociations = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/x-sh" = "Helix.desktop";
      "application/xhtml+xml" = "Helix.desktop";
      "application/xml" = "Helix.desktop";

      "image/bmp" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/webp" = "imv.desktop";

      "video/mp2t" = "mpv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";

      "text/css" = "Helix.desktop";
      "text/csv" = "Helix.desktop";
      "text/javascript" = "Helix.desktop";
      "text/json" = "Helix.desktop";
      "text/plain" = "Helix.desktop";
      "text/xml" = "Helix.desktop";

      # "audio/mpeg" = "moc.desktop";
      # "audio/ogg" = "moc.desktop";
      # "audio/opus" = "moc.desktop";
      # "audio/wav" = "moc.desktop";
      # "audio/webm" = "moc.desktop";
    };

    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "application/x-sh" = "Helix.desktop";
      "application/xhtml+xml" = "Helix.desktop";
      "application/xml" = "Helix.desktop";

      "image/bmp" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/webp" = "imv.desktop";

      "video/mp2t" = "mpv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";

      "text/css" = "Helix.desktop";
      "text/csv" = "Helix.desktop";
      "text/javascript" = "Helix.desktop";
      "text/json" = "Helix.desktop";
      "text/plain" = "Helix.desktop";
      "text/xml" = "Helix.desktop";

      # "audio/mpeg" = "moc.desktop";
      # "audio/ogg" = "moc.desktop";
      # "audio/opus" = "moc.desktop";
      # "audio/wav" = "moc.desktop";
      # "audio/webm" = "moc.desktop";
    };
  };

  # Enable sound with pipewire.
  sound.enable = false; # Alsa, seems to conflict with PipeWire
  hardware.pulseaudio.enable = false; # Get off my lawn
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false; # TODO: Was needed for low latency but probably not anymore (?) as Bitwig supports Pipewire now

    wireplumber.enable = true; # Probably the default
    # media-session.enable = false; # Removed upstream
  };

  fonts = {
    enableDefaultFonts = true; # Some default fonts for unicode coverage
    fontDir.enable = true; # Puts fonts to /run/current-system/sw/share/X11/fonts

    # Font packages go here
    # NOTE: Don't do this with HomeManager as I need the fonts in the fontdir for flatpak apps
    fonts = with pkgs; [
      # Mono fonts
      victor-mono
      jetbrains-mono
      source-code-pro
      (pkgs.nerdfonts.override {fonts = ["VictorMono"];})
      font-awesome

      # Chinese fonts
      source-han-mono
      source-han-sans
      source-han-serif
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_zenhei
      wqy_microhei

      # Sans/Serif fonts
      cantarell-fonts
      source-sans-pro
      source-serif-pro
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji

      # Emacs fonts
      emacs-all-the-icons-fonts
      material-design-icons

      # Some fonts from an old emacs config, not longer used
      # etBook
      # overpass
    ];

    # TODO: Check if this works
    # TODO: Conflicts with kde?
    # fontconfig = {
    #   enable = true;
    #   defaultFonts = {
    #     serif = [ "Source Han Serif Regular" ];
    #     sansSerif = [ "Source Han Sans Regular" ];
    #     monospace = [ "Source Han Mono Regular" ];
    #   };
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.christoph = {
    isNormalUser = true;
    description = "Christoph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "pipewire"
      "realtime"
      "gamemode"
      "docker"
      "podman"
      "adbusers"
      "scanner"
      "lp"
      "libvirtd"
    ];
    shell = pkgs.fish; # TODO: Is this needed if programs.fish.enable = true?
    # We do this with HomeManager
    # packages = with pkgs; [];
  };

  # Generate a list of installed system packages in /etc/current-system-packages
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  # We want these packages to be available even when no user profile is active
  # Empty since we basically only need git + editor which is enabled below
  environment.systemPackages = with pkgs; [
    iw
    mprocs # run multiple processes in single terminal window, screen alternative
    parted # partition manager
    procs # Better ps
    procps # pgrep, pkill
    slirp4netns # user network namespaces
    wireguard-tools
  ];

  # NOTE: Gnome
  # TODO: Identify all the crap
  # Remove these packages that come by default with GNOME
  # environment.gnome.excludePackages = with pkgs.gnome; [
  #   # epiphany # gnome webbrowser, could be good with new version
  #   gnome-maps
  #   gnome-contacts
  # ];

  # NOTE: Plasma
  # TODO: Identify all the crap
  # environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  # ];

  # It is preferred to use the module (if it exists) over environment.systemPackages, as some extra configs are applied.
  # I would prefer to use HomeManager for some of these but the modules don't exist (yet)
  programs = {
    adb.enable = true;
    dconf.enable = true; # NOTE: Also needed for Plasma Wayland (GTK theming)
    fish.enable = true;
    firejail.enable = true; # Use to run app in network namespace (e.g. through vpn)
    git.enable = true;
    kdeconnect.enable = true; # Use this instead of HM for firewall setup
    neovim.enable = true;
    starship.enable = true;
    thefuck.enable = true;
    xwayland.enable = true;

    # ausweisapp.openFirewall = true; # Directly set port in firewall
  };

  # List services that you want to enable:
  services = {
    # Enable CUPS to print documents.
    printing.enable = true;
    printing.drivers = with pkgs; [
      # gutenprint
      # gutenprintBin
      # foomatic-db-ppds-withNonfreeDb
      # dell-b1160w # TODO: Broken
    ];
    avahi.enable = true; # Network printers
    avahi.nssmdns = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Trims the journal if too large
    journald.extraConfig = ''
      SystemMaxUse=50M
    '';

    acpid.enable = true;
    dbus.enable = true;
    flatpak.enable = true; # Not quite the nix style but useful for bottles/proprietary stuff/steam/gaming
    fstrim.enable = true; # SSD
    fwupd.enable = true; # Device firmware (I don't think I have any supported devices)
    locate.enable = true; # Periodically update index
    ntp.enable = true; # Clock sync
    # packagekit.enable = true; # KDE Discover/Gnome Software

    # samba = {
    #   package = pkgs.samba4Full;
    #   enable = true;
    #   openFirewall = true;
    # };

    udev = {
      packages = with pkgs; [
        usb-blaster-udev-rules # For Intel Quartus
      ];
    };

    # TODO: Find a way to organize this better as it's split from the Gnome module, Gnome system module?
    gnome.gnome-keyring.enable = true; # TODO: Is probably also needed for Plasma (some apps require it)
    # gnome.sushi.enable = true;
    # gnome.gnome-settings-daemon.enable = true;
    # gnome.gnome-online-accounts.enable = true; # Probably Gnome enables this
  };

  virtualisation = {
    docker = {
      enable = false;
      autoPrune.enable = true;

      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;

      # extraPackages = with pkgs; [];
    };

    # TODO: This (or even single containers) should have their own system modules
    oci-containers.backend = "podman"; # "docker" or "podman"
    oci-containers.containers = {
      jellyfin = {
        image = "linuxserver/jellyfin";
        autoStart = false;

        ports = [
          "8096:8096/tcp"
        ];

        volumes = [
          "jellyfin-cache:/cache:Z"
          "jellyfin-config:/config:Z"
          "/home/christoph/Videos/Movies:/media/Movies:ro"
          "/home/christoph/Videos/Photos:/media/Photos:ro"
          # "/home/christoph/Music/Spotify:/media/Music:ro"
        ];
      };

      picard = {
        image = "mikenye/picard";
        autoStart = false;

        ports = [
          "5800:5800"
        ];

        volumes = [
          "picard-config:/config:Z"
          "/home/christoph/Music/Spotify:/storage:rw,private"
        ];
      };

      homeassistant = {
        image = "homeassistant/home-assistant";
        autoStart = false;

        ports = [
          "8123:8123"
        ];

        volumes = [
          "homeassistant-config:/config:Z"
        ];
      };

      # plex = {
      #   image = "linuxserver/plex";
      #   autoStart = false;

      #   ports = [
      #     "32400:32400/tcp"
      #   ];

      #   volumes = [
      #     "plex-config:/config:Z"
      #     "plex-transcode:/transcode:Z"
      #     "/home/christoph/Videos/Movies:/data/Movies:ro"
      #     "/home/christoph/Music/Spotify:/data/Music:ro"
      #   ];
      # };

      # emby = {
      #   image = "linuxserver/emby";
      #   autoStart = false;

      #   ports = [
      #     # Host port 8096 already used by Jellyfin
      #     "8097:8096"
      #   ];

      #   volumes = [
      #     "emby-config:/config:Z"
      #     "/home/christoph/Videos/Movies:/data/movies:ro"
      #     "/home/christoph/Videos/Pictures:/data/pictures:ro"
      #     "/home/christoph/Music/Spotify:/data/music:ro"
      #   ];
      # };
    };

    libvirtd.enable = true;

    # NOTE: Pretty unusable as NVidia hardware acceleration is not supported...
    # Follow steps from https://nixos.wiki/wiki/WayDroid
    # waydroid. enable = true;
    # lxd.enable = true;
  };

  # NOTE: Current system was installed on 22.05, do not change
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
