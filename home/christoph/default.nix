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
    # inputs.hyprland.homeManagerModules.default # NOTE: Use System module, this one doesn't (can't) add the SDDM entry
  ];

  modules = {
    # Config my modules
    emacs = {
      enable = true;
      pgtkNativeComp = false;
      nativeComp = false;
      nixpkgs = true;

      doom.enable = true;
      doom.autoSync = true;
      doom.autoUpgrade = false; # Very volatile as the upgrade fails sometimes with bleeding edge emacs
    };

    email = {
      enable = true;
      autosync = true;
      imapnotify = false;

      # Use kmail as viewer for stuff synced by mbsync
      kmail = {
        enable = true;
        autostart = true;
      };
    };

    firefox = {
      enable = true;
      wayland = true;
      vaapi = false; # TODO: Crashes AMDGPU driver
      disableTabBar = true;
      defaultBookmarks = true;
      gnomeTheme = true; # I like it also with Plasma
    };

    fish.enable = true;

    flatpak = {
      enable = true;
      autoUpdate = true;
      autoPrune = true;

      flatseal.enable = true;
      discord.enable = false;
      spotify.enable = false;
      bottles.enable = true;
    };

    gnome = {
      enable = false;
      extensions = true;

      theme = {
        papirusIcons = true;
        numixCursor = true;
      };

      settings = {
      };
    };

    # TODO:
    # plasma = {
    #   enable = false;
    # };

    # hyprland = {
    #   enable = true;
    # };

    # TODO: More options, like font?
    kitty.enable = true;

    misc = {
      enable = true;

      keepass = {
        enable = true;
        autostart = true;
      };

      protonmail = {
        enable = true;
        autostart = true;
      };
    };

    # neovim = {
    #   enable = true;
    #   alias = true;
    # };

    nextcloud = {
      enable = true;
      autostart = true;
    };

    ranger = {
      enable = true;
      preview = true;
    };
  };

  manual.manpages.enable = true;
  manual.html.enable = true;

  # TODO: Gnome terminal config
  # TODO: Store the external binaries for my derivations in GitHub LFS (Vital, NeuralDSP, other plugins etc.)
  # TODO: Derivations for bottles like UPlay, NeuralDSP, LoL (don't know what is possible with bottles-cli though)
  # TODO: When bottles derivations are there remove the bottles option from audio/gaming module and assert that bottles is enabled in flatpak module

  # TODO: Remove Plasma, only use Hyprland
  # TODO: I need to pack all Plasma/Hyprland/Gnome related stuff into their respective modules
  # TODO: Then it should only be possible to activate one Desktop at a time

  home.file.".config/hypr/polkit.conf".text = ''exec-once = ${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-agent-1 &'';

  # Make fonts installed through user packages available to applications
  # NOTE: I don't think I need this anymore as all fonts are installed through the system config but let's keep this just in case
  fonts.fontconfig.enable = false; # Also updates the font-cache

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

  # TODO: Hyprland Module
  # TODO: Move Hyprland config to NixFlake/config/hyprland and link from here

  # TODO: Latex module
  home.file."texmf/tex/latex/custom/christex.sty".source = ../../config/latex/christex.sty;
  home.file."Notes/Obsidian/Chriphost/christex.sty".source = ../../config/latex/christex.sty; # For obsidian notes
  home.file.".indentconfig.yaml".source = ../../config/latex/.indentconfig.yaml;
  home.file.".indentsettings.yaml".source = ../../config/latex/.indentsettings.yaml;

  # TODO: If navi enabled
  # TODO: Symlink this, so the config doesn't have to be rebuilt every time
  home.file.".local/share/navi/cheats/christoph.cheat".source = ../../config/navi/christoph.cheat;

  # TODO: Autostart module that is used by Mail/Plasma/Audio etc.
  # TODO: If kde plasma enabled
  home.file.".config/autostart/krunner.desktop".source = ../../config/autostart/krunner.desktop;

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

      DOCKER_BUILDKIT = 1;

      # Enable wayland
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";

      # Don't use system wine, use bottles
      # WINEESYNC = 1;
      # WINEFSYNC = 1;
      # WINEPREFIX = "/home/christoph/.wine";

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module
    };

    # Do not change
    stateVersion = "22.05";
  };

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
    procs # Better ps
    tokei # Text file statistics in a project
    rsync # cp on steroids
    rclone # Rsync for cloud
    poppler_utils # pdfunite
    # ffmpeg # Convert video (magic), v4
    ffmpeg_5-full # v5, including ffplay
    imagemagick # Convert image (magic)
    httpie # Cool http client
    (ripgrep.override {withPCRE2 = true;}) # fast as fuck
    nvd # nix rebuild diff
    # du-dust # Disk usage analyzer (for directories)
    gdu # Alternative to du-dust (I like it better)
    duf # Disk usage analyzer (for all disk overview)
    fd # find alternative
    sd # sed alternative
    tealdeer # very fast tldr (so readable man)
    gping # ping with graph
    # gtop # graphic top # We have btop already...
    curlie # curl a'la httpie
    wget # download that shit
    dogdns # dns client
    fclones # duplicate file finder
    gum # nice shell scripts
    lazygit # can always use another git client
    gitbatch # overview over multiple repos
    mprocs # run multiple processes in single terminal window, screen alternative
    # TODO: Maybe general document/typesetting module?
    graphviz # generate graphs from code
    xdot # .dot file viewer
    d2 # generate diagrams from code
    plantuml
    gnuplot # generate function plots
    # TODO: Latex module
    # tikzit
    texlive.combined.scheme-full
    pandoc # document converting madness
    # TODO: Programming languages module
    alejandra # nix code formatter
    nil # nix language server

    # Xooooorg/Desktop environment stuff
    xclip
    xorg.xwininfo # See what apps run in XWayland
    xdotool
    libnotify

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

    # Web stuff
    signal-desktop
    element-desktop # matrix client
    protonvpn-cli
    # yt-dlp # download videos (from almost anywhere) # HM program
    filezilla

    # Tools
    calibre # Do I even read
    virt-manager
    gource # Visualize git commit log, completely useless
    anki-bin # Use anki-bin as anki is some versions behind
    inputs.nixos-conf-editor.packages."x86_64-linux".nixos-conf-editor
    octave # GNU matlab basically
    logisim-evolution # Digital circuit simulator
    digital # Digital circuit simulator
    quartus-prime-lite # Intel FPGA design software

    # TODO: Module, sync config, try globally
    jetbrains.clion

    # Office
    # sioyek # Scientific pdf reader # HM program
    xournalpp # Write with a pen
    libreoffice-qt
    hunspell # I cna't type
    hunspellDicts.en_US
    hunspellDicts.de_DE
    obsidian # knowledge-base
    logseq # knowledge-base
    # zotero # Citation/source research assistant
    # jabref # manage bibilography # NOTE: Uses jdk18 which is EOL, so can't build, use flatpak instead
    vale # Why not lint everything (including english)?

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
    # jetbrains.clion

    # TODO: LaTeX module
    # texlab # Incredibly lag

    # Media
    wacomtablet
    # blender
    godot
    obs-studio
    vlc # Addition to mpv without any shaders etc
    kdenlive
    krita
    inkscape

    AusweisApp2

    # KDE Applications
    # TODO: Make a module out of this
    libsForQt5.kate
    libsForQt5.kwrited # Already included by default
    libsForQt5.ark
    # libsForQt5.kdeconnect-kde # NOTE: Also has HM service
    libsForQt5.kcalc
    libsForQt5.ksystemlog
    libsForQt5.kfind
    libsForQt5.discover
    libsForQt5.filelight # Drive file size stats
    libsForQt5.kcolorpicker
    libsForQt5.kgpg
    libsForQt5.kparts # Partition manager
    libsForQt5.kcharselect
    libsForQt5.kompare # Can't be used as git merge tool, but more integrated than kdiff3
    libsForQt5.skanlite
    libsForQt5.kmail
    libsForQt5.kalendar
    okteta
    kdiff3
    kgraphviewer
    kbibtex

    # Use NixCommunity binary cache
    cachix

    # TODO: Module
    # Hyprland stuff
    # dunst # NOTE: Use HM service
    libsForQt5.polkit-kde-agent # No idea if that comes with KDE
    slurp # Region selector for screensharing
    # rofi-wayland # App launcher # NOTE: Use HM Program
    webcord # Unshitted discord? Well, except Krisp of course
    ncspot # Spotify in cool (but slow)?
  ];

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    # Potential future enables
    # mangohud.enable = true;
    # matplotlib.enable = true;

    bat.enable = true;
    btop.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # TODO: Configure this
    # editorconfig.enable = true;

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

    # Modal texteditor
    helix = {
      enable = true;

      languages = [
        {
          name = "verilog";
          roots = [
            ".svls.toml"
            ".svlint.toml"
          ];
          language-server = {
            command = "svls";
            args = [];
          };
        }
      ];

      # https://docs.helix-editor.com/configuration.html
      settings = {
        # theme = "base16_terminal";
        editor = {
          scrolloff = 10;
          mouse = false; # Default true
          middle-click-paste = false; # Default true
          line-number = "relative";
          cursorline = true;
          auto-completion = true; # Default
          bufferline = "multiple";
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          lsp.display-messages = true;
          indent-guides.render = false;
        };
      };
    };

    # kakoune = {
    #   enable = true;
    # };

    # NOTE: If error occurs after system update on fish init run "ssh-add"
    keychain = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
      enableNushellIntegration = false;
      enableXsessionIntegration = true;
      agents = ["ssh"];
      keys = ["id_ed25519"];
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

    # NOTE: For Hyprland -> Enable from hyprland module
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = [
        pkgs.keepmenu # Rofi KeepassXC frontend
      ];
      terminal = "${pkgs.kitty}/bin/kitty";

      font = "JetBrains Mono 14";
      # theme = 
      # extraConfig = '''';
    };

    # Git status replacement with file selection by number
    scmpuff = {
      enable = true;
      enableFishIntegration = true;
    };

    # Scientific pdf reader
    sioyek = {
      enable = true;
      # bindings = {};
      # config = {};
    };

    ssh.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };

    # TODO: Module
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        alefragnani.bookmarks
        alefragnani.project-manager
        bradlc.vscode-tailwindcss
        christian-kohler.path-intellisense
        codezombiech.gitignore
        # coenraads.bracket-pair-colorizer-2 # Not maintained
        coolbear.systemd-unit-file
        eamodio.gitlens
        formulahendry.auto-rename-tag
        formulahendry.auto-close-tag
        gitlab.gitlab-workflow
        irongeek.vscode-env
        jnoortheen.nix-ide
        kamadorueda.alejandra
        kamikillerto.vscode-colorize
        llvm-vs-code-extensions.vscode-clangd
        matklad.rust-analyzer
        mechatroner.rainbow-csv
        mikestead.dotenv
        mkhl.direnv
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        # ms-python.python # TODO: Reenable, was disabled bc build failure
        ms-toolsai.jupyter
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-vscode.hexeditor
        ms-vscode.makefile-tools
        naumovs.color-highlight
        njpwerner.autodocstring
        # oderwat.indent-rainbow # Looks ugly
        james-yu.latex-workshop
        redhat.java
        redhat.vscode-xml
        redhat.vscode-yaml
        rubymaniac.vscode-paste-and-indent
        ryu1kn.partial-diff
        serayuzgur.crates
        shd101wyy.markdown-preview-enhanced
        skyapps.fish-vscode
        tamasfe.even-better-toml
        timonwong.shellcheck
        # tomoki1207.pdf # Incompatible with latex workshop
        valentjn.vscode-ltex
        vscodevim.vim
        vscode-icons-team.vscode-icons
        yzhang.markdown-all-in-one
      ];
      # haskell = {};
      # keybindings = {};
      userSettings = {
        "files.autoSave" = "onFocusChange";
        "editor.fontSize" = 14;
        "editor.fontFamily" = "Victor Mono Semibold";
        "editor.renderWhitespace" = "selection";
        "editor.cursorStyle" = "line";
        "editor.lineNumbers" = "relative";
        "editor.linkedEditing" = true;
        "editor.smoothScrolling" = true;
        "editor.stickyScroll.enabled" = true;
        "editor.tabCompletion" = "on";
        "editor.cursorSmoothCaretAnimation" = true;
        "editor.cursorSurroundingLines" = 10;
        "editor.minimap.renderCharacters" = false;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true; # NOTE: If this is enabled with frequent autosave, the current lines whitespace will always be removed, which is obnoxious
        "workbench.enableExperiments" = false;
        "workbench.list.smoothScrolling" = true;
        "workbench.colorTheme" = "Default Light+";
        "workbench.iconTheme" = "vscode-icons";
        "security.workspace.trust.enabled" = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.guides.bracketPairsHorizontal" = "active";
        "editor.guides.highlightActiveIndentation" = false;
        "ltex.checkFrequency" = "manual";
        # Looks ugly
        # "workbench.colorCustomizations" = {
        #   # Bracket colors
        #   "editorBracketHighlight.foreground1" = "#FFD700";
        #   "editorBracketHighlight.foreground2" = "#DA70D6";
        #   "editorBracketHighlight.foreground3" = "#179fff";
        #   # Inactive guide colors
        #   "editorBracketPairGuide.background1" = "#ffd90080";
        #   "editorBracketPairGuide.background2" = "#CC66CC80";
        #   "editorBracketPairGuide.background3" = "#87CEFA80";
        #   # Active guide colors
        #   "editorBracketPairGuide.activeBackground1" = "#ffd90080";
        #   "editorBracketPairGuide.activeBackground2" = "#CC66CC80";
        #   "editorBracketPairGuide.activeBackground3" = "#87CEFA80";
        # };
        "latex-workshop.latex.tools" = [
          {
            "name" = "latexmk";
            "command" = "latexmk";
            "args" = [
              "-synctex=1"
              "-shell-escape"
              "-interaction=nonstopmode"
              "-file-line-error"
              "-pdf"
              "-outdir=%OUTDIR%"
              "%DOC%"
            ];
            "env" = {};
          }
        ];
        "latex-workshop.latexindent.args" = [
          "-c"
          "%DIR%/"
          "%TMPFILE%"
          "-m"
          "-y=defaultIndent: '%INDENT%'"
        ];
        "[nix]"."editor.tabSize" = 2;
      };
      # TODO: Snippets
    };

    # TODO: Belongs to hyprland module
    waybar = {
      enable = true;
      systemd = {
        enable = false;
      };

      # settings = {};
      # style = '''';
    };

    # TODO: Check HM module options
    yt-dlp.enable = true;

    zoxide = {
      enable = true;
      enableFishIntegration = config.modules.fish.enable;
    };
  };

  services = {
    # kdeconnect.enable = true; # Note: This does not setup the firewall at all

    # TODO: To hyprland module
    dunst = {
      enable = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
