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
  system,
  username,
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
    polkit.enable = true;

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
        24727 # AusweisApp2
      ];
    };
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

    # plymouth.enable = true;
    loader = {
      timeout = 120;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

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
    dev.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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

  xdg = {
    # See https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
    # Find .desktop files: fd ".*\.desktop" / | grep --color=auto -E neovide
    mime = let
      textTypes = [
        "text/css"
        "text/csv"
        "text/javascript"
        "text/plain"
        "text/xml"
        "application/json"
        "application/ld+json"
        "application/x-sh"
        "application/xml"
      ];
      imageTypes = [
        "image/apng"
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/jpeg"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ];
      audioTypes = [
        "audio/aac"
        "audio/mpeg"
        "audio/ogg"
        "audio/opus"
        "audio/wav"
        "audio/webm"
        "audio/3gpp"
        "audio/3gpp2"
      ];
      videoTypes = [
        "video/x-msvideo"
        "video/mp4"
        "video/mpeg"
        "video/ogg"
        "video/mp2t"
        "video/webm"
        "video/3gpp"
        "video/3gpp2"
      ];
      webTypes = [
        "text/uri-list"
        "text/x-uri"
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/https"
      ];
    in rec {
      enable = true;

      defaultApplications = let
        associations = {
          "neovide.desktop" = textTypes ++ [];
          "yazi.desktop" = ["inode/directory"];
          "firefox.desktop" = webTypes ++ [];
          "org.pwmt.zathura.desktop" = ["application/pdf"];
          "imv-dir.desktop" = imageTypes ++ []; # imv-dir autoselects the directory so next/prev works
          "vlc.desktop" = audioTypes ++ videoTypes ++ [];
        };

        # Applied to a single app and a single type
        mkAssociation = app: type: {${type} = [app];}; # Result: { "image/jpg" = ["imv.desktop"]; }

        # Applied to a single app and a list of types
        mkAssociations = app: types: lib.mergeAttrsList (builtins.map (mkAssociation app) types); # Result: { "image/jpg" = ["imv.desktop"]; "image/png" = ["imv.desktop"]; ... }
      in
        # Apply to a list of apps each with a list of types
        lib.mergeAttrsList (lib.mapAttrsToList mkAssociations associations);

      addedAssociations = defaultApplications;

      removedAssociations = let
        fromTextTypes = [
          "nvim.desktop"
        ];

        fromImageTypes = [
          "imv.desktop"
          "chromium-browser.desktop"
          "org.kde.krita.desktop"
          "krita.desktop"
          "krita_svg.desktop"
          "krita_raw.desktop"
          "krita_heif.desktop"
          "krita_webp.desktop"
          "krita_gif.desktop"
          "krita_brush.desktop"
          "krita_xcf.desktop"
          "krita_jpeg.desktop"
          "krita_spriter.desktop"
          "krita_jxl.desktop"
          "krita_ora.desktop"
          "krita_csv.desktop"
          "krita_tga.desktop"
          "krita_psd.desktop"
          "krita_png.desktop"
          "krita_tiff.desktop"
          "krita_exr.desktop"
          "krita_qimageio.desktop"
          "krita_pdf.desktop"
          "krita_jp2.desktop"
          "krita_heightmap.desktop"
          "krita_kra.desktop"
          "krita_krz.desktop"
        ];

        fromAudioTypes = [];

        fromVideoTypes = [];

        fromWebTypes = [
          "chromium-browser.desktop"
          "com.google.Chrome.desktop"
        ];

        # Applied to a list of apps and a single type
        removeAssociation = apps: type: {${type} = apps;};

        # Applied to a list of apps and a list of types: For each type the list of apps should be removed
        removeAssociations = apps: types: lib.mergeAttrsList (builtins.map (removeAssociation apps) types);
      in
        lib.mergeAttrsList [
          {
            "application/pdf" = [
              "chromium-browser.desktop"
              "com.google.Chrome.desktop"
              "firefox.desktop"
            ];
            "text/plain" = [
              "firefox.desktop"
              "code.desktop"
            ];
          }

          # Only activate those if applications to remove are specified: (len from...Types) > 0
          (lib.optionalAttrs (builtins.lessThan 0 (builtins.length fromTextTypes))
            (removeAssociations fromTextTypes textTypes))
          (lib.optionalAttrs (builtins.lessThan 0 (builtins.length fromImageTypes))
            (removeAssociations fromImageTypes imageTypes))
          (lib.optionalAttrs (builtins.lessThan 0 (builtins.length fromAudioTypes))
            (removeAssociations fromAudioTypes audioTypes))
          (lib.optionalAttrs (builtins.lessThan 0 (builtins.length fromVideoTypes))
            (removeAssociations fromVideoTypes videoTypes))
          (lib.optionalAttrs (builtins.lessThan 0 (builtins.length fromWebTypes))
            (removeAssociations fromWebTypes webTypes))
        ];
    };

    # XDG
    portal = {
      enable = true;
      xdgOpenUsePortal = false;
      config.common.default = ["*"]; # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/26
      wlr.enable = false; # Hyprland has its own portal automatically enabled...
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk

        # xdg-desktop-portal-kde
        # xdg-desktop-portal-hyprland # Already enabled by hyprland system module
        # xdg-desktop-portal-termfilechooser # Filepicker using nnn
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true; # Some default fonts for unicode coverage
    fontDir.enable = true; # Puts fonts to /run/current-system/sw/share/X11/fonts

    # Font packages go here.
    # They are installed system-wide so they land in fontdir,
    # this is required for flatpak to find them.
    packages = with pkgs; [
      # Monospace fonts
      nerd-fonts.jetbrains-mono

      # Sans/Serif fonts
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      lxgw-wenkai
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      hinting.autohint = true;
      cache32Bit = true;
      defaultFonts = {
        serif = ["Noto Serif CJK SC"];
        sansSerif = ["Noto Sans CJK SC"];
        monospace = ["JetBrainsMono Nerd Font Mono"];
      };
    };
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

    # iPhone tethering + mounting
    libimobiledevice
    ifuse
    usbmuxd

    mprocs # run multiple processes in single terminal window, screen alternative
    parted # partition manager
    procs # Better ps
    procps # pgrep, pkill
    slirp4netns # user network namespaces
    wireguard-tools
    man-pages
    man-pages-posix

    # Sets NIX_LD_LIBRARY_PATH and NIX_LD variables for nix-ld
    # Start dynamically linked executable using "nix-alien-ld -- <Executable>"
    inputs.nix-alien.packages.${system}.nix-alien

    # Search nixpkgs
    inputs.nps.packages.${system}.default

    # egl-wayland
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
    kdeconnect.enable = false; # Use this instead of HM for firewall setup
    neovim.enable = true;
    starship.enable = true;
    # pay-respects.enable = true; # The new fuck
    xwayland.enable = true;
    nix-ld.enable = true; # Load dynamically linked executables

    hyprland = {
      enable = true;
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
    # ausweisapp.openFirewall = true; # Directly set port in firewall
  };

  # List services that you want to enable:
  services = {
    # Enable sound with pipewire.
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = false;
      wireplumber.enable = true;
    };
    pulseaudio.enable = false; # Get off my lawn

    # Enable the X11 windowing system.
    xserver = {
      enable = true;

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

    gnome.gnome-keyring.enable = false; # TODO: Do apps require this?
    gnome.gcr-ssh-agent.enable = false;
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
