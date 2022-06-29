# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.
  ];

  # Comment out if you wish to disable Unfree packages for your system
  nixpkgs.config.allowUnfree = true;
  # https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-gtk libsForQt5.fcitx5-qt fcitx5-chinese-addons fctix5-configtool ]

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    bat = {
      enable = true;
    };

    command-not-found.enable = true;

    direnv = {
      enable = true;
      # enableFishIntegration = true; # Deprecated
      nix-direnv.enable = true;
    };

    exa.enable = true;

    feh.enable = true;

    # TODO: Copy config from Arch dots
    fish = {
      enable = true;
    };

    firefox = {
      enable = true;
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
    emacs.emacsPgtkNativeComp
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
    discord
    yt-dlp
    spotify
    thunderbird
    protonmail-bridge
    protonvpn-cli

    # Tools
    # calibre
    virt-manager
    gource
    keepassxc
    ark
    anki
    libreoffice-fresh
    libsForQt5.dolphin-plugins
    libsForQt5.kdegraphics-thumbnailers

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
    # TODO: Make a module
    victor-mono
    source-code-pro
    source-sans-pro
    source-serif-pro
    jetbrains-mono
    etBook
    overpass
    # Chinese Fonts
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
    nur.gamescope
    steam
    polymc
    lutris
  ];

  services = {
    lorri.enable = true;

    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
