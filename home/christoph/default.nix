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
    # Config my modules
    emacs = {
      enable = false;
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
      gnomeTheme = true; # I like it also with Plasma
    };

    fish.enable = true;

    flatpak = {
      enable = true;
      autoUpdate = true;
      autoPrune = true;
      fontFix = false;
      iconFix = false;

      flatseal.enable = true;
      discord.enable = true;
      spotify.enable = true;
      bottles.enable = false;
      obsidian.enable = true;
      jabref.enable = true;
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

    hyprland = {
      enable = true;
      theme = "Three-Bears";

      # TODO:
      # papirusIcons = true;
      # bibataCursor = true;
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
        autostart = false;
      };

      protonmail = {
        enable = true;
        autostart = false;
      };
    };

    # neovim = {
    #   enable = true;
    #   alias = true;
    # };

    nextcloud = {
      enable = true;
      autostart = false;
    };

    plasma = {
      enable = false;
    };

    ranger = {
      enable = false;
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

  # TODO: NNN module
  xdg.desktopEntries.nnn = {
    type = "Application";
    name = "nnn";
    comment = "Terminal file manager";
    exec = "nnn";
    terminal = true;
    icon = "nnn";
    mimeType = ["inode/directory"];
    categories = ["System" "FileTools" "FileManager" "ConsoleOnly"];
    # keywords = ["File" "Manager" "Management" "Explorer" "Launcher"];
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
      TERMINAL = "kitty";
      BROWSER = "firefox";

      DOCKER_BUILDKIT = 1;

      # Enable wayland
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      NIXOS_OZONE_WL = "1";
      SDL_VIDEODRIVER = "wayland";

      # TODO: NNN Module
      # NNN_FIFO = "/tmp/nnn.fifo"; # For nnn preview

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
    dnsmasq # For Access Point/Hotspot
    linux-wifi-hotspot
    nzbget
    spotdl-4_1_6

    # Tools
    # calibre # Do I even read
    virt-manager
    # gource # Visualize git commit log, completely useless
    anki-bin # Use anki-bin as anki is some versions behind
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
    # obsidian # knowledge-base # Use flatpak for now, as I can't use window splitting with this version for some reason
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
    jetbrains.clion

    # Media
    wacomtablet
    blender
    godot
    obs-studio
    # vlc # Addition to mpv without any shaders etc
    kdenlive
    krita
    inkscape
    handbrake
    makemkv

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

    # Potential future enables
    # mangohud.enable = true;
    # matplotlib.enable = true;

    bat.enable = true;

    broot = {
      enable = true;
      enableFishIntegration = true;
    };

    btop.enable = true;

    chromium = {
      enable = true;

      # TODO: Extensions for ungoogled, see https://discourse.nixos.org/t/home-manager-ungoogled-chromium-with-extensions/15214
      # package = pkgs.ungoogled-chromium;

      extensions = [
        {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # UBlock Origin
        {id = "oboonakemofpalcgghocfoadofidjkkk";} # KeepassXC Browser
        {id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";} # Privacy Badger
        {id = "lckanjgmijmafbedllaakclkaicjfmnk";} # ClearURLs
        {id = "njdfdhgcmkocbgbhcioffdbicglldapd";} # LocalCDN
        {id = "jaoafjdoijdconemdmodhbfpianehlon";} # Skip Redirect
      ];
    };

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

    nnn = {
      package = pkgs.nnn.override {withNerdIcons = true;};
      enable = true;

      extraPackages = with pkgs; [
        xdragon # Drag and drop (why man)
      ];

      bookmarks = {
        c = "~/.config";
        d = "~/Documents";
        D = "~/Downloads";
        n = "~/Notes";
        t = "~/Notes/TU";
        h = "~/Notes/HHU";
        N = "~/NixFlake";
        p = "~/Pictures";
        v = "~/Videos";
      };

      plugins = {
        mappings = {
          c = "fzcd";
          d = "dragdrop";
          f = "finder";
          j = "autojump";
          k = "kdeconnect";
          p = "preview-tui";
          # s = "suedit";
          # s = "x2sel";
          v = "imgview";
        };

        src =
          (pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "nnn";
            rev = "6a8d74a43a2135a186dc59c5a1f561444ca098e4";
            sha256 = "sha256-jxPfaHRPWy1L87YkK1G/9cBgUwjyJyPXM2jG4VE4+kQ=";
          })
          + "/plugins";
      };
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
        ms-python.python # TODO: Reenable, was disabled bc build failure
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

    # TODO: Check HM module options
    yt-dlp.enable = true;

    # TODO
    zathura = {
      enable = true;
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
