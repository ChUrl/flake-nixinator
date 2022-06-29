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
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CLI Tools
    # HM exa
    procs
    tokei
    rsync
    xclip
    poppler_utils
    ffmpeg
    imagemagick

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
    pandoc
    nixfmt
    shellcheck
    maim
    xorg.xwininfo
    xdotool

    # Web
    discord
    yt-dlp
    spotify

    # Tools
    keepassxc
    ark
    anki
    libsForQt5.dolphin-plugins
    libsForQt5.kdegraphics-thumbnailers

    # Graphics
    wacomtablet
    xournalpp
    # kdenlive
    # krita
    # blender
    # godot
    papirus-icon-theme

    # Use NixCommunity binary cache
    cachix

    # Gaming
    steam
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
