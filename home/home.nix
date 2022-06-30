# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  # https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  nixpkgs.config.allowUnfree = true;

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-gtk libsForQt5.fcitx5-qt fcitx5-chinese-addons fcitx5-configtool ];

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    bat = {
      enable = true;
    };

    command-not-found.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # TODO: Move to emacs module
    emacs = {
      # TODO: This is wrong, I need to figure out the overlays
      # package = pkgs.emacsPgtkNativeComp;
      package = pkgs.emacs28NativeComp;
      enable = true;
    };

    exa.enable = true;

    feh.enable = true;

    # TODO: Copy config from Arch dots
    fish = {
      enable = true;
    };

    firefox = {
      enable = true;

      # TODO: Add extra config
      package = pkgs.firefox-wayland.override {
        # See nixpkgs' firefox/wrapper.nix to check which options you can use
        cfg = {
          # Gnome shell native connector
          enableGnomeExtensions = false; # I don't need this since I declare installed extensions inside HomeManager
        };
      };

      # TODO: Add extensions
      extensions = [];
    };

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

    # TODO: Copy config from Arch dots
    kitty = {
      enable = true;
    };

    mpv.enable = true;

    neovim = {
      enable = true;
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

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CLI Tools
    procs
    tokei
    rsync
    xclip
    poppler_utils
    ffmpeg
    imagemagick
    htop
    httpie
    rclone

    # TODO: Moooore
    # Gnome extensions
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.vitals
    gnomeExtensions.no-overview
    gnomeExtensions.switch-workspace
    gnomeExtensions.maximize-to-empty-workspace
    gnomeExtensions.pip-on-top

    # Ranger
    # TODO: Make module out of this
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

    # Doom Emacs
    # TODO: Make module out of this
    binutils
    zstd
    ripgrep
    fd
    gcc
    libgccjit
    gnumake
    cmake
    sqlite
    python310Packages.pygments
    inkscape
    graphviz
    gnuplot
    pandoc
    nixfmt
    shellcheck
    maim
    xorg.xwininfo
    xdotool

    # Web
    signal-desktop
    noisetorch
    # Flatpak discord
    yt-dlp
    # Flatpak spotify
    thunderbird
    protonmail-bridge
    protonvpn-cli

    # Tools
    # calibre
    # virt-manager # Let's try gnome-boxes while we're at it
    gnome.gnome-boxes
    gource
    keepassxc
    # ark # This is KDE tool
    anki
    libreoffice-fresh
    # libsForQt5.dolphin-plugins
    # libsForQt5.kdegraphics-thumbnailers

    # Graphics
    wacomtablet
    xournalpp
    # kdenlive
    # krita
    # blender
    # godot

    # Icons
    papirus-icon-theme

    # Fonts
    # TODO: Make a module and move to fonts.fonts or something more specific
    victor-mono
    source-code-pro
    source-sans-pro
    source-serif-pro
    jetbrains-mono
    etBook
    overpass
    source-han-mono
    source-han-sans
    source-han-serif
    wqy_zenhei
    wqy_microhei

    # Audio
    # TODO: Make a module
    # vcv-rack
    # bitwig-studio
    # audacity
    # carla
    # TODO: Make wine-tgk derivation
    # yabridge
    # yabridgectl # TODO: Do I need both?

    # Use NixCommunity binary cache
    cachix

    # Gaming
    gamemode
    # TODO: This is wrong, I need to figure out nur when I try out gamescope
    # pkgs.repos.dukzcry.gamescope
    # Flatpak bottles
    # Flatpak steam
    polymc # TODO: Should I use Flatpak for all gaming stuff?
    # lutris # I don't want that crap, pleaaaase
  ];

  services = {
    # lorri.enable = true; # Use nix-direnv instead

    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
