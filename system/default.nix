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

    systemd-networkd = {
      enable = true;
      hostname = hostname;

      networks = {
        # Default wildcard ethernet network for all hosts
        "50-ether" = mkSystemdNetwork "enp*";
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

  # NOTE: This should be handled by my local DNS
  # networking.hosts = {
  #   "192.168.86.50" = ["nixinator"];
  #   "192.168.86.4" = ["proxmox"];
  #   "192.168.86.20" = ["truenas"];
  #   "192.168.86.5" = ["opnsense"];
  #   "192.168.86.25" = ["servenix"];
  # };

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
    loader = {
      timeout = 120;
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      systemd-boot.editor = false;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    # Make /tmp volatile
    tmp.useTmpfs = true;
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;

    # TODO: Replace with polkit
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
    # enableNvidiaPatches = false; # NOTE: Enabled only in nixinator config
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
  xdg.mime = rec {
    enable = true;

    removedAssociations = {
      "application/pdf" = "chromium-browser.desktop";
    };

    defaultApplications = {
      "inode/directory" = "nnn.desktop";

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
      "video/quicktime" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";

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

    addedAssociations = defaultApplications;
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
    enableDefaultPackages = true; # Some default fonts for unicode coverage
    fontDir.enable = true; # Puts fonts to /run/current-system/sw/share/X11/fonts

    # Font packages go here
    # NOTE: Don't do this with HomeManager as I need the fonts in the fontdir for flatpak apps
    packages = with pkgs; [
      # Monospace fonts
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
        ];
      })

      # Sans/Serif fonts
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      lxgw-wenkai
    ];

    # TODO: Check if this works
    # TODO: Conflicts with kde?
    fontconfig = {
      enable = true;
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

    fuse.userAllowOther = true; # Allow users to mount e.g. samba shares (cifs)

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
    # locate.enable = true; # Periodically update index
    ntp.enable = true; # Clock sync
    gvfs = {
      # Network shares
      enable = true;
      package = lib.mkForce pkgs.gnome3.gvfs;
    };
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

    oci-containers.backend = "podman"; # "docker" or "podman"
    libvirtd.enable = true;

    # Follow steps from https://nixos.wiki/wiki/WayDroid
    # waydroid.enable = true;
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
