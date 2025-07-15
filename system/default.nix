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
}:
with mylib.networking; {
  imports = [
    # Import my system modules
    ./modules

    # Import the host-specific system config
    ./${hostname}

    ./cachix.nix
  ];

  modules = {
    bootloader = {
      enable = true;

      loader =
        if headless
        then "grub"
        else "systemd-boot";
      systemd-boot.bootDevice = "/boot/efi";
      grub.bootDevice = "/dev/sda";
    };

    desktopportal = {
      enable = !headless;

      termfilechooser.enable = true;
      hyprland.enable = config.programs.hyprland.enable;
    };

    docker = {
      enable = true;

      # Use podman on the desktops, the servers are
      # already configured using docker though...
      # TODO: Use podman on the servers
      podman = !headless;
      docker.rootless = true;
    };

    fonts = {
      enable = !headless;

      defaultSerifFont = "Noto Serif CJK SC";
      defaultSansSerifFont = "Noto Sans CJK SC";
      defaultMonoFont = "MonoLisa Alt Script";
    };

    mime = {
      enable = !headless;

      defaultTextEditor = "neovide.desktop";
      defaultFileBrowser = "yazi.desktop";
      defaultWebBrowser = "firefox.desktop";
      defaultPdfViewer = "org.pwmt.zathura.desktop";
      defaultImageViewer = "imv-dir.desktop";
      defaultAudioPlayer = "vlc.desktop";
      defaultVideoPlayer = "vlc.desktop";
    };

    network = {
      inherit hostname;
      enable = true;

      networks = {
        # Default wildcard ethernet network for all hosts
        "50-ether" = mkSystemdNetwork "enp*" false;
      };

      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
      ];
      allowedUDPPorts = [
        9918 # Wireguard
      ];
    };

    polkit.enable = true;

    sops-nix.bootSecrets.${username} = [
      "user-password"
    ];

    sops-nix.secrets.${username} = [
      "ssh-private-key"
      "nix-github-token"
      "docker-password"
    ];
  };

  # Write the nix user config file here so we have secrets access
  sops.templates."nix.conf" = {
    owner = config.users.users.${username}.name;
    group = config.users.users.${username}.group;
    content = ''
      access-tokens = github.com=${config.sops.placeholder.nix-github-token}
    '';
  };

  # Enable flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';

    settings.trusted-users = ["root" "${username}"];

    # Auto garbage-collect and optimize store
    gc.automatic = false; #  Done by nh.clean.enable;
    gc.options = "--delete-older-than 5d";
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    # This will add your inputs as registries, making operations with them (such
    # as nix shell nixpkgs#name) consistent with your flake inputs.
    # (Registry contains flakes)
    registry = lib.mapAttrs' (n: v: lib.nameValuePair n {flake = v;}) inputs;

    # Set NIX_PATH to find nixpgks
    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "home-manager=${inputs.home-manager.outPath}"
    ];
  };

  # Bootloader/Kernel stuff
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = ["mitigations=off"]; # I don't care

    # Make /tmp volatile
    # NOTE: Setting this to true can lead to large derivations running out of tmp space
    tmp.useTmpfs = false;
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;

    pam.services = {
      # Allow Hyprlock to unlock the system
      hyprlock = {};
    };

    sudo.enable = true;
    sudo.extraRules = [
      {
        users = ["${username}"];
        commands = [
          # We allow running flatpak without password
          # so flatpaks can be installed from the hm config
          {
            command = "/run/current-system/sw/bin/flatpak";
            options = ["SETENV" "NOPASSWD"];
          }
        ];
      }
    ];
  };

  documentation = {
    enable = true;
    man.enable = true;
    man.generateCaches = true; # Slow but needed for neovim man picker
    info.enable = true;
    dev.enable = true;
    doc.enable = false;
    nixos = {
      enable = true;
      includeAllModules = true;
    };
  };

  # Set your time zone.
  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = false;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
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
    supportedLocales = ["en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8"];
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Password is set from sops-nix secrets automatically.
  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.user-password.path;
    description = "Christoph";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
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
    shell = pkgs.fish;

    # We do this with HomeManager
    # packages = with pkgs; [];
  };

  # We want these packages to be available even when no user profile is active
  # Empty since we basically only need git + editor which is enabled below
  environment.systemPackages = with pkgs; [
    iw
    wget
    mprocs # run multiple processes in single terminal window, screen alternative
    parted # partition manager
    exfat
    procs # Better ps
    procps # pgrep, pkill
    busybox
    killall
    slirp4netns # user network namespaces
    wireguard-tools
    man-pages
    man-pages-posix

    # iPhone tethering + mounting
    libimobiledevice
    ifuse
    usbmuxd
  ];

  # It is preferred to use the module (if it exists) over environment.systemPackages,
  # as some extra configs are applied.
  # I would prefer to use HomeManager for some of these but the modules don't exist (yet).
  programs = {
    adb.enable = true;
    dconf.enable = !headless;
    fish.enable = true;
    firejail.enable = true; # Use to run app in network namespace (e.g. through vpn)
    fuse.userAllowOther = true; # Allow users to mount e.g. samba shares (cifs)
    git.enable = true;
    kdeconnect.enable = !headless; # Use this instead of HM for firewall setup
    neovim.enable = true;
    nix-ld.enable = true; # Load dynamically linked executables

    gnupg.agent = {
      enable = false;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
    };

    hyprland = {
      enable = !headless;
      xwayland.enable = true;
      withUWSM = true;
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 3";
      flake = "/home/${username}/NixFlake";
    };

    ssh.startAgent = true; # Use gnupg
    starship.enable = true;
    xwayland.enable = !headless;
  };

  # List services that you want to enable:
  services = {
    # Enable sound with pipewire.
    pipewire = {
      enable = !headless;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
      wireplumber.enable = true;
    };
    pulseaudio.enable = false; # Get off my lawn

    # Enable the X11 windowing system.
    xserver = {
      enable = !headless;

      # Startx replaces the displaymanager so default (lightdm) isn't used, start to shell
      displayManager.startx.enable = true;

      wacom.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = !headless;

    # Enable CUPS to print documents.
    printing = {
      enable = false;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        foomatic-db-ppds-withNonfreeDb
        dell-b1160w # TODO: Broken
      ];
    };

    avahi = {
      enable = false; # Network printers
      nssmdns4 = true;
    };

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Trims the journal if too large
    journald.extraConfig = ''
      SystemMaxUse=50M
    '';

    acpid.enable = true;
    dbus.enable = true;
    flatpak.enable = !headless; # Not quite the nix style but useful for bottles/proprietary stuff/steam/gaming
    fstrim.enable = true; # SSD
    fwupd.enable = true; # Device firmware (I don't think I have any supported devices)
    # locate.enable = true; # Periodically update index
    ntp.enable = true; # Clock sync
    gvfs.enable = true; # Network shares, spotify cover art caching, ...
    udev = {
      packages = with pkgs; [
        usb-blaster-udev-rules # For Intel Quartus
      ];
    };

    gnome.gnome-keyring.enable = true; # Apps (e.g. nextcloud) require this
    gnome.gcr-ssh-agent.enable = false; # TODO: Use this instead of ssh.startAgent?
  };

  systemd = {
    # TODO: Technically this should be a user service if it runs as ${username}?
    timers."refresh-nps-cache" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly"; # or however often you'd like
        Persistent = true;
        Unit = "refresh-nps-cache.service";
      };
    };

    services."refresh-nps-cache" = {
      # Make sure `nix` and `nix-env` are findable by systemd.services.
      path = ["/run/current-system/sw/"];
      serviceConfig = {
        Type = "oneshot";
        User = "${username}";
      };
      script = ''
        set -eu
        echo "Start refreshing nps cache..."
        ${inputs.nps.packages.${system}.default}/bin/nps -dddd -e -r
        echo "... finished nps cache with exit code $?."
      '';
    };
  };
}
