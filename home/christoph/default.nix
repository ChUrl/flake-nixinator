# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{
  hostname,
  username,
  lib,
  mylib,
  config,
  nixosConfig,
  pkgs,
  ...
}:
# This is a module
# Because no imports/options/config is defined explicitly, everything is treated as config
# { inputs, lib, ... }: { ... } gets turned into { inputs, lib, ... }: { config = { ... }; } implicitly
# TODO: Add nixified.ai module
rec {
  # Every module is a nix expression, specifically a function { inputs, lib, ... }: { ... }
  # Every module (/function) is called with the same arguments as this module (home.nix)
  # Arguments with matching names are "plugged in" into the right slots,
  # the case of different arity is handled by always providing ellipses (...) in module definitions
  imports = [
    # Import the host-specific user-config
    ./${hostname}

    ../modules

    # inputs.nixvim.homeManagerModules.nixvim
    # inputs.hyprland.homeManagerModules.default
  ];

  modules = {
    chromium = {
      enable = true;
      google = false;
    };

    # emacs = {
    #   enable = false;
    #   pgtkNativeComp = false;
    #   nativeComp = false;
    #   nixpkgs = true;

    #   doom.enable = true;
    #   doom.autoSync = true;
    #   doom.autoUpgrade = false; # Very volatile as the upgrade fails sometimes with bleeding edge emacs
    # };

    # TODO: Only sync protonmail using its bridge
    email = {
      enable = false;
      autosync = true;
      imapnotify = false;

      # Use kmail as viewer for stuff synced by mbsync
      kmail = {
        enable = false;
        autostart = true;
      };
    };

    firefox = {
      enable = true;
      wayland = true;
      vaapi = true; # NOTE: Crashes AMDGPU driver fairly often (don't know why exactly)
      disableTabBar = true;
      defaultBookmarks = true;
      gnomeTheme = true;
    };

    fish.enable = true;

    # flatpak = {
    #   enable = false;
    #   autoUpdate = true;
    #   autoPrune = true;
    #   fontFix = true; # TODO: This doesn't work reliably...
    #   iconFix = false;

    #   flatseal.enable = true;
    #   discord.enable = true;
    #   spotify.enable = true;
    #   bottles.enable = false;
    #   obsidian.enable = false; # Extremely low graph draw performance?
    #   jabref.enable = false;
    # };

    helix.enable = false;

    hyprland = {
      enable = true;
      # theme = "Three-Bears";
      theme = "Foggy-Lake";

      keybindings = {
        main-mod = "SUPER";

        bindings = {
          "$mainMod, T" = ["exec, kitty"];
          "$mainMod, E" = ["exec, kitty"];
          "$mainMod, N" = ["exec, neovide"];
          # "$mainMod, T" = ["exec, alacritty -o font.size=12 -e tmux"];
          # "$mainMod, E" = ["exec, alacritty -o font.size=12 -e tmux"];

          "$mainMod, P" = ["exec, hyprpicker -a"];
          "$mainMod, S" = ["exec, grim -g \"$(slurp)\""];
          "$mainMod CTRL, S" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];

          ", XF86AudioRaiseVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
          ", XF86AudioLowerVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"];
        };
      };

      autostart = {
        # immediate = [];

        delayed = [
          # "kdeconnect-indicator"
          "kitty"
          "nextcloud --background"
          "keepassxc"
        ];
      };

      workspacerules = {
        "2" = [
          "neovide"
          "jetbrains-clion"
          "jetbrains-idea"
          "jetbrains-pycharm"
          "jetbrains-rustrover"
          "jetbrains-rider"
          "code-url-handler"
        ];
        "3" = [
          "obsidian"
          "unityhub"
          "Unity"
          "chromium-browser"
        ];
        "4" = [
          "firefox"
          "Google-chrome"
        ];
        "7" = [
          "signal"
        ];
        "8" = [
          "Spotify"
        ];
        "9" = [
          "discord"
          "vesktop"
        ];
      };

      floating = [
        {
          class = "org.kde.polkit-kde-authentication-agent-1";
        }
        {
          class = "thunar";
          title = "File Operation Progress";
        }
      ];

      transparent = [
        "kitty"
        "Alacritty"
        "discord"
        "signal"
        "vesktop"
        "Spotify"
        "obsidian"
        "jetbrains-clion"
        "jetbrains-idea"
        "jetbrains-pycharm"
        "jetbrains-rustrover"
        "jetbrains-rider"
        "code-url-handler"
        "neovide"
      ];
    };

    kitty.enable = true;

    neovim = {
      enable = true;
      alias = true;
      neovide = true;
    };

    nnn.enable = true;

    # ranger = {
    #   enable = false;
    #   preview = true;
    # };

    rofi = {
      enable = true;
      # theme = "Three-Bears";
      theme = "Foggy-Lake";
    };

    vscode.enable = true;

    waybar = {
      enable = true;
    };
  };

  manual = {
    manpages.enable = true;
    html.enable = false;
  };

  # Make fonts installed through user packages available to applications
  # NOTE: I don't think I need this anymore as all fonts are installed through the system config but let's keep this just in case
  fonts.fontconfig.enable = true; # Also updates the font-cache

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      associations.added = nixosConfig.xdg.mime.addedAssociations;
      associations.removed = nixosConfig.xdg.mime.removedAssociations;
      inherit (nixosConfig.xdg.mime) defaultApplications; # Equal to "defaultApplications = nixosConfig.xdg.mime.defaultApplications"
    };
  };

  home = {
    inherit username; # Inherited from flake.nix

    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      LANG = "en_US.UTF-8";

      # TERMINAL = "alacritty -o font.size=12";
      TERMINAL = "kitty";
      BROWSER = "firefox";

      DOCKER_BUILDKIT = 1;

      # Enable wayland
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";

      # Don't use system wine, use bottles
      # WINEESYNC = 1;
      # WINEFSYNC = 1;
      # WINEPREFIX = "/home/christoph/.wine";

      # GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    file = {
      # Generate a list of installed user packages in ~/.local/share/current-user-packages
      ".local/share/current-user-packages".text = let
        packages = builtins.map (p: "${p.name}") home.packages;
        sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
        formatted;

      ".config/mpv" = {
        recursive = true;
        source = ../../config/mpv;
      };

      # TODO: Latex module
      "texmf/tex/latex/custom/christex.sty".source = ../../config/latex/christex.sty;
      "Notes/Obsidian/Chriphost/christex.sty".source = ../../config/latex/christex.sty; # For obsidian notes
      ".indentconfig.yaml".source = ../../config/latex/.indentconfig.yaml;
      ".indentsettings.yaml".source = ../../config/latex/.indentsettings.yaml;
      # TODO: Use mkLink
      # "Notes/Obsidian/Chriphost/latex_snippets.json".source = ../../config/obsidian/latex_snippets.json;
      "Notes/Obsidian/Chriphost/.obsidian/snippets/latex_preview.css".source = ../../config/obsidian/css_snippets/latex_preview.css;

      # TODO: If navi enabled
      # TODO: Symlink this, so the config doesn't have to be rebuilt every time
      ".local/share/navi/cheats/christoph.cheat".source = ../../config/navi/christoph.cheat;
    };

    activation = {
      linkObsidianLatexSnippets =
        lib.hm.dag.entryAfter ["writeBoundary"]
        (mylib.modules.mkLink "~/NixFlake/config/obsidian/latex_snippets.json" "~/Notes/Obsidian/Chriphost/latex_snippets.json");
    };

    # TODO: Make a module for standard UNIX replacements
    # Add stuff for your user as you see fit:
    packages = with pkgs; [
      # Shell utils
      (ripgrep.override {withPCRE2 = true;}) # fast as fuck
      gdu # Alternative to du-dust (I like it better)
      duf # Disk usage analyzer (for all disk overview)
      sd # sed alternative
      fclones # duplicate file finder
      tealdeer # very fast tldr (so readable man)
      atool # Archive preview
      ffmpegthumbnailer # Video thumbnails
      mediainfo
      tree # Folder preview
      unrar
      p7zip
      unzip
      progress
      tokei # Text file statistics in a project
      appimage-run
      nvd # nix rebuild diff
      file
      # spotdl # TODO: Borked

      # Hardware/Software info
      pciutils # lspci
      glxinfo # opengl info
      wayland-utils # wayland-info
      aha # ansi html adapter? TODO: Why did I install this?
      clinfo # OpenCL info
      vulkan-tools # vulkaninfo
      libva-utils # vainfo
      vdpauinfo
      hwloc
      lm_sensors
      acpica-tools # Dump ACPI tables etc.

      # Video/Image utils
      ffmpeg_5-full # I love ffmpeg (v5, including ffplay)
      ffmpeg-normalize
      imagemagick # Convert image (magic)
      ueberzugpp # Display images in terminal (alacritty)

      # Document utils
      # TODO: Latex module with individual packages or HomeManager
      texlive.combined.scheme-full
      poppler_utils # pdfunite
      graphviz # generate graphs from code
      plantuml
      gnuplot # generate function plots
      pdf2svg
      pandoc # document converting madness
      inkscape # for latex

      # Networking
      dig
      tcpdump
      traceroute
      wireshark
      gping # ping with graph
      curlie # curl a'la httpie
      wget # download that shit
      dogdns # dns client
      rsync # cp on steroids
      rclone # Rsync for cloud
      httpie # Cool http client
      # suricata
      cifs-utils # Mount samba shares
      nfs-utils
      sshfs
      protonvpn-cli
      # protonvpn-gui # NOTE: Doesn't work

      # GUI apps
      vlc
      cool-retro-term
      ventoy-full # Bootable USB for many ISOs
      sqlitebrowser # To modify tables
      dbeaver-bin # To import/export data + diagrams
      hoppscotch # Test APIs
      # decker # TODO: Build failure
      signal-desktop
      filezilla
      anki
      # octave # GNU matlab basically
      font-manager
      nextcloud-client
      keepassxc
      protonmail-bridge
      thunderbird # TODO: Email module
      # xwaylandvideobridge # NOTE: Doesn't work

      # Office
      wacomtablet # For xournalpp/krita
      xournalpp # Write with a pen, like old people
      # libreoffice-qt
      hunspell # I cna't type
      hunspellDicts.en_US
      hunspellDicts.de_DE
      # obsidian # knowledge-base # NOTE: Use flatpak
      # logseq # knowledge-base

      # TODO: Module, I need to add python packages from multiple modules to the same interpreter
      python312

      AusweisApp2

      # Games
      # NOTE: Does not run with wayland
      # (retroarch.override {
      #   cores = with libretro; [
      #     desmume
      #     melonds
      #   ];
      # })
      # melonDS # NOTE: Doesn't work - No QT platform plugin for wayland
      desmume

      # Use NixCommunity binary cache
      cachix

      # Generate documentation
      # modules-options-doc
    ];

    # Do not change
    stateVersion = "22.05";
  };

  # home.file.".options-doc".source = "${pkgs.modules-options-doc}";

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    alacritty = {
      enable = false;

      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };

          font = {
            normal = "JetBrainsMono Nerd Font Mono";
            size = 12;
          };
        };

        env = {
          TERM = "xterm-256color";
        };

        colors = {
          # Default colors
          primary = {
            background = "#EFF1F5"; # base
            foreground = "#4C4F69"; # text
            # Bright and dim foreground colors
            dim_foreground = "#4C4F69"; # text
            bright_foreground = "#4C4F69"; # text
          };

          # Cursor colors
          cursor = {
            text = "#EFF1F5"; # base
            cursor = "#DC8A78"; # rosewater
          };
          vi_mode_cursor = {
            text = "#EFF1F5"; # base
            cursor = "#7287FD"; # lavender
          };

          # Search colors
          search = {
            matches = {
              foreground = "#EFF1F5"; # base
              background = "#6C6F85"; # subtext0
            };
            focused_match = {
              foreground = "#EFF1F5"; # base
              background = "#40A02B"; # green
            };
            footer_bar = {
              foreground = "#EFF1F5"; # base
              background = "#6C6F85"; # subtext0
            };
          };

          # Keyboard regex hints
          hints = {
            start = {
              foreground = "#EFF1F5"; # base
              background = "#DF8E1D"; # yellow
            };
            end = {
              foreground = "#EFF1F5"; # base
              background = "#6C6F85"; # subtext0
            };
          };

          # Selection colors
          selection = {
            text = "#EFF1F5"; # base
            background = "#DC8A78"; # rosewater
          };

          # Normal colors
          normal = {
            black = "#5C5F77"; # subtext1
            red = "#D20F39"; # red
            green = "#40A02B"; # green
            yellow = "#DF8E1D"; # yellow
            blue = "#1E66F5"; # blue
            magenta = "#EA76CB"; # pink
            cyan = "#179299"; # teal
            white = "#ACB0BE"; # surface2
          };

          # Bright colors
          bright = {
            black = "#6C6F85"; # subtext0
            red = "#D20F39"; # red
            green = "#40A02B"; # green
            yellow = "#DF8E1D"; # yellow
            blue = "#1E66F5"; # blue
            magenta = "#EA76CB"; # pink
            cyan = "#179299"; # teal
            white = "#BCC0CC"; # surface1
          };

          # Dim colors
          dim = {
            black = "#5C5F77"; # subtext1
            red = "#D20F39"; # red
            green = "#40A02B"; # green
            yellow = "#DF8E1D"; # yellow
            blue = "#1E66F5"; # blue
            magenta = "#EA76CB"; # pink
            cyan = "#179299"; # teal
            white = "#ACB0BE"; # surface2
          };

          indexed_colors = [
            {
              index = 16;
              color = "#FE640B";
            }
            {
              index = 17;
              color = "#DC8A78";
            }
          ];
        };
      };
    };

    bat = {
      enable = true;

      themes = {
        catppuccin-latte = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-latte.tmTheme";
        };
      };

      config = {
        theme = "catppuccin-latte";
      };
    };

    btop.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    eza = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    fastfetch = {
      enable = true;
    };

    fd = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    gallery-dl.enable = false; # TODO: Alternative to cyberdrop-dl?

    git = {
      enable = true;
      lfs.enable = true;
      delta.enable = true;

      userEmail = "christoph.urlacher@protonmail.com";
      userName = "Christoph Urlacher";
    };

    keychain = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      enableNushellIntegration = false;
      enableXsessionIntegration = true;
      agents = ["ssh"];
      keys = ["id_ed25519"];
    };

    lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = false;
          activeBorderColor = ["#40a02b" "bold"];
          inactiveBorderColor = ["#4c4f69"];
          optionsTextColor = ["#1e66f5"];
          selectedLineBgColor = ["#ccd0da"];
          selectedRangeBgColor = ["#ccd0da"];
          cherryPickedCommitBgColor = ["#179299"];
          cherryPickedCommitFgColor = ["#1e66f5"];
          unstagedChangeColor = ["red"];
        };
      };
    };

    # Realtime Motion Interpolation: https://gist.github.com/phiresky/4bfcfbbd05b3c2ed8645
    mpv = {
      enable = true;
      # NOTE: wrapMpv explained here: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/video/mpv/wrapper.nix#L84
      #       wrapMpv gets two args: the mpv derivation and some options
      #       Possible overrides for derivation: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/video/mpv/default.nix#L222
      package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override {vapoursynthSupport = true;}) {
        youtubeSupport = true;
        extraMakeWrapperArgs = [
          "--prefix"
          "LD_LIBRARY_PATH"
          ":"
          "${pkgs.vapoursynth-mvtools}/lib"
        ];
      };
    };

    # Interactive Cheatsheets
    navi = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable; # Type something "remove first line" and hit Ctrl-G to launch navi on that prompt
    };

    nix-index = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    nushell = {
      enable = false;
    };

    # Git status replacement with file selection by number
    scmpuff = {
      enable = false;
      enableFishIntegration = true;
    };

    # Scientific pdf reader
    sioyek = {
      enable = false; # Disabled for now, as it crashes sometimes?
      # bindings = {};
      # config = {};
    };

    ssh.enable = true;

    starship = let
      flavour = "latte"; # One of `latte`, `frappe`, `macchiato`, or `mocha`
    in {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      settings =
        {
          # Other config here
          format = "$all"; # Remove this line to disable the default prompt format
          palette = "catppuccin_${flavour}";
        }
        // builtins.fromTOML (builtins.readFile
          (pkgs.fetchFromGitHub
            {
              owner = "catppuccin";
              repo = "starship";
              rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc";
              sha256 = "sha256-soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
            }
            + /palettes/${flavour}.toml));
    };

    tmux = {
      enable = true;

      clock24 = true;
      escapeTime = 0; # Delay after pressing escape
      # keyMode = "vi";
      terminal = "xterm-256color";

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @plugin 'catppuccin/tmux'
            set -g @catppuccin_flavour 'latte' # or frappe, macchiato, mocha
          '';
        }
      ];

      extraConfig = ''
        set -g default-terminal "xterm-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"
      '';
    };

    # TODO: Check HM module options
    yt-dlp.enable = true;

    zathura = {
      enable = true;

      options = {
        # Catppuccin Latte
        default-fg = "#4C4F69";
        default-bg = "#EFF1F5";

        completion-bg = "#CCD0DA";
        completion-fg = "#4C4F69";
        completion-highlight-bg = "#575268";
        completion-highlight-fg = "#4C4F69";
        completion-group-bg = "#CCD0DA";
        completion-group-fg = "#1E66F5";

        statusbar-fg = "#4C4F69";
        statusbar-bg = "#CCD0DA";

        notification-bg = "#CCD0DA";
        notification-fg = "#4C4F69";
        notification-error-bg = "#CCD0DA";
        notification-error-fg = "#D20F39";
        notification-warning-bg = "#CCD0DA";
        notification-warning-fg = "#FAE3B0";

        inputbar-fg = "#4C4F69";
        inputbar-bg = "#CCD0DA";

        recolor-lightcolor = "#EFF1F5";
        recolor-darkcolor = "#4C4F69";

        index-fg = "#4C4F69";
        index-bg = "#EFF1F5";
        index-active-fg = "#4C4F69";
        index-active-bg = "#CCD0DA";

        render-loading-bg = "#EFF1F5";
        render-loading-fg = "#4C4F69";

        highlight-color = "#575268";
        highlight-fg = "#EA76CB";
        highlight-active-color = "#EA76CB";
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };
  };

  services = {
    # kdeconnect.enable = true; # Note: This does not setup the firewall at all

    flatpak = {
      packages = [
        "com.github.tchx84.Flatseal"
        "com.discordapp.Discord"
        "com.spotify.Client"
        "com.google.Chrome"
        "md.obsidian.Obsidian"
        "dev.vencord.Vesktop"
      ];

      uninstallUnmanaged = true;

      update.auto = {
        enable = true;
        onCalendar = "daily"; # Default value: weekly
      };

      overrides = {
        global = {
          # Force Wayland by default
          # Context.sockets = ["wayland" "!x11" "!fallback-x11"]; # NOTE: Makes discord crash

          Context.filesystems = ["/nix/store:ro"];

          Environment = {
            # Fix un-themed cursor in some Wayland apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # Force correct theme for some GTK apps
            GTK_THEME = "Adwaita:light";
          };
        };
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
