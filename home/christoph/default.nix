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
  modules = {
    chromium = {
      enable = true;
      google = false;
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
        "code-url-handler"
        "neovide"
      ];
    };

    kitty.enable = true;
    latex.enable = true;

    neovim = {
      enable = true;
      alias = true;
      neovide = true;
    };

    nnn.enable = true;

    rofi = {
      enable = true;
      # theme = "Three-Bears";
      theme = "Foggy-Lake";
    };

    waybar = {
      enable = true;
    };

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

      # GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # Files to generate in the home directory are specified here.
    file = {
      # Generate a list of installed user packages in ~/.local/share/current-user-packages
      ".local/share/current-user-packages".text = let
        packages = builtins.map (p: "${p.name}") home.packages;
        sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
        formatted;

      # TODO: If navi enabled
      ".local/share/navi/cheats/christoph.cheat".source = ../../config/navi/christoph.cheat; # TODO :Symlink
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

      # GUI apps
      ventoy-full # Bootable USB for many ISOs
      signal-desktop
      anki
      font-manager # Previews fonts, but doesn't set them
      nextcloud-client
      keepassxc
      AusweisApp2
      protonmail-bridge # TODO: Enable on startup, email module
      thunderbird # TODO: Email module

      # Office
      wacomtablet # For xournalpp/krita
      xournalpp # Write with a pen, like old people
      hunspell # I cna't type
      hunspellDicts.en_US
      hunspellDicts.de_DE

      # TODO: Module, I need to add python packages from multiple modules to the same interpreter
      python312

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
      lfs.enable = true;

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

    mpv.enable = true;

    navi = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    nix-index = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    nushell.enable = false;
    ssh.enable = true;

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

  systemd.user.tmpfiles.rules = [
    # Fix Discord rich presence for Flatpak
    "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"
  ];

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
