# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
# The nixosConfig allows to access the toplevel system configuration from within home manager
# https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L19
{
  inputs,
  hostname,
  username,
  publicKeys,
  lib,
  mylib,
  nixosConfig,
  config,
  pkgs,
  headless,
  ...
}:
# This is a HM module.
# Because no imports/options/config is defined explicitly, everything is treated as config:
# { inputs, lib, ... }: { ... } gets turned into { inputs, lib, ... }: { config = { ... }; } implicitly.
{
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
  paths = rec {
    nixflake = "${config.home.homeDirectory}/NixFlake";
    dotfiles = "${nixflake}/config";
  };

  modules = {
    # TODO: Reenable after build-failure on 2025-07-18
    beets.enable = false; # !headless;

    btop.enable = true;

    chromium = {
      enable = !headless;
      google = false;
    };

    color = {
      scheme = "catppuccin-mocha";
      font = builtins.head nixosConfig.fonts.fontconfig.defaultFonts.monospace;
      wallpaper = "Windows";

      accent = "mauve";
      accentHl = "pink";
      accentDim = "lavender";
      accentText = "base";
    };

    docs.enable = !headless;

    firefox = {
      enable = !headless;
      wayland = true;
      vaapi = true;
      textfox = true;
      disableTabBar = true;
    };

    fish.enable = true;

    git = {
      enable = true;

      userName = "Christoph Urlacher";
      userEmail = "christoph.urlacher@protonmail.com";
      signCommits = true;
    };

    hyprland = {
      enable = !headless;
      dunst.enable = !config.modules.hyprpanel.enable; # Disable for hyprpanel

      keybindings = {
        main-mod = "SUPER";

        bindings = {
          "$mainMod, t" = ["exec, kitty"];
          "$mainMod, e" = ["exec, kitty --title=Yazi yazi"];
          "$mainMod, n" = ["exec, neovide"];
          # "$mainMod, r" = ["exec, kitty --title=Rmpc rmpc"];
          "$mainMod CTRL, n" = ["exec, kitty --title=Navi navi"];
          "$mainMod SHIFT, n" = ["exec, neovide ${config.paths.dotfiles}/navi/christoph.cheat"];
          "$mainMod SHIFT, f" = ["exec, neovide ${config.paths.dotfiles}/flake.nix"];

          "$mainMod, p" = ["exec, hyprpicker --autocopy --format=hex"];
          "$mainMod, s" = ["exec, grim -g \"$(slurp)\""];
          "$mainMod CTRL, s" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];
          "$mainMod SHIFT, s" = ["exec, grim -g \"$(slurp)\" - | wl-copy"];

          ", XF86AudioRaiseVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"];
          ", XF86AudioLowerVolume" = ["exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"];
          ", XF86AudioPlay" = ["exec, playerctl play-pause"];
          ", XF86AudioPrev" = ["exec, playerctl previous"];
          ", XF86AudioNext" = ["exec, playerctl next"];

          ", XF86MonBrightnessDown" = ["exec, hyprctl hyprsunset gamma -10"];
          ", XF86MonBrightnessUp" = ["exec, hyprctl hyprsunset gamma +10"];
          "$mainMod, XF86MonBrightnessDown" = ["exec, hyprctl hyprsunset temperature 5750"];
          "$mainMod, XF86MonBrightnessUp" = ["exec, hyprctl hyprsunset identity"];

          # "CTRL ALT, t" = ["exec, bash -c 'systemctl --user restart hyprpanel.service'"];
        };

        ws-bindings = {
          # "<Workspace>" = "<Key>";
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          "10" = "0";
        };

        special-ws-bindings = {
          "ferdium" = "x";
          "msty" = "z";
          "btop" = "b";
          "rmpc" = "r";
        };
      };

      autostart = {
        immediate = [
          "kitty"
          "nextcloud --background"
          "protonvpn-app"

          # "kdeconnect-indicator" # started by services.kdeconnect.indicator
        ];

        delayed = [
          "keepassxc" # The tray doesn't work when started too early
        ];

        special-silent = {
          "ferdium" = ["ferdium"];
          "msty" = ["msty"];
          "btop" = ["kitty --title=Btop btop"];
          "rmpc" = ["kitty --title=Rmpc rmpc"];
        };
      };

      windowrules = [];

      workspacerules = {
        "1" = [];
        "2" = ["Zotero" "neovide" "code-url-handler"];
        "3" = ["obsidian" "unityhub" "Unity"];
        "4" = ["firefox" "Google-chrome" "chromium-browser"];
        "5" = ["steam"];
        "6" = ["steam_app_(.+)"];
        "7" = ["signal"];
        "8" = ["tidal-hifi"];
        "9" = ["discord"];
        "10" = ["python3"];
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
        "tidal-hifi"
        "obsidian"
        "firefox"
        "jetbrains-clion"
        "jetbrains-idea"
        "jetbrains-pycharm"
        "jetbrains-rustrover"
        "jetbrains-rider"
        "jetbrains-webstorm"
        "code-url-handler"
        "neovide"
        "steam"
        "ferdium"
        "Msty"
      ];
    };

    hyprpanel.enable = !headless;
    kitty.enable = !headless;
    lazygit.enable = true;
    mpd.enable = !headless;

    neovim = {
      enable = true;
      alias = true;
      neovide = !headless;
    };

    nnn.enable = false; # Use yazi
    qutebrowser.enable = !headless;
    rmpc.enable = !headless;

    rofi = {
      enable = !headless;
    };

    waybar.enable = false; # Use hyprpanel
    yazi.enable = true;
    zathura.enable = !headless;
  };

  manual = {
    manpages.enable = nixosConfig.documentation.enable;
    html.enable = false;
  };

  # Make fonts installed through user packages available to applications.
  # Also updates the font-cache.
  fonts.fontconfig.enable = !headless;

  # This only works when HM is installed as a system module,
  # as nixosConfig won't be available otherwise.
  xdg = {
    enable = true; # This only does xdg path management
    mime.enable = nixosConfig.modules.mime.enable;

    mimeApps = {
      enable = nixosConfig.modules.mime.enable;

      associations.added = nixosConfig.xdg.mime.addedAssociations;
      associations.removed = nixosConfig.xdg.mime.removedAssociations;
      defaultApplications = nixosConfig.xdg.mime.defaultApplications;
    };

    portal = {
      inherit (nixosConfig.xdg.portal) enable xdgOpenUsePortal config extraPortals;
    };
  };

  home = {
    inherit username; # Inherited from flake.nix

    homeDirectory = "/home/${config.home.username}";
    enableNixpkgsReleaseCheck = true;

    # Environment variables
    sessionVariables = lib.mkMerge [
      {
        LANG = "en_US.UTF-8";
        MANPAGER = "nvim +Man!";
      }
      (lib.mkIf (!headless) {
        # TERMINAL = "alacritty -o font.size=12";
        TERMINAL = "kitty";
        BROWSER = "firefox";

        # Enable wayland
        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland";
        NIXOS_OZONE_WL = "1";
        SDL_VIDEODRIVER = "wayland";

        # Run SSH_ASKPASS as GUI, not TTY for Obsidian git
        SSH_ASKPASS_REQUIRE = "prefer";

        # GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
      })
    ];

    # Files to generate in the home directory are specified here.
    file = lib.mkMerge [
      {
        # Because we can't access the absolute path /run/secrets/... we have to symlink.
        # This will create a chain of links leading to /run/secrets/... without /nix/store
        # containing the secret contents.
        ".ssh/id_ed25519".source =
          config.lib.file.mkOutOfStoreSymlink
          nixosConfig.sops.secrets.ssh-private-key.path;

        ".ssh/id_ed25519.pub".text = "${publicKeys.${username}.ssh}";

        ".secrets/age/age.pub".text = "${publicKeys.${username}.age}";

        # The sops config specifies what happens when we call sops edit
        ".sops.yaml".text = ''
          keys:
            - &${username} ${publicKeys.${username}.age}
          creation_rules:
            - path_regex: secrets.yaml$
              key_groups:
                - age:
                  - *${username}
        '';

        ".config/nix/nix.conf".source =
          config.lib.file.mkOutOfStoreSymlink
          nixosConfig.sops.templates."nix.conf".path;
      }
      (lib.mkIf nixosConfig.modules.desktopportal.termfilechooser.enable {
        ".config/xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD=kitty --class=file_chooser
          open_mode = suggested
          save_mode = last
        '';
      })
      (lib.mkIf config.modules.git.enable {
        ".ssh/allowed_signers".text = "* ${publicKeys.${username}.ssh}";
      })
      (lib.mkIf config.programs.navi.enable {
        ".local/share/navi/cheats/christoph.cheat".source = config.lib.file.mkOutOfStoreSymlink "${config.paths.dotfiles}/navi/christoph.cheat";
      })
      (lib.mkIf (!headless) {
        # killswitch: 0, 1, 2 (off, on, advanced - still on after reboot)
        # netshield: 0, 1, 2 (off, malware, ads+malware+trackers)
        ".config/Proton/VPN/settings.json".text = ''
          {
              "protocol": "wireguard",
              "killswitch": 1,
              "custom_dns": {
                  "enabled": false,
                  "ip_list": []
              },
              "ipv6": true,
              "anonymous_crash_reports": false,
              "features": {
                  "netshield": 1,
                  "moderate_nat": true,
                  "vpn_accelerator": true,
                  "port_forwarding": false
              }
          }
        '';
        ".config/Proton/VPN/app-config.json".text = ''
          {
              "tray_pinned_servers": [
                  "DE",
                  "CH",
                  "AU"
              ],
              "connect_at_app_startup": null,
              "start_app_minimized": true
          }
        '';
      })
    ];

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
    # TODO: Make the headless installations smaller
    packages = with pkgs;
      lib.mkMerge [
        [
          # Shell utils
          (ripgrep.override {withPCRE2 = true;}) # fast as fuck
          gdu # Alternative to du-dust (I like it better)
          duf # Disk usage analyzer (for all disk overview)
          sd # Sed alternative
          fclones # Duplicate file finder
          tealdeer # Very fast tldr (so readable man)
          killall
          atool # Archive preview
          ouch # Unified compression/decompression
          ffmpegthumbnailer # Video thumbnails
          mediainfo # Media meta information
          file # File meta information
          unrar # Cooler WinRar
          p7zip # Zip stuff
          unzip # Unzip stuff
          progress # Find coreutils processes and show their progress
          tokei # Text file statistics in a project
          playerctl # Media player control
          pastel # Color tools
          nvd # Nix rebuild diff
          nix-search-tv # Search nixpkgs, nur, nixos options and homemanager options
          nix-tree # Browse the nix store sorted by size (gdu for closures)
          nurl # Generate nix fetcher sections based on URLs
          python313 # Nicer scripting than bash
          binsider # Analyze binaries
          lazyjournal # Journalctl viewer
          systemctl-tui
          restic # Backups

          # Hardware/Software info
          pciutils # lspci
          glxinfo # OpenGL info
          wayland-utils # wayland-info
          clinfo # OpenCL info
          vulkan-tools # vulkaninfo
          libva-utils # vainfo
          vdpauinfo # Video-Decode and Presentation API for Unix info
          hwloc # Generate CPU topology diagram
          lm_sensors # Readout hardware sensors
          acpica-tools # Dump ACPI tables etc.
          smartmontools # Disk health
          nvme-cli # NVME disk health

          # Video/Image/Audio utils
          ffmpeg-full # I love ffmpeg (including ffplay)
          ffmpeg-normalize # Normalize audio
          imagemagick # Convert image (magic)
          mp3val # Validate mp3 files
          flac # Validate flac files
          spotdl

          # Document utils
          poppler_utils # pdfunite
          graphviz # generate graphs from code
          d2 # generate diagrams from code
          plantuml # generate diagrams
          gnuplot # generate function plots
          pdf2svg # extract vector graphics from pdf
          pandoc # document converting madness

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
          protonvpn-cli_2
          protonmail-bridge # TODO: Enable on startup, email module

          # Run unpatched binaries on NixOS
          # Sets NIX_LD_LIBRARY_PATH and NIX_LD variables for nix-ld.
          # Usage: "nix-alien-ld -- <Executable>".
          inputs.nix-alien.packages.${system}.nix-alien

          # Search nixpkgs
          inputs.nps.packages.${system}.default

          # Use NixCommunity binary cache
          cachix
        ]
        (lib.mkIf (!headless) [
          ripdrag # drag & drop from terminal
          veracrypt

          # Proton
          protonvpn-gui
          protonmail-bridge-gui

          # GUI stuff
          signal-desktop
          anki
          font-manager # Previews fonts, but doesn't set them
          nextcloud-client
          keepassxc
          thunderbird # TODO: Email module
          obsidian
          zotero
          zeal-qt6 # docs browser
          helvum
          vlc
          audacity
          ferdium
          gparted
          tidal-hifi
          tidal-dl-ng
          picard

          # Office
          wacomtablet # For xournalpp/krita
          xournalpp # Write with a pen, like old people
          hunspell # I cna't type
          hunspellDicts.en_US
          hunspellDicts.de_DE
        ])
      ];
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

    cava = {
      enable = !headless;

      settings = {
        general = {
          framerate = 60; # default 60
          autosens = 1; # default 1
          sensitivity = 100; # default 100
          lower_cutoff_freq = 50; # not passed to cava if not provided
          higher_cutoff_freq = 10000; # not passed to cava if not provided
        };

        smoothing = {
          noise_reduction = 77; # default 77
          monstercat = false; # default false
          waves = false; # default false
        };

        color = {
          # https://github.com/catppuccin/cava/blob/main/themes/latte-transparent.cava
          gradient = 1;
          gradient_color_1 = "'#179299'";
          gradient_color_2 = "'#04a5e5'";
          gradient_color_3 = "'#209fb5'";
          gradient_color_4 = "'#1e66f5'";
          gradient_color_5 = "'#8839ef'";
          gradient_color_6 = "'#ea76cb'";
          gradient_color_7 = "'#e64553'";
          gradient_color_8 = "'#d20f39'";
        };
      };
    };

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

    keychain = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      enableXsessionIntegration = !headless;
      keys = ["id_ed25519"];
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

    # spicetify = let
    #   spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    # in {
    #   enable = true;
    #
    #   # https://github.com/catppuccin/spicetify
    #   theme = spicePkgs.themes.catppuccin;
    #   colorScheme = "mocha";
    #
    #   wayland = true;
    #
    #   enabledExtensions = with spicePkgs.extensions; [
    #     adblock
    #     hidePodcasts
    #     oneko # cat
    #   ];
    #   # enabledCustomApps = with spicePkgs.apps; [];
    #   enabledSnippets = with spicePkgs.snippets; [
    #     rotatingCoverart
    #     pointer
    #   ];
    # };

    ssh = {
      enable = true;
      compression = true;

      matchBlocks = {
        "nixinator" = {
          user = "christoph";
          hostname = "192.168.86.50";
        };
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

    yt-dlp.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };
  };

  services = {
    kdeconnect = {
      enable = nixosConfig.programs.kdeconnect.enable; # Only the system package sets up the firewall
      indicator = nixosConfig.programs.kdeconnect.enable;
    };

    flatpak = lib.mkIf nixosConfig.services.flatpak.enable {
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

      packages = lib.mkMerge [
        []
        (lib.mkIf (!headless) [
          "com.github.tchx84.Flatseal"

          # "com.spotify.Client" # Don't need this when spicetify is enabled

          "com.discordapp.Discord"
          # "com.discordapp.DiscordCanary"

          # "com.google.Chrome"
          # "md.obsidian.Obsidian"
          # "io.anytype.anytype"
        ])
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
      tmpfiles.rules = lib.mkMerge [
        []
        (lib.mkIf (mylib.modules.contains
          config.services.flatpak.packages
          "com.discordapp.Discord") [
          # Fix Discord rich presence for Flatpak
          "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"
        ])
        (lib.mkIf (mylib.modules.contains
          config.services.flatpak.packages
          "com.discordapp.DiscordCanary") [
          # Fix Discord rich presence for Flatpak
          "L %t/discord-ipc-0 - - - - app/com.discordapp.DiscordCanary/discord-ipc-0"
        ])
      ];

      # Nicely reload system units when changing configs
      startServices = "sd-switch";
    };
  };
}
