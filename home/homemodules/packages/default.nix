{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  headless,
  inputs,
  ...
}: let
  inherit (config.homemodules) packages color;
in {
  options.homemodules.packages = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf packages.enable {
    home.packages = with pkgs;
      lib.mkMerge [
        # Common packages
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
          exiftool
          ouch # Unified compression/decompression
          ffmpegthumbnailer # Video thumbnails
          mediainfo # Media meta information
          file # File meta information
          unrar # Cooler WinRar
          p7zip # Zip stuff
          unzip # Unzip stuff
          progress # Find coreutils processes and show their progress
          tokei # Text file statistics in a project

          # Nix
          nix-search-tv # Search nixpkgs, nur, nixos options and homemanager options
          nix-tree # Browse the nix store sorted by size (gdu for closures)
          inputs.nps.packages.${pkgs.stdenv.hostPlatform.system}.default # Search nixpkgs

          # Video/Image/Audio utils
          ffmpeg-full # I love ffmpeg (including ffplay)
          ffmpeg-normalize # Normalize audio

          # Document utils
          poppler-utils # pdfunite
          pdf2svg # extract vector graphics from pdf
          pandoc # document converting madness

          # Networking
          dig # Make DNS requests
          tcpdump # Listen in on TCP traffic
          gping # ping with graph
          curlie # curl a'la httpie
          wget # download that shit
          doggo # dns client
          rsync # cp on steroids
          rclone # Rsync for cloud
          httpie # Cool http client
          speedtest-cli

          # Use NixCommunity binary cache
          cachix
        ]

        # Common !headless packages
        (lib.optionals (!headless) [
          ripdrag # drag & drop from terminal
          jellyfin-tui
        ])

        # Linux exclusive packages
        (lib.optionals (pkgs.stdenv.isLinux) [
          pastel # Color tools
          nvd # Nix rebuild diff
          nurl # Generate nix fetcher sections based on URLs
          python313 # Nicer scripting than bash
          lazyjournal # Journalctl viewer
          systemctl-tui
          restic # Backups
          gnumake
          just # make alternative
          binsider # .elf analyzer
          jujutsu # git-like vcs
          lurk # strace analysis
          radare2

          # Hardware/Software info
          pciutils # lspci
          mesa-demos # OpenGL info
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
          imagemagick # Convert image (magic)
          mp3val # Validate mp3 files
          flac # Validate flac files

          # Document utils
          graphviz # generate graphs from code
          d2 # generate diagrams from code
          plantuml # generate diagrams
          gnuplot # generate function plots

          # Networking
          traceroute # "Follow" a packet
          cifs-utils # Mount samba shares
          nfs-utils # Mount NFS shares
          sshfs # Mount remote directories via SSH

          # Run unpatched binaries on NixOS
          # Sets NIX_LD_LIBRARY_PATH and NIX_LD variables for nix-ld.
          # Usage: "nix-alien-ld -- <Executable>".
          inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien
        ])

        # Linux exclusive packages (!headless)
        (lib.optionals (pkgs.stdenv.isLinux && (!headless)) [
          veracrypt
          wl-clipboard

          # Proton
          protonvpn-gui
          protonmail-bridge-gui

          # GUI stuff
          nautilus # Just in case
          signal-desktop
          anki
          font-manager # Previews fonts, but doesn't set them
          nextcloud-client
          keepassxc
          thunderbird # TODO: Email module
          obsidian
          zotero
          zeal # docs browser
          # helvum # unmaintained
          crosspipe
          vlc
          audacity
          ferdium
          gparted
          # feishin # electron :(
          jellyfin-tui
          playerctl # Media player control
          czkawka-full # file deduplicator

          # Office
          kdePackages.wacomtablet # For xournalpp/krita
          xournalpp # Write with a pen, like old people
          hunspell # I cna't type
          hunspellDicts.en_US
          hunspellDicts.de_DE

          inputs.masssprings.packages.${stdenv.hostPlatform.system}.default
        ])

        # Darwin exclusive packages
        (lib.optionals pkgs.stdenv.isDarwin [
          # Use homebrew instead
          # alt-tab-macos
          # discord
          # obsidian
          # nextcloud-client
          # protonvpn-gui
          # iina
        ])
      ];

    programs = {
      # The home-manager management tool.
      # Will only be enabled if HM is installed standalone.
      home-manager.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      eza = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
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

      yt-dlp.enable = true;

      zoxide = {
        enable = true;
        enableFishIntegration = config.homemodules.fish.enable;
      };
    };
  };
}
