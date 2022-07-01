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

  # TODO: Gtk
  # TODO: Email
  # TODO: Run noisetorch as login script

  # Disabled since HomeManager should use global pkgs
  # https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfreePredicate = (pkg: true);
  # nixpkgs.config.allowUnfree = true;

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-gtk
    libsForQt5.fcitx5-qt
    fcitx5-chinese-addons
    fcitx5-configtool
  ];

  # Make fonts installed through packages available to applications
  fonts.fontconfig.enable = true;

  home = {
    username = "christoph";
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MOZ_ENABLE_WAYLAND = 1;
      XDG_DATA_DIRS =
        "/var/lib/flatpak/exports/share:/home/christoph/.local/share/flatpak/exports/share:$XDG_DATA_DIRS";
      DOCKER_BUILDKIT = 1;
      LANG = "en_US.UTF-8";
      WINEESYNC = 1;
      WINEFSYNC = 1;
      WINEPREFIX = "/home/christoph/.wine";

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module

      # TODO: Investigate if this also slows down Gnome login
      # GTK_USE_PORTAL = 1;

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
    (pkgs.nerdfonts.override { fonts = [ "VictorMono" ]; })

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

    bat = { enable = true; };

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
      # functions = {};
      # plugins = [];
      shellAbbrs = {
        c = "clear";
        q = "exit";
        h = "history | bat";

        failed = "systemctl --failed";
        errors = "journalctl -p 3 -xb";

        cd = "z";
        cp = "cp -i";
        ls =
          "exa --color always --group-directories-first -F --git --icons"; # color-ls
        lsl =
          "exa --color always --group-directories-first -F -l --git --icons";
        lsa =
          "exa --color always --group-directories-first -F -l -a --git --icons";
        tre =
          "exa --color always --group-directories-first -F -T -L 2 ---icons";
        mkd = "mkdir -p";
        blk =
          "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL | bat";
        fsm = "df -h | bat";
        grp = "grep --color=auto -E";
        fzp =
          "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        fre = "free -m";

        r =
          "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";
        rsync = "rsync -chavzP --info=progress2";
        performance =
          "sudo cpupower frequency-set -g performance && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1";
        powersave =
          "sudo cpupower frequency-set -g powersave && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=0";

        wat = "watch -d -c -n -0.5";
        dus = "sudo dust -r";
        dsi = "sudo du -sch . | bat";
        prc = "procs -t";

        emcs = "emacs -nw";

        gs = "git status";
        gcm = "git commit -m";
        ga = "git add";
        glg = "git log --graph --decorate --oneline";
        gcl = "git clone";

        xxhamster = "TERM=ansi ssh christoph@217.160.142.51";

        fonts = "fc-list";
        fchar = "fc-match -s";

        vpnat = "protonvpn-cli c --cc at";
        vpnch = "protonvpn-cli c --cc ch";
        vpnlu = "protonvpn-cli c --cc lu";
        vpnus = "protonvpn-cli c --cc us";
        vpnhk = "protonvpn-cli c --cc hk";
        vpnkr = "protonvpn-cli c --cc kr";
        vpnoff = "protonvpn-cli d";

        league = "sudo sysctl -w abi.vsyscall32=0";

        mp4 =
          "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
        mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";
      };
      shellAliases = {
        # ".." = "cd ..";
        "please" = "sudo !!";
        "yeet" = "rm -rf";
      };
      shellInit = ''
        set -e fish_greeting
      '';
      # promptInit = ''
      #   any-nix-shell fish --info-right | source
      # '';
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
          ExtensionSettings = { };

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
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-origin ];

      # TODO:
      profiles = {
        default = {
          id = 0;

          # TODO:
          settings = {
            "app.update.auto" = false;
            # "browser.startup.homepage" = "https://lobste.rs";
            "identity.fxaccounts.account.device.name" =
              nixosConfig.networking.hostName; # NOTE: nixosConfig attribute is somehow not documented, so Idk if I should use it
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
      font = { name = "Victor Mono SemiBold"; };
      settings = {
        font_size = 12;
        scrollback_lines = 10000;
        window_padding_width = 10;

        # Light Theme
        # background = "#f7f7f7";
        # foreground = "#494542";
        # selection_background = "#a4a1a1";
        # selection_foreground = "#f7f7f7";
        # cursor = "#494542";
        # color0 = "#090200";
        # color1 = "#da2c20";
        # color2 = "#00a152";
        # color3 = "#ffcc00";
        # color4 = "#00a0e4";
        # color5 = "#a06994";
        # color6 = "#0077d9";
        # color7 = "#a4a1a1";
        # color8 = "#5b5754";
        # color9 = "#e8bacf";
        # color10 = "#3a3332";
        # color11 = "#494542";
        # color12 = "#7f7c7b";
        # color13 = "#d6d4d3";
        # color14 = "#ccab53";
        # color15 = "#d2b3ff";
      };
      keybindings = {
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
      };
    };

    # mpv.enable = true; # Use gnome apps for now

    neovim = {
      enable = true;
      extraConfig = ''
        set incsearch
        set hlsearch
        set ignorecase
        set autoindent
        set expandtab
        set smartindent
        set smarttab
        set shiftwidth=4
        set softtabstop=4
        set backspace=indent,eol,start
        set ruler
        set number
        set laststatus=2
        set noshowmode
        set undofile
        set undodir=~/.vim/undo
        set hidden
        set printfont=Victor\ Mono\ SemiBold:h10
        set guifont=Victor\ Mono\ SemiBold:h12
        let printencoding='utf-8'
        set encoding=utf-8
      '';
      plugins = with pkgs.vimPlugins; [ vim-nix lightline-vim ];
      viAlias = true;
      vimAlias = true;
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
