# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # NixCommunity binary cache
      ./cachix.nix
    ];

  # Enable flakes
  # Keep nix-shell from grabage collection for direnv (keep-outputs + keep-derivations)
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes

      keep-outputs = true
      keep-derivations = true
    '';
  };

  # Auto garbage-collect and optimize store
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 5d";
  nix.autoOptimiseStore = true;
  nix.optimise.automatic = true;

  # TODO: Understand this
  # This will add your inputs as registries, making operations with them (such
  # as nix shell nixpkgs#name) consistent with your flake inputs.
  nix.registry = lib.mapAttrs' (n: v: lib.nameValuePair n { flake = v; }) inputs;

  # TODO: Understand that
  # Will activate home-manager profiles for each user upon login
  # This is useful when using ephemeral installations
  environment.loginShellInit = ''
    [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
  '';

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "mitigations=off" ];
  security.protectKernelImage = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  hardware.cpu.intel.updateMicrocode = true;

  # Make /tmp volatile
  boot.tmpOnTmpfs = true;

  networking.hostName = "nixinator"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.modesetting.enable = true; # Not officially supported by NVidia
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.runUsingSystemd = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # TODO: Printer driver
  services.avahi.enable = true; # Network printers
  services.avahi.nssmdns = true;
  hardware.sane.enable = true; # Scanning

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true; # We need this for low latency audio

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.christoph = {
    isNormalUser = true;
    description = "Christoph";
    extraGroups = [ "networkmanager" "wheel" "audio" "realtime" "docker" "adbusers" "scanner" "lp" ];
    shell = pkgs.fish; # TODO: Is this needed if programs.fish.enable = true?
    # We do this with HomeManager
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use all redistributable firmware (i.e. nonfree)
  hardware.enableRedistributableFirmware = true;

  # We want these packages to be available even when no user profile is active
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
  ];

  # It is preferred to use the module (if it exists) over environment.systemPackages, as some extra configs are applied.
  programs.adb.enable = true;
  programs.fish.enable = true;
  programs.git.enable = true;
  programs.neovim.enable = true;
  programs.starship.enable = true;
  programs.thefuck.enable = true; # Not available in HomeManager

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=50M
  '';

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.locate.enable = true; # Periodically update index
  services.ntp.enable = true;
  services.xserver.wacom.enable = true;

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
  };

  # TODO: Other ports (tcp/udp/ssh...)?
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedTCPPortRanges = [
    { # KDEConnect
      from = 1714;
      to = 1764;
    }
  ];

  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowedUDPPortRanges = [
    { # KDEConnect
      from = 1714;
      to = 1764;
    }
  ];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
