# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{ inputs, hostname, username, lib, mylib, config, nixosConfig, pkgs, ... }:

# This is a module
# Because no imports/options/config is defined explicitly, everything is treated as config
# { inputs, lib, ... }: { ... } gets turned into { inputs, lib, ... }: { config = { ... }; } implicitly
let

in rec {

  # Every module is a nix expression, specifically a function { inputs, lib, ... }: { ... }
  # Every module (/function) is called with the same arguments as this module (home.nix)
  # Arguments with matching names are "plugged in" into the right slots,
  # the case of different arity is handled by always providing ellipses (...) in module definitions
  imports = [
    # Import the host-specific user-config
    ./${hostname}

    ../modules

    # inputs.nixvim.homeManagerModules.nixvim
  ];

  modules = {
    # Config my modules
    emacs = {
      enable = true;
      pgtkNativeComp = false;
      nativeComp = false;
      nixpkgs = true;

      doom.enable = true;
      doom.autoSync = true;
      doom.autoUpgrade = false; # Very volatile as the upgrade fails sometimes with bleeding edge emacs
    };

    firefox = {
      enable = true;
      wayland = true;
      vaapi = true;
      disableTabBar = true;
      defaultBookmarks = true;
      gnomeTheme = true; # I like it also with Plasma
    };

    fish.enable = true;

    flatpak = {
      enable = true;
      autoUpdate = true;
      autoPrune = true;

      flatseal.enable = true;
      discord.enable = false;
      spotify.enable = true;
      bottles.enable = true;
    };

    gnome = {
      enable = false;
      extensions = true;

      theme = {
        papirusIcons = true;
        numixCursor = true;
      };

      settings = {
      };
    };

    kitty.enable = true;

    misc = {
      enable = true;

      keepass = {
        enable = true;
        autostart = true;
      };

      protonmail = {
        enable = true;
        autostart = true;
      };
    };

    neovim = {
      enable = true;
      alias = true;
    };

    nextcloud = {
      enable = true;
      autostart = true;
    };

    ranger = {
      enable = true;
      preview = true;
    };
  };

  # TODO: Gnome terminal config
  # TODO: Store the external binaries for my derivations in GitHub LFS (Vital, NeuralDSP, other plugins etc.)
  # TODO: Derivations for bottles like UPlay, NeuralDSP, LoL (don't know what is possible with bottles-cli though)
  # TODO: When bottles derivations are there remove the bottles option from audio/gaming module and assert that bottles is enabled in flatpak module

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
  fonts.fontconfig.enable = false; # Also updates the font-cache

  # Generate a list of installed user packages in ~/.local/share/current-user-packages
  home.file.".local/share/current-user-packages".text = let
    packages = builtins.map (p: "${p.name}") home.packages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  home = {
    username = username; # Inherited from flake.nix
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      LANG = "en_US.UTF-8";

      DOCKER_BUILDKIT = 1;

      # Enable wayland
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";

      # Don't use system wine, use bottles
      # WINEESYNC = 1;
      # WINEFSYNC = 1;
      # WINEPREFIX = "/home/christoph/.wine";

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # Do not change
    stateVersion = "22.05";
  };

  # TODO: Check what packages are installed here and in modules and check if there is already a service/hm-module for it
  # TODO: If so use this or adapt the config from there (example gnome.sushi is also added to dbus packages in services.sushi)
  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CLI Tools
    procs
    tokei
    rsync
    rclone
    xclip
    xorg.xwininfo
    xdotool
    poppler_utils # pdfunite
    ffmpeg
    imagemagick
    httpie
    ripgrep
    nvd # nix rebuild diff
    du-dust
    neofetch # Easily see interesting package versions/kernel
    lazygit
    yt-dlp
    pciutils
    glxinfo
    wayland-utils
    aha
    radeontop

    signal-desktop
    protonvpn-cli
    cyberdrop-dl
    filezilla

    # Tools
    # calibre
    # virt-manager # Let's try gnome-boxes while we're at it
    gource # Visualize git commit log
    anki-bin # Use anki-bin as anki is some versions behind
    # libreoffice-fresh
    jabref # manage bibilography
    inputs.nixos-conf-editor.packages."x86_64-linux".nixos-conf-editor
    octave

    # TODO: LaTeX module
    texlab

    # Media
    wacomtablet
    xournalpp
    # davinci-resolve # Large and slow and overpowered for my purposes
    blender
    godot
    obs-studio
    vlc
    kdenlive
    krita

    # KDE Applications
    # TODO: Make a module out of this
    libsForQt5.kate
    # libsForQt5.kwrited # Already included by default
    libsForQt5.ark
    libsForQt5.kdeconnect-kde
    libsForQt5.kcalc
    libsForQt5.ksystemlog
    libsForQt5.kfind
    libsForQt5.discover
    libsForQt5.filelight # Drive file size stats
    libsForQt5.kcolorpicker
    libsForQt5.kgpg
    libsForQt5.kparts # Partition manager
    libsForQt5.kcharselect
    libsForQt5.kompare # Can't be used as git merge tool, but more integrated than kdiff3
    libsForQt5.skanlite
    libsForQt5.kmail
    libsForQt5.kalendar
    libsForQt5.plasma-browser-integration
    okteta
    kdiff3
    kgraphviewer
    kbibtex

    # Use NixCommunity binary cache
    cachix
  ];

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;
    bat.enable = true;
    exa.enable = true;
    # mpv.enable = true; # Doesn't work, only blackscreen?
    ssh.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      delta.enable = true;
      userEmail = "christoph.urlacher@protonmail.com";
      userName = "ChUrl";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
