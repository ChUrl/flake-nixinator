# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# This is a module
# Because no imports/options/config is defined explicitly, everything is treated as config
# { inputs, lib, ... }: { ... } gets turned into { inputs, lib, ... }: { config = { ... }; } implicitly
rec {

  # Every module is a nix expression, specifically a function { inputs, lib, ... }: { ... }
  # Every module (/function) is called with the same arguments as this module (home.nix)
  # Arguments with matching names are "plugged in" into the right slots,
  # the case of different arity is handled by always providing ellipses (...) in module definitions
  imports = [
    # Import the host-specific user-config
    ./${hostname}

    ../../modules

    # inputs.nixvim.homeManagerModules.nixvim
  ];

  modules = {
    # Config my modules
    emacs = {
      enable = true;
      pgtkNativeComp = true;

      doom.enable = true;
      doom.autoSync = true;
      doom.autoUpgrade = false; # Very volatile as the upgrade fails sometimes with bleeding edge emacs
    };

    firefox = {
      enable = true;
      wayland = true;
      vaapi = true;
      disableTabBar = true;
    };

    fish.enable = true;

    flatpak = {
      enable = true;
      autoUpdate = true;
      autoPrune = true;

      discord.enable = false;
      spotify.enable = true;
    };

    kitty.enable = true;

    misc = {
      enable = true;

      keepass = {
        enable = true;
        autostart = true;
      };
    };

    nextcloud = {
      enable = true;
      autostart = true;
    };
  };

  # TODO: Gnome terminal config
  # TODO: Autostart keepass
  # TODO: Store the external binaries for my derivations in GitHub LFS (Vital, NeuralDSP, other plugins etc.)
  # TODO: Derivations for bottles like UPlay, NeuralDSP, LoL (don't know what is possible with bottles-cli though)
  # TODO: When bottles derivations are there remove the bottles option from audio/gaming module and assert that bottles is enabled in flatpak module
  # TODO: Fix chinese input

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-gtk
    libsForQt5.fcitx5-qt
    fcitx5-chinese-addons
    fcitx5-configtool # TODO: Remove this and set config through HomeManager
  ];

  # Make fonts installed through user packages available to applications
  # NOTE: I don't think I need this anymore as all fonts are installed through the system config but let's keep this just in case
  fonts.fontconfig.enable = true; # Also updates the font-cache

  # TODO: Move to gaming modules
  home.file.".local/share/flatpak/overrides/com.valvesoftware.Steam".text = ''
    [Context]
    filesystems=${home.homeDirectory}/GameSSD;${home.homeDirectory}/GameHDD
  '';
  home.file.".local/share/flatpak/overrides/com.usebottles.bottles".text = ''
    [Context]
    filesystems=${home.homeDirectory}/.var/app/com.valvesoftware.Steam/data/Steam;${home.homeDirectory}/Downloads;${home.homeDirectory}/GameSSD;${home.homeDirectory}/GameHDD
  '';

  # Generate a list of installed user packages in ~/.local/share/current-user-packages
  home.file.".local/share/current-user-packages".text =
    let
      packages = builtins.map (p: "${p.name}") home.packages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;

  gtk = {
    enable = true;

    # I guess this gets set by home.pointerCursor
    # cursorTheme.package = pkgs.numix-cursor-theme;
    # cursorTheme.name = "Numix-Cursor";

    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus";

    # theme.package = pkgs.whitesur-gtk-theme;
    # theme.name = "WhiteSur-light-solid";
  };

  home = {
    username = username; # Inherited from flake.nix
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";

      DOCKER_BUILDKIT = 1;

      # Enable wayland
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";

      # Don't use system wine, use bottles
      # WINEESYNC = 1;
      # WINEFSYNC = 1;
      # WINEPREFIX = "/home/christoph/.wine";

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # sessionPath = [];

    pointerCursor.package = pkgs.numix-cursor-theme;
    pointerCursor.gtk.enable = true;
    pointerCursor.name = "Numix-Cursor";
    pointerCursor.x11.enable = true;

    # Do not change
    stateVersion = "22.05";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CLI Tools
    procs
    tokei
    rsync
    # rclone
    xclip
    xorg.xwininfo
    xdotool
    poppler_utils # pdfunite
    ffmpeg
    imagemagick
    # htop
    # httpie
    ripgrep
    nvd # nix rebuild diff
    neofetch # Easily see interesting package versions/kernel
    lazygit

    # Some basics should be available everywhere
    # This makes problems with conflicts in nix-store, for example gcc/ld and binutils/ld or different python versions
    # python311
    # gcc # nvim needs this

    # Gnome extensions
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.vitals
    gnomeExtensions.no-overview
    # gnomeExtensions.switch-workspace
    gnomeExtensions.maximize-to-empty-workspace
    gnomeExtensions.pip-on-top
    gnomeExtensions.custom-hot-corners-extended
    # gnomeExtensions.dock-from-dash
    gnomeExtensions.gamemode
    # gnomeExtensions.gsconnect # kde connect alternative
    # gnomeExtensions.quake-mode # dropdown for any application
    # gnomeExtensions.systemd-manager # to quickly start nextcloud
    gnomeExtensions.extensions-sync
    gnomeExtensions.tweaks-in-system-menu
    # gnomeExtensions.compiz-windows-effect # WobBlY wiNdoWS
    gnomeExtensions.panel-scroll
    gnomeExtensions.rounded-window-corners
    # gnomeExtensions.easyeffects-preset-selector # Throws error com.sth could not be found, dbus problem?
    gnomeExtensions.launch-new-instance
    gnomeExtensions.auto-activities

    # Gnome applications
    # gnome.gnome-session # Allow to start gnome from tty (sadly this is not usable, many things don't work)
    gnome.gnome-boxes # VM
    gnome.sushi # Gnome files previews
    gnome.gnome-logs # systemd log viewer
    gnome.gnome-tweaks # conflicts with nixos/hm gnome settings file sometimes, watch out what settings to change
    gnome.gnome-nettool
    gnome.simple-scan
    gnome.gnome-sound-recorder
    gnome.file-roller # archive manager
    # gnome-usage # Alternative system performance monitor (gnome.gnome-system-monitor is the preinstalled one)
    # gnome-secrets # Alternative keepass database viewer
    gnome-firmware

    # Ranger
    ranger
    ueberzug
    ffmpegthumbnailer
    atool
    p7zip
    zip
    unzip
    unrar
    libarchive
    exiftool
    mediainfo

    # Web
    signal-desktop
    yt-dlp
    # thunderbird # Try gnome mail
    protonmail-bridge
    protonvpn-cli

    # Tools
    # calibre
    # virt-manager # Let's try gnome-boxes while we're at it
    gource # Visualize git commit log
    anki-bin # Use anki-bin as anki is some versions behind
    # libreoffice-fresh
    jabref # manage bibilography
    # wike # Wikipedia viewer

    # Media
    wacomtablet
    xournalpp
    # kdenlive
    # krita
    # blender
    # godot
    # obs-studio

    # Use NixCommunity binary cache
    cachix
  ];

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    bat = { enable = true; };

    # Exclusive with nix-index
    # command-not-found.enable = true;

    # chromium.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    exa.enable = true;

    # feh.enable = true; # Use gnome apps for now

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
      userEmail = "christoph.urlacher@protonmail.com";
      userName = "ChUrl";
    };

    keychain = {
      enable = true;
      enableFishIntegration = true;
      enableXsessionIntegration = true;
      agents = [ "ssh" ];
      keys = [ "id_ed25519" ];
    };

    # Gnome apps for now
    # mpv = {
    #   enable = true;
    #   scripts = with pkgs; [
    #     mpvScripts.mpris  # Make controllable with media keys
    #   ];
    # };

    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    ssh.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # TODO: TexLive

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  # services = {
  #   # lorri.enable = true; # Use nix-direnv instead

  #   nextcloud-client = {
  #     enable = true;
  #     startInBackground = true;
  #   };
  # };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
