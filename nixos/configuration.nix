# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # NixCommunity binary cache
    ./cachix.nix
  ];

  # Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Keep nix-shell from grabage collection for direnv (keep-outputs + keep-derivations)
    # NOTE: nix-direnv use nix or use flake should do this automatically
    # keep-outputs = true
    # keep-derivations = true

    # Auto garbage-collect and optimize store
    gc.automatic = true;
    gc.options = "--delete-older-than 5d";
    settings.auto-optimise-store = true;
    optimise.automatic = true;

    # TODO: Understand this
    # This will add your inputs as registries, making operations with them (such
    # as nix shell nixpkgs#name) consistent with your flake inputs.
    registry = lib.mapAttrs' (n: v: lib.nameValuePair n { flake = v; }) inputs;
  };

  # TODO: Understand that
  # Will activate home-manager profiles for each user upon login
  # This is useful when using ephemeral installations
  environment.loginShellInit = ''
    [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
  '';

  # Allow unfree packages
  # Since we use HomeManager as a module with global pkgs this should also cover user packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader/Kernel stuff
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "mitigations=off" ];

    plymouth.enable = true;
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 5;
    loader.systemd-boot.editor = false;
    loader.systemd-boot.consoleMode = "max";
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";

    # Make /tmp volatile
    tmpOnTmpfs = true;
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    polkit.enable = true;

    sudo.enable = true;
    sudo.extraRules = [
      {
        users = [ "christoph" ];
        commands = [
          {
            command = "/etc/profiles/per-user/christoph/bin/gamemoderun";
            options = [ "SETENV" "NOPASSWD" ];
          }
          # We allow running flatpak without password so flatpaks can be installed from the hm config (needs sudo)
          {
            command = "/run/current-system/sw/bin/flatpak";
            options = [ "SETENV" "NOPASSWD" ];
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
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];

  # TODO: Other ports (tcp/udp/ssh...)?
  # Open ports in the firewall.
  networking = {
    # hostName = "nixinator"; # Define your hostname. # NOTE: Done in host specific config
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    firewall.allowedTCPPorts = [ ];
    firewall.allowedTCPPortRanges = [ ];

    firewall.allowedUDPPorts = [ ];
    firewall.allowedUDPPortRanges = [ ];

    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Configure keymap in X11
    # layout = "us"; # NOTE: Done in host specific config
    # xkbVariant = "altgr-intl"; # NOTE: Done in host specific config

    # Proprietary graphics drivers
    # TODO: Opengl and stuff
    # videoDrivers = [ "nvidia" ]; # NOTE: Done in host specific config

    # Startx replaces the displaymanager so default (lightdm) isn't used, start to shell
    # displayManager.startx.enable = true;

    # Plasma (X11)
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;
    # desktopManager.plasma5.runUsingSystemd = true;

    # Gnome (Wayland)
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true; # This is actually the default
    desktopManager.gnome.enable = true;
    # HomeManager gnome.gnome-keyring.enable = true;

    wacom.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;
  };

  # XDG
  xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-wlr # For wlroots based desktops
        # xdg-desktop-portal-gtk # Comes with gnome
        xdg-desktop-portal-gnome
      ];
      # gtkUsePortal = true; # Deprecated
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # We need this for low latency audio

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  fonts = {
    enableDefaultFonts = true; # Some default fonts for unicode coverage
    fontDir.enable = true; # Puts fonts to /run/current-system/sw/share/X11/fonts

    # Font packages go here, don't do this with HomeManager as I need the fonts in the fontdir for flatpak apps
    fonts = with pkgs; [
      victor-mono
      source-code-pro
      source-sans-pro
      source-serif-pro
      (pkgs.nerdfonts.override { fonts = [ "VictorMono" ]; })
      source-han-mono
      source-han-sans
      source-han-serif
      wqy_zenhei
      wqy_microhei
      # jetbrains-mono
      # etBook  
      # overpass
    ];

    # TODO: Check if this works
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Source Han Serif Regular" ];
        sansSerif = [ "Source Han Sans Regular" ];
        monospace = [ "Source Han Mono Regular" ];
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
      "realtime"
      "gamemode"
      "docker"
      "adbusers"
      "scanner"
      "lp"
      "libvirtd"
    ];
    shell = pkgs.fish; # TODO: Is this needed if programs.fish.enable = true?
    # We do this with HomeManager
    packages = with pkgs; [ ];
  };

  # Generate a list of installed system packages in /etc/current-system-packages
  environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;

  # TODO: Trusted users

  # We want these packages to be available even when no user profile is active
  # Empty since we basically only need git + editor which is enabled below
  environment.systemPackages = with pkgs; [ ];

  # TODO: Identify all the crap
  # Remove these packages that come by default with GNOME
  environment.gnome.excludePackages = with pkgs.gnome; [
    # epiphany # gnome webbrowser, could be good with new version
    # gnome-maps
    gnome-contacts
  ];

  # It is preferred to use the module (if it exists) over environment.systemPackages, as some extra configs are applied.
  # I would prefer to use HomeManager for some of these but the modules don't exist (yet)
  programs = {
    adb.enable = true;
    dconf.enable = true;
    fish.enable = true;
    git.enable = true;
    neovim.enable = true;
    starship.enable = true;
    thefuck.enable = true; # Not available in HomeManager
    xwayland.enable = true;
  };

  # List services that you want to enable:
  services = {
    # Enable CUPS to print documents.
    # TODO: Printer driver, Gnome printing
    printing.enable = true;
    avahi.enable = true; # Network printers
    avahi.nssmdns = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=50M
    '';

    # Wiki says needed for appindicators
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    acpid.enable = true;
    dbus.enable = true;
    flatpak.enable = true; # Not quite the nix style but useful for bottles/proprietary stuff
    fstrim.enable = true;
    fwupd.enable = true;
    locate.enable = true; # Periodically update index
    ntp.enable = true;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.libvirtd = { enable = true; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
