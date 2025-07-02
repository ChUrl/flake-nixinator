# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{
  hostname,
  username,
  lib,
  mylib,
  nixosConfig,
  config,
  pkgs,
  ...
}:
# This is a HM module.
# Because no imports/options/config is defined explicitly, everything is treated as config:
# { inputs, lib, ... }: { ... } gets turned into { inputs, lib, ... }: { config = { ... }; } implicitly.
rec {
  # Every module is a nix expression, specifically a function { inputs, lib, ... }: { ... }.
  # Every module (/function) is called with the same arguments as this module.
  # Arguments with matching names are "plugged in" into the right slots,
  # the case of different arity is handled by always providing ellipses (...) in module definitions.
  imports = [
    # Import the host-specific HM config.
    # It will be merged with the main config (like all different modules).
    # Settings regarding a specific host (e.g. desktop or laptop)
    # should only be made in the host-specific config.
    ./${hostname}

    # Import all of my custom HM modules.
    ../modules
  ];

  # Enable and configure my custom HM modules.
  paths = {
    enable = true; # You can't disable this
    nixflake = "${config.home.homeDirectory}/NixFlake";
    dotfiles = "${config.home.homeDirectory}/NixFlake/config";
  };

  modules = {
    ags.enable = false; # TODO: Configure

    chromium = {
      enable = true;
      google = false;
    };

    color = {
      enable = true; # You can't disable this
      lightScheme = "catppuccin-latte";
      darkScheme = "catppuccin-mocha";
      font = "JetBrainsMono Nerd Font Mono";
    };

    firefox = {
      enable = true;
      wayland = true;
      vaapi = true;
      disableTabBar = true;
      defaultBookmarks = true;
      gnomeTheme = true;
    };

    fish.enable = true;

    hyprland = {
      enable = true;
      dunst.enable = false; # Disable for hyprpanel
      theme = "Foggy-Lake"; # Three-Bears

      keybindings = {
        main-mod = "SUPER";

        bindings = {
          "$mainMod, T" = ["exec, kitty"];
          "$mainMod, E" = ["exec, kitty"];
          "$mainMod, N" = ["exec, neovide"];
          "$mainMod SHIFT, N" = ["exec, neovide ${config.paths.dotfiles}/navi/christoph.cheat"];
          "$mainMod CTRL, N" = ["exec, kitty navi"];
          "$mainMod SHIFT, F" = ["exec, neovide ${config.paths.dotfiles}/flake.nix"];

          "$mainMod, P" = ["exec, hyprpicker --autocopy --format=hex"];
          "$mainMod, S" = ["exec, grim -g \"$(slurp)\""];
          "$mainMod CTRL, S" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];
          "$mainMod SHIFT, S" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];

          ", XF86AudioRaiseVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
          ", XF86AudioLowerVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"];
          ", XF86AudioPlay" = ["exec, playerctl play-pause"];
          ", XF86AudioPrev" = ["exec, playerctl previous"];
          ", XF86AudioNext" = ["exec, playerctl next"];
        };
      };

      autostart = {
        immediate = [
        ];

        delayed = [
          # "kdeconnect-indicator"
          "kitty"
          "nextcloud --background"
          "keepassxc"
        ];
      };

      windowrules = [
        # TODO: Doesn't work, use focus_on_activate for now
        # "suppressevent activate, class:^(Unity)$"
        # "suppressevent activatefocus, class:^(Unity)$"
      ];

      workspacerules = {
        "2" = [
          "Zotero"

          "neovide"
          "code-url-handler"

          # NOTE: Pinning Jetbrains IDEs to a workspace prevents them from being on any other :(
          # "jetbrains-clion"
          # "jetbrains-idea"
          # "jetbrains-pycharm"
          # "jetbrains-rustrover"
          # "jetbrains-rider"
          # "jetbrains-webstorm"
        ];
        "3" = [
          "obsidian"

          "unityhub"
          "Unity"
        ];
        "4" = [
          "firefox"
          "Google-chrome"
          "chromium-browser"
        ];
        "5" = [
          "steam"
        ];
        "6" = [
          # Should match all steam games
          "steam_app_(.+)"
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

      transparent-opacity = "0.8";

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
        "jetbrains-webstorm"
        "code-url-handler"
        "neovide"
        "steam"
      ];
    };

    hyprpanel.enable = true;
    kitty.enable = true;
    latex.enable = true;

    neovim = {
      enable = true;
      alias = true;
      neovide = true;
    };

    nnn.enable = false;

    rofi = {
      enable = true;
      # theme = "Three-Bears";
      theme = "Foggy-Lake";
    };

    waybar.enable = false;
    zathura.enable = true;
  };

  manual = {
    manpages.enable = true;
    html.enable = false;
  };

  # Make fonts installed through user packages available to applications.
  # Also updates the font-cache.
  fonts.fontconfig.enable = true;

  # This only works when HM is installed as a system module,
  # as nixosConfig won't be available otherwise.
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      associations.added = nixosConfig.xdg.mime.addedAssociations;
      associations.removed = nixosConfig.xdg.mime.removedAssociations;
      defaultApplications = nixosConfig.xdg.mime.defaultApplications;
    };

    # TODO: What about desktop portals? They're configured in system config, do I need to do sth here?
    portal = {
      enable = nixosConfig.xdg.portal.enable;
      xdgOpenUsePortal = nixosConfig.xdg.portal.xdgOpenUsePortal;
      config.common.default = nixosConfig.xdg.portal.config.common.default;
      extraPortals = nixosConfig.xdg.portal.extraPortals;
    };
  };

  home = {
    inherit username; # Inherited from flake.nix

    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

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

      # Run SSH_ASKPASS as GUI, not TTY for Obsidian git
      SSH_ASKPASS_REQUIRE = "prefer";

      # GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # Files to generate in the home directory are specified here.
    file = let
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAoJac+GdGtzblCMA0lBfMdSR6aQ4YyovrNglCFGIny christoph.urlacher@protonmail.com";
    in {
      # Generate a list of installed user packages in ~/.local/share/current-user-packages
      ".local/share/current-user-packages".text = let
        packages = builtins.map (p: "${p.name}") home.packages;
        sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
        formatted;

      # TODO: If navi enabled
      ".local/share/navi/cheats/christoph.cheat".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.dotfiles}/navi/christoph.cheat";

      ".ssh/id_ed25519.pub".text = "${sshPublicKey}";
      ".ssh/allowed_signers".text = "* ${sshPublicKey}";
    };

    # Here, custom scripts can be run when activating a HM generation.
    # If those scripts contain side-effects, like creating files,
    # they must be placed after the "writeBoundary" node in the execution graph.
    activation = {
      # Example with side-effects:
      # linkObsidianLatexSnippets =
      #   lib.hm.dag.entryAfter ["writeBoundary"]
      #   (mylib.modules.mkLink "~/NixFlake/config/obsidian/latex_snippets.json" "~/Notes/Obsidian/Chriphost/latex_snippets.json");
    };

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
      mediainfo # Media meta information
      file # File meta information
      tree # Folder preview
      unrar # Cooler WinRar
      p7zip # Zip stuff
      unzip # Unzip stuff
      progress # Find coreutils processes and show their progress
      tokei # Text file statistics in a project
      nvd # nix rebuild diff
      ripdrag # drag & drop from terminal
      playerctl # media player control
      pastel # color tools

      # Hardware/Software info
      pciutils # lspci
      glxinfo # opengl info
      wayland-utils # wayland-info
      clinfo # OpenCL info
      vulkan-tools # vulkaninfo
      libva-utils # vainfo
      vdpauinfo # Video-Decode and Presentation API for Unix info
      hwloc # Generate CPU topology diagram
      lm_sensors # Readout hardware sensors
      acpica-tools # Dump ACPI tables etc.

      # Video/Image utils
      ffmpeg_7-full # I love ffmpeg (including ffplay)
      ffmpeg-normalize # Normalize audio
      imagemagick # Convert image (magic)

      # Document utils
      poppler_utils # pdfunite
      graphviz # generate graphs from code
      d2 # generate diagrams from code
      plantuml # generate diagrams
      gnuplot # generate function plots
      pdf2svg # extract vector graphics from pdf
      pandoc # document converting madness
      # decker # TODO: Build failure

      # Networking
      dig # Make DNS requests
      tcpdump # Listen in on TCP traffic
      traceroute # "Follow" a packet
      gping # ping with graph
      curlie # curl a'la httpie
      wget # download that shit
      dogdns # dns client
      rsync # cp on steroids
      rclone # Rsync for cloud
      httpie # Cool http client
      cifs-utils # Mount samba shares
      nfs-utils # Mount NFS shares
      sshfs # Mount remote directories via SSH

      protonvpn-gui
      protonmail-bridge-gui
      protonvpn-cli_2 # TODO: Not compatible with systemd-networkd?
      protonmail-bridge # TODO: Enable on startup, email module

      # GUI apps
      signal-desktop
      anki
      font-manager # Previews fonts, but doesn't set them
      nextcloud-client
      keepassxc
      AusweisApp2
      thunderbird # TODO: Email module
      obsidian
      # logseq
      # anytype # Use flatpak
      zotero
      zeal-qt6 # docs browser
      helvum
      vlc
      audacity

      # Office
      wacomtablet # For xournalpp/krita
      xournalpp # Write with a pen, like old people
      hunspell # I cna't type
      hunspellDicts.en_US
      hunspellDicts.de_DE

      # TODO: Module, I need to add python packages from multiple modules to the same interpreter
      python313

      # Use NixCommunity binary cache
      cachix

      # Generate documentation
      # modules-options-doc
    ];

    # Do not change.
    # This marks the version when NixOS was installed for backwards-compatibility.
    stateVersion = "22.05";
  };

  # home.file.".options-doc".source = "${pkgs.modules-options-doc}";

  # Packages with extra options managed by HomeManager natively
  programs = {
    # The home-manager management tool.
    # Will only be enabled if HM is installed standalone.
    home-manager.enable = true;

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

    fastfetch.enable = true;
    fd.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    git = {
      enable = true;

      userEmail = "christoph.urlacher@protonmail.com";
      userName = "Christoph Urlacher";

      signing = {
        signByDefault = true;
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
      };

      lfs.enable = true;
      diff-so-fancy = {
        enable = true;
        changeHunkIndicators = true;
        markEmptyLines = false;
        stripLeadingSymbols = true;
      };

      extraConfig = {
        core = {
          compression = 9;
          # whitespace = "error";
          preloadindex = true;
        };

        init = {
          defaultBranch = "main";
        };

        gpg = {
          ssh = {
            allowedSignersFile = "~/.ssh/allowed_signers";
          };
        };

        status = {
          branch = true;
          showStash = true;
          showUntrackedFiles = "all";
        };

        pull = {
          default = "current";
          rebase = true;
        };

        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };

        rebase = {
          autoStash = true;
          missingCommitsCheck = "warn";
        };

        diff = {
          context = 3;
          renames = "copies";
          interHunkContext = 10;
        };

        interactive = {
          diffFilter = "${pkgs.diff-so-fancy}/bin/diff-so-fancy --patch";
          singlekey = true;
        };

        log = {
          abbrevCommit = true;
          graphColors = "blue,yellow,cyan,magenta,green,red";
        };

        branch = {
          sort = "-committerdate";
        };

        tag = {
          sort = "-taggerdate";
        };

        pager = {
          branch = false;
          tag = false;
        };

        url = {
          "ssh://git@gitea.local.chriphost.de:222/christoph/" = {
            insteadOf = "gitea:";
          };
          "git@github.com:" = {
            insteadOf = "github:";
          };
        };
      };
    };

    keychain = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      enableNushellIntegration = false;
      enableXsessionIntegration = true;
      # agents = ["ssh"]; # Deprecated
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

    mpv = {
      enable = false;
      config = {
        gpu-context = "wayland";
      };
    };

    navi = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    nix-index = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    nushell.enable = false;
    ssh = {
      enable = true; # NOTE: Do NOT generate .ssh/config using HM, as it will have invalid permissions!
      compression = true;

      matchBlocks = {
        "servenix" = {
          user = "christoph";
          hostname = "local.chriphost.de";
        };
        "thinknix" = {
          user = "christoph";
          hostname = "think.chriphost.de";
        };
        "vps" = {
          user = "root";
          hostname = "vps.chriphost.de";
        };
      };
    };

    tmux = {
      enable = false;

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

    yazi = let
      yazi-plugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "63f9650e522336e0010261dcd0ffb0bf114cf912"; # NOTE: Refresh after system updates depending on the yazi version
        hash = "sha256-ZCLJ6BjMAj64/zM606qxnmzl2la4dvO/F5QFicBEYfU=";
      };

      yazi-starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "6a0f3f788971b155cbc7cec47f6f11aebbc148c9";
        sha256 = "sha256-q1G0Y4JAuAv8+zckImzbRvozVn489qiYVGFQbdCxC98=";
      };
    in {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "y";

      # https://yazi-rs.github.io/docs/configuration/yazi
      settings = {
        mgr = {
          show_hidden = false;
        };

        # Associate mimetypes with edit/open/play actions
        # open = {};

        # Configure programs to edit/open/play files
        opener = {
          play = [
            {
              run = ''vlc "$@"'';
              orphan = true;
              for = "unix";
            }
          ];
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              for = "unix";
            }
          ];
          open = [
            {
              run = ''xdg-open "$@"'';
              desc = "Open";
            }
          ];
        };

        preview = {
          max_width = 1000;
          max_height = 1000;
        };

        plugin.prepend_fetchers = [
          {
            id = "git";
            name = "*";
            run = "git";
          }
          {
            id = "git";
            name = "*/";
            run = "git";
          }
        ];
      };

      plugins = {
        full-border = "${yazi-plugins}/full-border.yazi";
        starship = "${yazi-starship}";
        git = "${yazi-plugins}/git.yazi";
        mount = "${yazi-plugins}/mount.yazi";
        chmod = "${yazi-plugins}/chmod.yazi";
        # toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
      };

      initLua = ''
        require("full-border"):setup()
        require("starship"):setup()
        require("git"):setup()
      '';

      keymap = {
        input.prepend_keymap = [
          {
            # Don't exit vi mode on <Esc>, but close the input
            on = "<Esc>";
            run = "close";
            desc = "Cancel input";
          }
        ];

        mgr.prepend_keymap = [
          {
            on = "M";
            run = "plugin mount";
            desc = "Manage device mounts";
          }
          {
            on = ["C"];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = "!";
            run = ''shell "$SHELL" --block'';
            desc = "Open $SHELL here";
          }
          {
            on = "<C-n>";
            run = ''shell -- ripdrag -a -n "$@"''; # $@: all selected files, $0: the hovered file, $n: the nth selected file
            desc = "Expose files in ripdrag";
          }
          {
            on = "y";
            run = [''shell -- for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list'' "yank"];
            desc = "Copy files to system clipboard on yank";
          }
        ];
      };
    };

    yt-dlp.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };
  };

  services = {
    # kdeconnect.enable = true; # Note: This does not setup the firewall at all

    flatpak = {
      # FlatHub stable is only added by default if no custom remotes are specified
      remotes = lib.mkOptionDefault [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];

      packages = [
        "com.github.tchx84.Flatseal"

        "com.spotify.Client"

        # NOTE: Also change discord-ipc-0 below
        "com.discordapp.Discord"
        # "com.discordapp.DiscordCanary"
        # "dev.vencord.Vesktop"

        # "com.google.Chrome"
        # "md.obsidian.Obsidian" # NOTE: Installed via package
        # "io.anytype.anytype"
      ];

      uninstallUnmanaged = true;
      uninstallUnused = true;

      update.auto = {
        enable = true;
        onCalendar = "daily"; # Default value: weekly
      };

      overrides = {
        global = {
          # Force Wayland by default
          # Context.sockets = ["wayland" "!x11" "!fallback-x11"]; # NOTE: Makes discord + steam crash

          Context.filesystems = ["/nix/store:ro"];

          Environment = {
            # Fix un-themed cursor in some Wayland apps
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

            # Force correct theme for some GTK apps
            GTK_THEME = "Adwaita:light";
          };
        };

        "io.anytype.anytype".Context = {
          filesystems = [
            "${config.home.homeDirectory}"
          ];
        };

        "com.discordapp.Discord".Context = {
          filesystems = [
            "${config.home.homeDirectory}"
          ];
        };
      };
    };
  };

  systemd = {
    user = {
      tmpfiles.rules = [
        # Fix Discord rich presence for Flatpak
        "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"
        # "L %t/discord-ipc-0 - - - - app/com.discordapp.DiscordCanary/discord-ipc-0"
      ];

      # Nicely reload system units when changing configs
      startServices = "sd-switch";
    };
  };
}
