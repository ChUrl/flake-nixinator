# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
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
      useNetworkManager = true;

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
  };

  # Enable flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-users = ["root" "christoph"];

    # Auto garbage-collect and optimize store
    # gc.automatic = true; # NOTE: Disabled for "nh clean"
    gc.options = "--delete-older-than 5d";
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    # This will add your inputs as registries, making operations with them (such
    # as nix shell nixpkgs#name) consistent with your flake inputs.
    # (Registry contains flakes)
    registry = lib.mapAttrs' (n: v: lib.nameValuePair n {flake = v;}) inputs;

    # Set NIX_PATH to find nixpgks
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}" "home-manager=${inputs.home-manager.outPath}"];
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
        users = ["christoph"];
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
    man.generateCaches = false; # very slow
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.christoph = {
    isNormalUser = true;
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
    dconf.enable = true;
    fish.enable = true;
    firejail.enable = true; # Use to run app in network namespace (e.g. through vpn)
    git.enable = true;
    kdeconnect.enable = !headless; # Use this instead of HM for firewall setup
    neovim.enable = true;
    starship.enable = true;
    # pay-respects.enable = true; # The new fuck
    xwayland.enable = !headless;
    nix-ld.enable = true; # Load dynamically linked executables

    hyprland = {
      enable = !headless;
      xwayland.enable = true;
      withUWSM = true;
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 3";
      flake = "/home/christoph/NixFlake";
    };

    ssh = {
      startAgent = true;
      # enableAskPassword = true;
      # askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };

    fuse.userAllowOther = true; # Allow users to mount e.g. samba shares (cifs)
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
    libinput.enable = true;

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
    flatpak.enable = true; # Not quite the nix style but useful for bottles/proprietary stuff/steam/gaming
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

    oci-containers.backend = "podman"; # "docker" or "podman"
    libvirtd.enable = true;
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
        User = "${username}"; # ⚠️ replace with your "username" or "${user}", if it's defined
      };
      script = ''
        set -eu
        echo "Start refreshing nps cache..."
        ${inputs.nps.packages.${system}.default}/bin/nps -dddd -e -r
        echo "... finished nps cache with exit code $?."
      '';
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
