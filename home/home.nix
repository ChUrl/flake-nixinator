# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, nixosConfig, pkgs, ... }:

rec {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.

    ./modules/emacs.nix
  ];

  # Config my modules
  modules = {
    emacs.enable = true;
    emacs.useDoom = true;
  };

  # TODO: Fonts
  # TODO: Gtk
  # TODO: Email

  # Disabled since HomeManager should use global pkgs
  # https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfreePredicate = (pkg: true);
  # nixpkgs.config.allowUnfree = true;

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-gtk libsForQt5.fcitx5-qt fcitx5-chinese-addons fcitx5-configtool ];

  # Make fonts installed through packages available to applications
  fonts.fontconfig.enable = true;

  home = {
    username = "christoph";
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      EDITOR = "nvim";
    };

    stateVersion = "22.05";
  };

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
    # htop
    httpie

    # Gnome extensions
    # TODO: Make a gnome module
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.vitals
    gnomeExtensions.no-overview
    gnomeExtensions.switch-workspace
    gnomeExtensions.maximize-to-empty-workspace
    gnomeExtensions.pip-on-top
    gnomeExtensions.custom-hot-corners-extended
    gnomeExtensions.dock-from-dash

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

    # Doom Emacs (contained in Module)
    # binutils
    # zstd
    # ripgrep
    # fd
    # gcc
    # libgccjit
    # gnumake
    # cmake
    # sqlite
    # python310Packages.pygments
    # inkscape
    # graphviz
    # gnuplot
    # pandoc
    # nixfmt
    # shellcheck
    # maim

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
    # Flatpak nur.repos.dukzcry.gamescope # We need to install this with flatpak to be able to use with bottles
    # Flatpak bottles
    # Flatpak steam
    polymc # TODO: Should I use Flatpak for all gaming stuff?
    # lutris # I don't want to, pleeeease
  ];

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

    # Contained in Module
    # emacs = {
    #   package = pkgs.emacsPgtkNativeComp; # NOTE: I have no idea why not pkgs.emacs.emacsPgtkNativeComp...
    #   # package = pkgs.emacs28NativeComp;
    #   enable = true;
    # };

    exa.enable = true;

    # feh.enable = true; # Use gnome apps for now

    # TODO: Copy config from Arch dots
    fish = {
      enable = true;
    };

    firefox = {
      enable = true;

      # firefox-unwrapped is the pure firefox browser, wrapFirefox adds configuration ontop
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {

        forceWayland = true;

        # About policies:
        # https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
        extraPolicies = {
	  # TODO: Investigate this
          ExtensionSettings = {};

	  CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
      };

      # TODO:
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
	ublock-origin
      ];

      # TODO:
      profiles = {
        default = {
	  id = 0;

          # TODO:
          settings = {
	    "app.update.auto" = false;
            # "browser.startup.homepage" = "https://lobste.rs";
            "identity.fxaccounts.account.device.name" = nixosConfig.networking.hostName; # NOTE: nixosConfig attribute is somehow not documented, so Idk if I should use it
            "signon.rememberSignons" = false;
            # "browser.urlbar.placeholderName" = "DuckDuckGo";
            # "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          # userChrome = builtins.readFile ../conf.d/userChrome.css;
	};
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # TODO: This is also enabled as system module, what exactly happens now?
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

    # mpv.enable = true; # Use gnome apps for now

    neovim = {
      enable = true;
    };

    # TODO: openssh is also enabled as system module
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
