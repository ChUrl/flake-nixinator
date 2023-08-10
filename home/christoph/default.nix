# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{
  inputs,
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
    chromium.enable = true;

    # emacs = {
    #   enable = false;
    #   pgtkNativeComp = false;
    #   nativeComp = false;
    #   nixpkgs = true;

    #   doom.enable = true;
    #   doom.autoSync = true;
    #   doom.autoUpgrade = false; # Very volatile as the upgrade fails sometimes with bleeding edge emacs
    # };

    email = {
      enable = true;
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
      vaapi = false; # NOTE: Crashes AMDGPU driver fairly often (don't know why exactly)
      disableTabBar = true;
      defaultBookmarks = true;
      gnomeTheme = true;
    };

    fish.enable = true;

    flatpak = {
      enable = true;
      autoUpdate = true;
      autoPrune = true;
      fontFix = true; # TODO: This doesn't work reliably...
      iconFix = false;

      flatseal.enable = true;
      discord.enable = true;
      spotify.enable = false; # Can't login because browser doesn't open
      bottles.enable = false;
      obsidian.enable = false; # Extremely low graph draw performance?
      jabref.enable = false;
    };

    helix.enable = true;

    hyprland = {
      enable = true;
      # theme = "Three-Bears";
      theme = "Foggy-Lake";

      keybindings = {
        main-mod = "SUPER";

        bindings = {
          "$mainMod, T" = ["exec, kitty"];
          "$mainMod, E" = ["exec, kitty"];
          # "$mainMod, T" = ["exec, alacritty -o font.size=12 -e tmux"];
          # "$mainMod, E" = ["exec, alacritty -o font.size=12 -e tmux"];

          "$mainMod, P" = ["exec, hyprpicker -a"];
          "$mainMod, S" = ["exec, grim -g \"$(slurp)\""];
          "$mainMod CTRL, S" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];

          ", XF86AudioRaiseVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
          ", XF86AudioLowerVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"];
        };
      };

      autostart = [
        # NOTE: The sleep 15s is a hack for tray icons,
        #       they need to be launched after waybar
        "hyprctl dispatch exec \"sleep 15s && kdeconnect-indicator\""
        "hyprctl dispatch exec \"sleep 15s && nextcloud --background\""
        "hyprctl dispatch exec \"sleep 15s && keepassxc\""
        # "alacritty -o font.size=12 -e tmux"
        "kitty"
        # "md.obsidian.Obsidian"
        # "firefox"
      ];

      workspacerules = {
        "2" = [
          "jetbrains-clion"
          "code-url-handler"
        ];
        "3" = [
          "obsidian"
        ];
        "4" = [
          "firefox"
        ];
        "10" = [
          "discord"
          "Spotify"
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
        "Spotify"
        "obsidian"
        "jetbrains-clion"
        "code-url-handler"
      ];
    };

    kitty.enable = true;

    misc = {
      enable = true;

      keepass = {
        enable = true;
        autostart = false; # TODO: This option should use hyprland module
      };

      protonmail = {
        enable = true;
        autostart = false; # TODO: This option should use hyprland module
      };
    };

    # neovim = {
    #   enable = false;
    #   alias = true;
    # };

    nextcloud = {
      enable = true;
      autostart = false; # TODO: This option should use hyprland module
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

  manual.manpages.enable = true;
  manual.html.enable = true;

  # Make fonts installed through user packages available to applications
  # NOTE: I don't think I need this anymore as all fonts are installed through the system config but let's keep this just in case
  fonts.fontconfig.enable = true; # Also updates the font-cache

  # Generate a list of installed user packages in ~/.local/share/current-user-packages
  home.file.".local/share/current-user-packages".text = let
    packages = builtins.map (p: "${p.name}") home.packages;
    sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

  home.file.".config/mpv" = {
    recursive = true;
    source = ../../config/mpv;
  };

  # TODO: Latex module
  home.file."texmf/tex/latex/custom/christex.sty".source = ../../config/latex/christex.sty;
  home.file."Notes/Obsidian/Chriphost/christex.sty".source = ../../config/latex/christex.sty; # For obsidian notes
  home.file.".indentconfig.yaml".source = ../../config/latex/.indentconfig.yaml;
  home.file.".indentsettings.yaml".source = ../../config/latex/.indentsettings.yaml;
  # TODO: Use mkLink
  # home.file."Notes/Obsidian/Chriphost/latex_snippets.json".source = ../../config/obsidian/latex_snippets.json;
  home.file."Notes/Obsidian/Chriphost/.obsidian/snippets/latex_preview.css".source = ../../config/obsidian/css_snippets/latex_preview.css;

  # TODO: If navi enabled
  # TODO: Symlink this, so the config doesn't have to be rebuilt every time
  home.file.".local/share/navi/cheats/christoph.cheat".source = ../../config/navi/christoph.cheat;

  home.activation = {
    linkObsidianLatexSnippets =
      lib.hm.dag.entryAfter ["writeBoundary"]
      (mylib.modules.mkLink "~/NixFlake/config/obsidian/latex_snippets.json" "~/Notes/Obsidian/Chriphost/latex_snippets.json");
  };

  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = nixosConfig.xdg.mime.addedAssociations;
    associations.removed = nixosConfig.xdg.mime.removedAssociations;
    defaultApplications = nixosConfig.xdg.mime.defaultApplications;
  };

  home = {
    username = username; # Inherited from flake.nix
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      LANG = "en_US.UTF-8";

      EDITOR = "hx";
      VISUAL = "hx";
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

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # Do not change
    stateVersion = "22.05";
  };

  # TODO: Split this more between laptop and desktop...
  # TODO: Check what packages are installed here and in modules and check if there is already a service/hm-module for it
  # TODO: If so use this or adapt the config from there (example gnome.sushi is also added to dbus packages in services.sushi)
  # TODO: Make a module for standard UNIX replacements
  # TODO: Make a video player module
  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # CLI Tools
    # bat # cat with wings (enabled as program)
    # exa # ls in cool (enabled as program)
    # delta # diffier diff differ (enabled as program)
    # fzf # fuzzy find (enabled as program in fish module)
    tokei # Text file statistics in a project
    poppler_utils # pdfunite
    # ffmpeg # Convert video (magic), v4
    ffmpeg_5-full # v5, including ffplay
    imagemagick # Convert image (magic)
    ueberzugpp # Display images in terminal (alacritty)
    (ripgrep.override {withPCRE2 = true;}) # fast as fuck
    nvd # nix rebuild diff
    # du-dust # Disk usage analyzer (for directories)
    gdu # Alternative to du-dust (I like it better)
    duf # Disk usage analyzer (for all disk overview)
    fd # find alternative
    sd # sed alternative
    tealdeer # very fast tldr (so readable man)
    # gtop # graphic top # We have btop already...
    fclones # duplicate file finder
    gum # nice shell scripts
    geteltorito # extreact boot image from iso
    gitbatch # overview over multiple repos
    # TODO: Maybe general document/typesetting module?
    graphviz # generate graphs from code
    xdot # .dot file viewer
    kgraphviewer # dot graph viewer
    d2 # generate diagrams from code
    plantuml
    gnuplot # generate function plots
    # TODO: Latex module with individual packages
    texlive.combined.scheme-full
    # tikzit
    # texlab # Incredibly lag
    pandoc # document converting madness
    # TODO: Programming languages module
    alejandra # nix code formatter
    nil # nix language server
    libnotify
    inotifyTools # inotifywait etc.
    atool # Archive preview
    ffmpegthumbnailer # Video thumbnails
    mediainfo
    tree # Folder preview
    # gnome.zenity # Popups from terminal
    unrar
    p7zip
    unzip
    progress

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

    appimage-run

    cool-retro-term
    ventoy-full # Bootable USB for many ISOs
    # geekbench
    spotify

    # Xooooorg/Desktop environment stuff
    # xclip
    xorg.xwininfo # See what apps run in XWayland
    # xdotool

    # Hardware/Software info
    neofetch # Easily see interesting package versions/kernel
    pciutils # lspci
    glxinfo # opengl info
    wayland-utils # wayland-info
    aha # ansi html adapter? TODO: Why did I install this?
    radeontop
    clinfo # OpenCL info
    vulkan-tools # vulkaninfo
    libva-utils # vainfo
    rocminfo # radeon comptute platform info
    hwloc
    lm_sensors
    acpica-tools # Dump ACPI tables etc.

    # Web stuff
    signal-desktop
    # element-desktop # matrix client
    # webcord # Unshitted discord? Well, except Krisp of course
    # ncspot # Spotify in cool (but slow)?
    protonvpn-cli
    # yt-dlp # download videos (from almost anywhere) # HM program
    filezilla
    # dnsmasq # For Access Point/Hotspot
    # linux-wifi-hotspot
    # spotdl-4_1_6 # My derivation as temporary fix
    spotdl

    # Tools
    # calibre # Do I even read
    virt-manager
    # gource # Visualize git commit log, completely useless
    # anki-bin # Use anki-bin as anki is some versions behind NOTE: anki-bin doesn't support fcitx5 :(
    anki
    # inputs.nixos-conf-editor.packages."x86_64-linux".nixos-conf-editor
    # octave # GNU matlab basically
    logisim-evolution # Digital circuit simulator
    digital # Digital circuit simulator
    okteta # hex editor
    kdiff3 # diff/patch tool
    font-manager

    # Office
    # sioyek # Scientific pdf reader # HM program
    xournalpp # Write with a pen, like old people
    # libreoffice-qt
    hunspell # I cna't type
    hunspellDicts.en_US
    hunspellDicts.de_DE
    obsidian # knowledge-base # Use flatpak for now, as I can't use window splitting with this version for some reason
    # logseq # knowledge-base
    # zotero # Citation/source research assistant
    # jabref # manage bibilography # NOTE: Uses jdk18 which is EOL, so can't build, use flatpak instead
    # kbibtex # bibtex editor
    # vale # Why not lint everything (including english)?

    # TODO: Development module
    # TODO: Does this conflict with devshell pythons? If so, use lowPrio
    # TODO: Merge this somehow? I want multiple pythons to merge to one with all the packages...
    # (python310.withPackages (p: with p; [
    #   p.rich
    #   p.numpy
    #   p.scipy
    #   p.matplotlib
    #   p.pillow # for ranger
    #   p.pygments # for emacs
    # ]))
    # jetbrains.pycharm-professional
    # jetbrains.idea-ultimate
    jetbrains.clion # TODO: Use toolbox instead
    jetbrains-toolbox

    # Media
    wacomtablet
    # blender
    godot
    obs-studio
    # vlc # Addition to mpv without any shaders etc
    kdenlive
    krita
    inkscape
    # handbrake
    # makemkv

    AusweisApp2

    # Use NixCommunity binary cache
    cachix

    # Generate documentation
    modules-options-doc
  ];

  home.file.".options-doc".source = "${pkgs.modules-options-doc}";

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    alacritty = {
      enable = true;

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
        catppuccin-latte = builtins.readFile (pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        } + "/Catppuccin-latte.tmTheme");
      };

      config = {
        theme = "catppuccin-latte";
      };
    };

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    btop.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    exa.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    gallery-dl.enable = true; # TODO: Alternative to cyberdrop-dl?

    git = {
      enable = true;
      delta.enable = true;
      userEmail = "christoph.urlacher@protonmail.com";
      userName = "ChUrl";
    };

    # helix = {
    #   enable = true;

    #   # NOTE: Syntax changed
    #   # languages = [
    #   #   {
    #   #     name = "verilog";
    #   #     roots = [
    #   #       ".svls.toml"
    #   #       ".svlint.toml"
    #   #     ];
    #   #     language-server = {
    #   #       command = "svls";
    #   #       args = [];
    #   #     };
    #   #   }
    #   # ];

    #   # https://docs.helix-editor.com/configuration.html
    #   settings = {
    #     # theme = "base16_terminal";
    #     editor = {
    #       scrolloff = 10;
    #       mouse = false; # Default true
    #       middle-click-paste = false; # Default true
    #       line-number = "relative";
    #       cursorline = true;
    #       auto-completion = true; # Default
    #       bufferline = "multiple";
    #       cursor-shape = {
    #         normal = "block";
    #         insert = "bar";
    #         select = "underline";
    #       };
    #       lsp.display-messages = true;
    #       indent-guides.render = false;
    #     };
    #   };
    # }; # NOTE: If error occurs after system update on fish init run "ssh-add"

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
      enable = true;
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
        default-fg                = "#4C4F69";
        default-bg 			          = "#EFF1F5";

        completion-bg		          = "#CCD0DA";
        completion-fg		          = "#4C4F69";
        completion-highlight-bg	  = "#575268";
        completion-highlight-fg	  = "#4C4F69";
        completion-group-bg		    = "#CCD0DA";
        completion-group-fg		    = "#1E66F5";

        statusbar-fg		          = "#4C4F69";
        statusbar-bg		          = "#CCD0DA";

        notification-bg		        = "#CCD0DA";
        notification-fg		        = "#4C4F69";
        notification-error-bg	    = "#CCD0DA";
        notification-error-fg	    = "#D20F39";
        notification-warning-bg	  = "#CCD0DA";
        notification-warning-fg	  = "#FAE3B0";

        inputbar-fg			          = "#4C4F69";
        inputbar-bg 		          = "#CCD0DA";

        recolor-lightcolor		    = "#EFF1F5";
        recolor-darkcolor		      = "#4C4F69";

        index-fg			            = "#4C4F69";
        index-bg			            = "#EFF1F5";
        index-active-fg		        = "#4C4F69";
        index-active-bg		        = "#CCD0DA";

        render-loading-bg		      = "#EFF1F5";
        render-loading-fg		      = "#4C4F69";

        highlight-color		        = "#575268";
        highlight-fg              = "#EA76CB";
        highlight-active-color	  = "#EA76CB";
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };
  };

  services = {
    # kdeconnect.enable = true; # Note: This does not setup the firewall at all
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
