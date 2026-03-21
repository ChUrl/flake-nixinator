{
  pkgs,
  nixosConfig,
  config,
  lib,
  mylib,
  username,
  inputs,
  ...
}: {
  config = let
    inherit (config.homemodules) color;
  in {
    paths = rec {
      nixflake = "${config.home.homeDirectory}/NixFlake";
      dotfiles = "${nixflake}/config";
    };

    homemodules = {
      color = {
        scheme = "catppuccin-mocha";
        accent = "mauve";
        accentHl = "pink";
        accentDim = "lavender";
        accentText = "base";

        font = "MonoLisa Alt Script";
      };

      fish.enable = true;

      git = {
        enable = true;

        userName = "Christoph Urlacher";
        userEmail = "christoph.urlacher@protonmail.com";
        signCommits = true;
      };

      kitty.enable = true;
      lazygit.enable = true;

      neovim = {
        enable = true;
        alias = true;
        neovide = true;
      };

      yazi.enable = true;
    };

    home = {
      inherit username;

      homeDirectory = "/Users/${config.home.username}";
      enableNixpkgsReleaseCheck = true;

      packages = with pkgs; [
        (ripgrep.override {withPCRE2 = true;})
        gdu
        duf
        sd
        fclones
        tealdeer
        killall
        atool
        exiftool
        ouch
        ffmpegthumbnailer
        mediainfo
        file
        unrar
        p7zip
        unzip
        progress
        tokei
        nix-search-tv
        nix-tree
        just

        ffmpeg-full
        imagemagick

        poppler-utils
        pdf2svg
        pandoc

        dig
        tcpdump
        gping
        curlie
        wget
        doggo
        rsync
        rclone
        httpie

        inputs.nps.packages.${pkgs.stdenv.hostPlatform.system}.default

        cachix

        # GUI
        ripdrag
        jellyfin-tui
      ];

      stateVersion = "25.11";
    };

    # TODO: Deduplicate with other configs
    programs = {
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

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      eza = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      fastfetch = {
        enable = true;

        settings = {
          logo = {
            padding = {
              top = 4;
              left = 1;
              right = 2;
            };
          };

          display = {
            separator = "";
            key.width = 17;
          };

          # Box Drawing: ╭ ─ ╮ ╰ ╯ │
          modules = [
            # Title
            {
              type = "title";
              format = "{#1}╭─── {#}{user-name-colored}";
            }

            # System Information
            {
              type = "custom";
              format = "{#1}│ {#}System Information";
            }
            {
              type = "os";
              key = "{#separator}│  {#keys}󰍹 OS";
            }
            {
              type = "kernel";
              key = "{#separator}│  {#keys}󰒋 Kernel";
            }
            {
              type = "bootmgr";
              key = "{#separator}│  {#keys}󰒋 BootMGR";
            }
            {
              type = "uptime";
              key = "{#separator}│  {#keys}󰅐 Uptime";
            }
            {
              type = "packages";
              key = "{#separator}│  {#keys}󰏖 Packages";
              # format = "{all}";
            }
            {
              type = "custom";
              format = "{#1}│";
            }

            # Desktop Environment
            {
              type = "custom";
              format = "{#1}│ {#}Desktop Environment";
            }
            {
              type = "de";
              key = "{#separator}│  {#keys}󰧨 DE";
            }
            {
              type = "wm";
              key = "{#separator}│  {#keys}󱂬 WM";
            }
            {
              type = "wmtheme";
              key = "{#separator}│  {#keys}󰉼 Theme";
            }
            {
              type = "display";
              key = "{#separator}│  {#keys}󰹑 Resolution";
            }
            {
              type = "shell";
              key = "{#separator}│  {#keys}󰞷 Shell";
            }
            {
              type = "terminalfont";
              key = "{#separator}│  {#keys}󰛖 Font";
            }
            {
              type = "icons";
              key = "{#separator}│  {#keys} Icons";
            }
            {
              type = "cursor";
              key = "{#separator}│  {#keys}󰆽 Cursor";
            }
            {
              type = "custom";
              format = "{#1}│";
            }

            # Hardware Information
            {
              type = "custom";
              format = "{#1}│ {#}Hardware Information";
            }
            {
              type = "board";
              key = "{#separator}│  {#keys} Board";
            }
            {
              type = "cpu";
              key = "{#separator}│  {#keys}󰻠 CPU";
            }
            {
              type = "gpu";
              key = "{#separator}│  {#keys}󰢮 GPU";
            }
            {
              type = "memory";
              key = "{#separator}│  {#keys}󰍛 Memory";
            }
            # {
            #   type = "disk";
            #   key = "{#separator}│  {#keys}󰋊 Disk (/)";
            #   folders = "/";
            # }
            # {
            #   type = "disk";
            #   key = "{#separator}│  {#keys}󰋊 Disk (~/Games)";
            #   folders = "/home/christoph/Games";
            # }
            {
              type = "btrfs";
              key = "{#separator}│  {#keys}󰋊 BTRFS";
            }
            {
              type = "custom";
              format = "{#1}│";
            }

            # Colors Footer
            {
              type = "colors";
              key = "{#separator}╰─── {#1}";
              keyWidth = 6;
              symbol = "circle";
            }
          ];
        };
      };

      fd.enable = true;

      fzf = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      navi = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            forwardAgent = false;
            addKeysToAgent = "yes";
            compression = true;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };
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
          "mars" = {
            user = "smchurla";
            hostname = "mars.cs.tu-dortmund.de";
            serverAliveInterval = 60;
            localForwards = [
              {
                # Resultbrowser
                bind.port = 22941;
                host.address = "127.0.0.1";
                host.port = 22941;
              }
              {
                # Mysql
                bind.port = 3306;
                host.address = "127.0.0.1";
                host.port = 3306;
              }
            ];
          };
        };
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

      yt-dlp.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };
    };

    services = {
    };
  };
}
