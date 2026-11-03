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

  # Qt 6 on Wayland draws the tray menu as an xdg_popup: the menu ends up in
  # the wrong place and the tray tooltip ("Account synchronization is
  # disabled") is rendered as a second floating window on top of it. Force only
  # this app onto XWayland (niri runs xwayland-satellite), where the menu is a
  # plain override-redirect window again.
  nextcloud-client-xcb = pkgs.symlinkJoin {
    name = "nextcloud-client-xcb-${pkgs.nextcloud-client.version}";
    paths = [pkgs.nextcloud-client];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/nextcloud --set QT_QPA_PLATFORM xcb
    '';
  };
in {
  options.homemodules.packages = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf packages.enable {
    # State of the applications installed below
    homemodules.impermanence.directories = [
      ".cache/keepassxc"
      ".cache/nix"
      ".cache/nix-index"
      ".cache/nix-search-tv"
      ".config/LM Studio"
      ".config/Nextcloud"
      ".config/Signal"
      ".config/Vector 35" # binaryninja-free
      ".config/Zeal"
      ".config/feishin"
      ".config/keepassxc"
      ".config/obsidian"
      ".config/vlc"
      ".lmstudio"
      ".local/share/Anki2"
      ".local/share/Nextcloud"
      ".local/share/direnv"
      ".local/share/org.localsend.localsend_app"
      ".local/share/zoxide"
      ".nix-package-search"
      ".tableplus"
    ];

    # TODO: Add extra packages option and use that from host-specific configs
    home.packages = with pkgs;
      lib.mkMerge [
        # Common packages
        [
          # Shell utils
          (ripgrep.override {withPCRE2 = true;}) # fast as fuck
          gdu # Disk usage analyzer
          duf # Total disk usage viewer (for all disk overview)
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
          ttyper # Typing test
          wiki-tui # Wikipedia

          # Nix
          nix-search-tv # Search nixpkgs, nur, nixos options and homemanager options
          nix-tree # Browse the nix store sorted by size (gdu for closures)

          # TODO: Still broken on 2026-09-09
          inputs.nps.packages.${pkgs.stdenv.hostPlatform.system}.default # Search nixpkgs

          # Video/Image/Audio utils
          ffmpeg-normalize # Normalize audio
          ffmpeg-full # I love ffmpeg

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
          bandwhich # Network utilization
          snitch # Better netstat
          nmap
          # speedtest-cli
        ]

        # Common !headless packages
        (lib.optionals (!headless) [
          ripdrag # drag & drop from terminal
          # jellyfin-tui # Use module

          inputs.masssprings.packages.${stdenv.hostPlatform.system}.default # TODO: Broken 2026-10-03 (tracy)
        ])

        # Linux exclusive packages
        (lib.optionals (pkgs.stdenv.hostPlatform.isLinux) [
          # Use NixCommunity binary cache
          cachix

          pastel # Color tools
          nvd # Nix rebuild diff
          nurl # Generate nix fetcher sections based on URLs
          lazyjournal # Journalctl viewer
          systemctl-tui
          restic # Backups
          gnumake
          just # make alternative
          binsider # .elf analyzer
          jujutsu # git-like vcs
          lurk # strace analysis
          radare2 # disassembly analyzer
          disktui
          lldb
          inotify-tools
          xdotool
          gnome-keyring
          superfile # File manager

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
        (lib.optionals (pkgs.stdenv.hostPlatform.isLinux && (!headless)) [
          wl-clipboard
          asciicam

          # Proton
          proton-vpn
          protonmail-bridge-gui # TODO: Set this up for thunderbird (email module)

          # GUI stuff
          signal-desktop
          anki
          nextcloud-client-xcb
          keepassxc
          thunderbird # TODO: Email module
          obsidian
          zeal # docs browser
          # zotero # NOTE: Depends on firefox version no longer in nixpkgs. Use flatpak
          vlc
          # audacity # NOTE: Broken on 2026-10-23
          # ferdium
          feishin # electron :(
          playerctl # Media player control
          czkawka-full # file deduplicator
          binaryninja-free # reverse engineering
          raddbg # RAD debugger (custom derivation)
          tableplus # database explorer
          # claude-desktop
          lmstudio # TODO: Ollama
          opencode-desktop
          upscayl
          # calibre # Sometimes I need to convert ebooks
          vcv-rack
          # gajim # XMPP client
          # bitwig-studio5 # My license doesn't cover this version :/
          localsend

          # Office
          xournalpp # Write with a pen, like old people
          hunspell # I cna't type
          hunspellDicts.en_US
          hunspellDicts.de_DE

          # kdePackages.wacomtablet # NOTE: Deprecated, only works on X11

          # GTK-Apps because I hate nice software
          # gnome-calculator
          # gnome-calendar
          # helvum # unmaintained
          crosspipe
          # nautilus # This is the worst file manager I've ever used
          font-manager # Previews fonts, but doesn't set them
          gparted
          resources
          # celluloid
          # cine
          # eyedropper
          hyprpicker
          junction
          footage
        ])

        # Darwin exclusive packages
        (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          # Use homebrew instead
          # alt-tab-macos
          # discord
          # obsidian
          # nextcloud-client
          # proton-vpn
          # iina

          # TODO: Update the docs module to be darwinix compatible
          #       - The filepaths need to be adapted
          texliveFull
          typst
        ])
      ];

    programs = {
      # The home-manager management tool.
      # Will only be enabled if HM is installed standalone.
      home-manager.enable = true;

      direnv = {
        enable = true;
        enableFishIntegration = true;
        silent = true;
        nix-direnv.enable = true;
      };

      # This replaces the normal direnv.enableFishIntegration.
      # direnv-instant = {
      #   enable = true;
      #   enableFishIntegration = true;
      #   enableKittyIntegration = true;
      #   settings.use_cache = true;
      # };

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

    # Obsidian (Electron) can fail to start (gray window) when an old V8 "Code Cache"
    # entry from an older Electron/Obsidian version is reused. Drop it on version change
    home.activation.obsidianClearStaleCodeCache = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && (!headless)) (
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        obsidianConfig="${config.home.homeDirectory}/.config/obsidian"
        marker="$obsidianConfig/.nix-codecache-version"
        current="${pkgs.electron.version}-${pkgs.obsidian.version}"

        if [ -d "$obsidianConfig" ] && [ "$(cat "$marker" 2>/dev/null)" != "$current" ]; then
          run rm -rf "$obsidianConfig/Code Cache"
          printf '%s' "$current" > "$marker"
        fi
      ''
    );
  };
}
