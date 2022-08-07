# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, nixosConfig, pkgs, ... }:

rec {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors), use something like:
    # inputs.nix-colors.homeManagerModule

    # Feel free to split up your configuration and import pieces of it here.

    ./modules/emacs.nix

    # inputs.nixvim.homeManagerModules.nixvim
  ];

  # Config my modules
  # TODO: Emacs autosync on rebuild?
  modules = {
    emacs.enable = true;
    emacs.useDoom = true;
  };

  # TODO: Email
  # TODO: Run noisetorch as login script
  # TODO: Gnome terminal config

  # TODO: Update flatpak on rebuild? Make a setting/module for this, emacs update and yabridgectl update... Use home.activation...
  home.activation.syncDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${home.homeDirectory}/.emacs.d/bin/doom sync
  '';
  home.activation.syncYabridge = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    yabridgectl sync
  '';

  # Disabled since HomeManager should use global pkgs
  # https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfreePredicate = (pkg: true);
  # nixpkgs.config.allowUnfree = true;

  # Chinese Input
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-gtk
    libsForQt5.fcitx5-qt
    fcitx5-chinese-addons
    fcitx5-configtool # TODO: Remove this and set config through HomeManager
  ];

  # Make fonts installed through user packages available to applications
  # NOTE: I don't think I need this anymore as all fonts are installed through the system config but let's keep this just in case
  fonts.fontconfig.enable = true; # Also updates the font-cache

  # Make fonts available to flatpak apps, we link the fontdir to $XDG_DATA_DIR/fonts and allow access
  # home.file.".local/share/fonts" = {
  #   recursive = true;
  #   source = /run/current-system/sw/share/X11/fonts; # We cannot use the absolute path
  # };
  # We link like this to be able to address the absolute location, also the fonts won't get copied to store, also icons
  home.activation.linkFontDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -L "${home.homeDirectory}/.local/share/fonts" ]; then
      ln -sf /run/current-system/sw/share/X11/fonts ${home.homeDirectory}/.local/share/fonts
    fi
    if [ ! -L "${home.homeDirectory}/.local/share/icons" ]; then
      ln -sf /run/current-system/sw/share/icons ${home.homeDirectory}/.local/share/icons
    fi
  '';
  home.file.".local/share/flatpak/overrides/global".text = ''
    [Context]
    filesystems=/run/current-system/sw/share/X11/fonts:ro;/run/current-system/sw/share/icons:ro;/nix/store:ro
  '';

  # TODO: Move to gaming modules
  home.file.".local/share/flatpak/overrides/com.valvesoftware.Steam".text = ''
    [Context]
    filesystems=${home.homeDirectory}/GameSSD;${home.homeDirectory}/GameHDD
  '';
  home.file.".local/share/flatpak/overrides/com.usebottles.bottles".text = ''
    [Context]
    filesystems=${home.homeDirectory}/.var/app/com.valvesoftware.Steam/data/Steam;${home.homeDirectory}/Downloads;${home.homeDirectory}/GameSSD;${home.homeDirectory}/GameHDD
  '';

  # Generate a list of installed user packages in /etc/current-user-packages
  home.file.".local/share/current-user-packages".text =
    let
      packages = builtins.map (p: "${p.name}") home.packages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;

  # TODO: Make to a derivation with makeDesktopIcon and add to music module
  # Doesn't work
  # home.file.".local/share/applications/carla-guitar-amp.desktop".text = ''
  #   [Desktop Entry]
  #   Type=Application
  #   Exec=PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${home.homeDirectory}/Documents/Carla/GuitarDefault.carxp
  #   Terminal=false
  #   Name=Carla Guitar Amp
  #   Icon=carla
  #   Comment=Play through NeuralDSP Gojira and Petrucci
  #   GenericName=Guitar Amp Simulation
  #   Categories=Music;Audio;
  # '';

  # TODO: Module
  gtk = {
    enable = true;

    # I guess this gets set by home.pointerCursor
    # cursorTheme.package = pkgs.numix-cursor-theme;
    # cursorTheme.name = "Numix-Cursor";

    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus";

    # theme.package = pkgs.whitesur-gtk-theme;
    # theme.name = "WhiteSur-light-solid";
  };

  home = {
    username = "christoph";
    homeDirectory = "/home/${home.username}";
    enableNixpkgsReleaseCheck = true;

    # TODO: There are many more home.* options

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";

      XDG_DATA_DIRS =
        "/var/lib/flatpak/exports/share:/home/christoph/.local/share/flatpak/exports/share:$XDG_DATA_DIRS";
      DOCKER_BUILDKIT = 1;

      # Enable wayland for other shitty apps
      MOZ_ENABLE_WAYLAND = 1;
      MOZ_USE_XINPUT2 = 1;
      QT_QPA_PLATFORM = "wayland";
      LIBVA_DRIVER_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = 1;
      EGL_PLATFORM = "wayland";

      # Don't use system wine, use bottles
      # WINEESYNC = 1;
      # WINEFSYNC = 1;
      # WINEPREFIX = "/home/christoph/.wine";

      # NOTE: GTK_IM_MODULE, QT_IM_MODULE, XMODIFIERS are set by HomeManager fcitx5 module

      # TODO: Investigate if this also slows down Gnome login
      # GTK_USE_PORTAL = 1;

    };

    # sessionPath = [];

    pointerCursor.package = pkgs.numix-cursor-theme;
    pointerCursor.gtk.enable = true;
    pointerCursor.name = "Numix-Cursor";
    pointerCursor.x11.enable = true;

    # Do not change
    stateVersion = "22.05";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Firefox hardware video acceleration
    libva
    libva-utils
    nvidia-vaapi-driver
    vulkan-tools

    # CLI Tools
    procs
    tokei
    rsync
    # rclone
    xclip
    xorg.xwininfo
    xdotool
    poppler_utils # pdfunite
    ffmpeg
    imagemagick
    # htop
    # httpie
    ripgrep
    nvd # nix rebuild diff
    neofetch # Easily see interesting package versions/kernel
    lazygit

    # Some basics should be available everywhere
    # This makes problems with conflicts in nix-store, for example gcc/ld and binutils/ld or different python versions
    # python311
    # gcc # nvim needs this

    # Gnome extensions
    # TODO: Make a gnome module
    # gnome.gnome-tweaks # Disabled since settings should be set declaratively
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.vitals
    gnomeExtensions.no-overview
    # gnomeExtensions.switch-workspace
    gnomeExtensions.maximize-to-empty-workspace
    gnomeExtensions.pip-on-top
    gnomeExtensions.custom-hot-corners-extended
    # gnomeExtensions.dock-from-dash
    gnomeExtensions.gamemode
    # gnomeExtensions.gsconnect # kde connect alternative
    # gnomeExtensions.quake-mode # dropdown for any application
    gnomeExtensions.systemd-manager # to quickly start nextcloud
    gnomeExtensions.extensions-sync
    gnomeExtensions.tweaks-in-system-menu
    # gnomeExtensions.compiz-windows-effect # WobBlY wiNdoWS
    gnomeExtensions.panel-scroll
    gnomeExtensions.rounded-window-corners

    # Gnome applications
    gnome.gnome-boxes
    gnome.sushi # Gnome files previews
    gnome.gnome-logs # systemd log viewer
    gnome.gnome-tweaks # conflicts with nixos/hm gnome settings file
    gnome.gnome-nettool
    gnome.simple-scan
    gnome.file-roller # archive manager
    # gnome-usage # Alternative system performance monitor (gnome.gnome-system-monitor is the preinstalled one)
    # gnome-secrets # Alternative keepass database viewer
    gnome-firmware
    wike # Wikipedia viewer

    # Ranger
    # TODO: Make module out of this
    ranger
    ueberzug
    ffmpegthumbnailer
    atool
    p7zip
    zip
    unzip
    unrar
    libarchive
    exiftool
    mediainfo

    # Web
    signal-desktop
    noisetorch
    # Flatpak discord
    yt-dlp
    # Flatpak spotify
    # thunderbird # Try gnome mail
    protonmail-bridge
    protonvpn-cli

    # Tools
    # calibre
    # virt-manager # Let's try gnome-boxes while we're at it
    gource
    keepassxc
    anki-bin # Use anki-bin as anki is some versions behind
    libreoffice-fresh
    jabref # manage bibilography

    # Graphics
    wacomtablet
    xournalpp
    # kdenlive
    # krita
    # blender
    # godot

    # Audio
    # TODO: Make a module, autosync yabridge on rebuild?
    # vcv-rack
    bitwig-studio
    # audacity
    carla
    yabridge
    yabridgectl
    # (callPackage ../derivations/carla-guitar-amp.nix { inherit home; }) # TODO

    # Use NixCommunity binary cache
    cachix

    # Gaming
    gamemode
    # Flatpak nur.repos.dukzcry.gamescope # We need to install this with flatpak to be able to use with bottles
    # Flatpak bottles
    # Flatpak steam
    # Flatpak proton-ge
    # Flatpak polymc # Use flatpak as it bundles java and I don't have/want system wide java installation
  ];

  # Packages with extra options managed by HomeManager natively
  programs = {
    home-manager.enable = true;

    bat = { enable = true; };

    # Exclusive with nix-index
    # command-not-found.enable = true;

    chromium.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    exa.enable = true;

    # feh.enable = true; # Use gnome apps for now

    fish = {
      enable = true;
      # functions = {};
      # plugins = [];
      shellAbbrs = {
        c = "clear";
        q = "exit";
        h = "history | bat";

        # upgrade = "nix flake update && sudo nixos-rebuild build --flake .#nixinator && nvd diff /run/current-system result";
        # rebuild = "sudo nixos-rebuild switch --flake .#nixinator";
        # rebuildfast = "sudo nixos-rebuild switch --fast --flake .#nixinator";

        failed = "systemctl --failed";
        errors = "journalctl -p 3 -xb";

        cd = "z";
        cp = "cp -i";
        ls =
          "exa --color always --group-directories-first -F --git --icons"; # color-ls
        lsl =
          "exa --color always --group-directories-first -F -l --git --icons";
        lsa =
          "exa --color always --group-directories-first -F -l -a --git --icons";
        tre =
          "exa --color always --group-directories-first -F -T -L 2 ---icons";
        mkd = "mkdir -p";
        blk =
          "lsblk -o NAME,LABEL,UUID,FSTYPE,SIZE,FSUSE%,MOUNTPOINT,MODEL | bat";
        fsm = "df -h | bat";
        grp = "grep --color=auto -E";
        fzp =
          "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        fre = "free -m";

        r =
          "ranger --choosedir=$HOME/.rangerdir; set LASTDIR (cat $HOME/.rangerdir); cd $LASTDIR";
        rsync = "rsync -chavzP --info=progress2";
        performance =
          "sudo cpupower frequency-set -g performance && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=1";
        powersave =
          "sudo cpupower frequency-set -g powersave && nvidia-settings -a [gpu:0]/GPUPowerMizerMode=0";

        wat = "watch -d -c -n -0.5";
        dus = "sudo dust -r";
        dsi = "sudo du -sch . | bat";
        prc = "procs -t";

        emcs = "emacs -nw";

        lg = "lazygit";
        gs = "git status";
        gcm = "git commit -m";
        ga = "git add";
        glg = "git log --graph --decorate --oneline";
        gcl = "git clone";

        xxhamster = "TERM=ansi ssh christoph@217.160.142.51";

        fonts = "fc-list";
        fchar = "fc-match -s";

        vpnat = "protonvpn-cli c --cc at";
        vpnch = "protonvpn-cli c --cc ch";
        vpnlu = "protonvpn-cli c --cc lu";
        vpnus = "protonvpn-cli c --cc us";
        vpnhk = "protonvpn-cli c --cc hk";
        vpnkr = "protonvpn-cli c --cc kr";
        vpnoff = "protonvpn-cli d";

        league = "sudo sysctl -w abi.vsyscall32=0";

        mp4 =
          "yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b' --recode-video mp4"; # the -f options are yt-dlp defaults
        mp3 = "yt-dlp -f 'ba' --extract-audio --audio-format mp3";

        guitar =
          "PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${home.homeDirectory}/Documents/Carla/GuitarDefault.carxp";
      };
      shellAliases = {
        # ".." = "cd ..";
        "please" = "sudo !!";
        "yeet" = "rm -rf";
      };
      # This init only occurs for login shell
      # TODO: Make option for noisetorch activation, doesn't work like this
      # loginShellInit = ''
      #   noisetorch -i
      # '';
      shellInit = ''
        set -e fish_greeting
      '';
      # promptInit = ''
      #   any-nix-shell fish --info-right | source
      # '';
    };

    firefox = {
      enable = true;

      # firefox-unwrapped is the pure firefox browser, wrapFirefox adds configuration ontop
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {

        forceWayland = true;

        # About policies:
        # https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
        extraPolicies = {
          # TODO: Investigate this
          ExtensionSettings = { };

          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
      };

      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        augmented-steam
        betterttv
        bypass-paywalls-clean
        clearurls
        cookie-autodelete
        don-t-fuck-with-paste
        h264ify
        keepassxc-browser
        localcdn
        privacy-badger
        search-by-image
        single-file
        skip-redirect
        sponsorblock
        tab-session-manager
        to-deepl
        transparent-standalone-image
        tree-style-tab
        ublacklist
        ublock-origin
        # umatrix # Many pages need manual intervention
        unpaywall
        view-image
        vimium
      ];

      # TODO:
      profiles = {
        default = {
          id = 0; # 0 is default profile

          settings = {
            "app.update.auto" = false;
            # "browser.startup.homepage" = "https://lobste.rs";
            "identity.fxaccounts.account.device.name" =
              nixosConfig.networking.hostName; # NOTE: nixosConfig attribute is somehow not documented, so Idk if I should use it

            # Firefox wayland hardware video acceleration
            # https://github.com/elFarto/nvidia-vaapi-driver/#firefox=
            "media.ffmpeg.vaapi.enabled" = true;
            "widget.wayland-dmabuf-vaapi.enabled" = true;
            "widget.dmabuf.force-enabled" = true;
            "gfx.webrender.enabled" = true; # Should be set on gnome anyway
            "media.rdd-ffmpeg.enabled" = true;
            "media.av1.enabled" = false;
            "gfx.x11-egl.force-enabled" = true;

            # Enable ETP for decent security (makes firefox containers and many
            # common security/privacy add-ons redundant).
            "browser.contentblocking.category" = "standard";
            "privacy.donottrackheader.enabled" = true;
            "privacy.donottrackheader.value" = 1;
            "privacy.purge_trackers.enabled" = true;
            # Your customized toolbar settings are stored in
            # 'browser.uiCustomization.state'. This tells firefox to sync it between
            # machines. WARNING: This may not work across OSes. Since I use NixOS on
            # all the machines I use Firefox on, this is no concern to me.
            # "services.sync.prefs.sync.browser.uiCustomization.state" = true;
            # Enable userContent.css and userChrome.css for our theme modules
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            # Don't use the built-in password manager. A nixos user is more likely
            # using an external one (you are using one, right?).
            "signon.rememberSignons" = false;
            # Do not check if Firefox is the default browser
            "browser.shell.checkDefaultBrowser" = false;
            # Disable the "new tab page" feature and show a blank tab instead
            # https://wiki.mozilla.org/Privacy/Reviews/New_Tab
            # https://support.mozilla.org/en-US/kb/new-tab-page-show-hide-and-customize-top-sites#w_how-do-i-turn-the-new-tab-page-off
            "browser.newtabpage.enabled" = false;
            "browser.newtab.url" = "about:blank";
            # Disable Activity Stream
            # https://wiki.mozilla.org/Firefox/Activity_Stream
            "browser.newtabpage.activity-stream.enabled" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            # Disable new tab tile ads & preload
            # http://www.thewindowsclub.com/disable-remove-ad-tiles-from-firefox
            # http://forums.mozillazine.org/viewtopic.php?p=13876331#p13876331
            # https://wiki.mozilla.org/Tiles/Technical_Documentation#Ping
            # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-source
            # https://gecko.readthedocs.org/en/latest/browser/browser/DirectoryLinksProvider.html#browser-newtabpage-directory-ping
            "browser.newtabpage.enhanced" = false;
            "browser.newtabpage.introShown" = true;
            "browser.newtab.preload" = false;
            "browser.newtabpage.directory.ping" = "";
            "browser.newtabpage.directory.source" = "data:text/plain,{}";
            # Reduce search engine noise in the urlbar's completion window. The
            # shortcuts and suggestions will still work, but Firefox won't clutter
            # its UI with reminders that they exist.
            # TODO: Somehow not applied? At least it's not represented in settings
            "browser.urlbar.suggest.searches" = true;
            "browser.urlbar.shortcuts.bookmarks" = false;
            "browser.urlbar.shortcuts.history" = true;
            "browser.urlbar.shortcuts.tabs" = false;
            "browser.urlbar.showSearchSuggestionsFirst" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
            # https://bugzilla.mozilla.org/1642623
            "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0;
            # https://blog.mozilla.org/data/2021/09/15/data-and-firefox-suggest/
            "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
            "browser.urlbar.suggest.quicksuggest.sponsored" = false;
            # Show whole URL in address bar
            "browser.urlbar.trimURLs" = false;
            # Disable some not so useful functionality.
            "browser.disableResetPrompt" =
              true; # "Looks like you haven't started Firefox in a while."
            "browser.onboarding.enabled" =
              false; # "New to Firefox? Let's get started!" tour
            "browser.aboutConfig.showWarning" =
              false; # Warning when opening about:config
            "media.videocontrols.picture-in-picture.video-toggle.enabled" =
              true;
            "extensions.pocket.enabled" = false;
            "extensions.shield-recipe-client.enabled" = false;
            "reader.parse-on-load.enabled" = false; # "reader view"

            # Security-oriented defaults
            "security.family_safety.mode" = 0;
            # https://blog.mozilla.org/security/2016/10/18/phasing-out-sha-1-on-the-public-web/
            "security.pki.sha1_enforcement_level" = 1;
            # https://github.com/tlswg/tls13-spec/issues/1001
            "security.tls.enable_0rtt_data" = false;
            # Use Mozilla geolocation service instead of Google if given permission
            "geo.provider.network.url" =
              "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
            "geo.provider.use_gpsd" = false;
            # https://support.mozilla.org/en-US/kb/extension-recommendations
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
              false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
              false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;
            "extensions.htmlaboutaddons.discover.enabled" = false;
            "extensions.getAddons.showPane" = false; # uses Google Analytics
            "browser.discovery.enabled" = false;
            # Reduce File IO / SSD abuse
            # Otherwise, Firefox bombards the HD with writes. Not so nice for SSDs.
            # This forces it to write every 30 minutes, rather than 15 seconds.
            "browser.sessionstore.interval" = "1800000";
            # Disable battery API
            # https://developer.mozilla.org/en-US/docs/Web/API/BatteryManager
            # https://bugzilla.mozilla.org/show_bug.cgi?id=1313580
            "dom.battery.enabled" = false;
            # Disable "beacon" asynchronous HTTP transfers (used for analytics)
            # https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
            "beacon.enabled" = false;
            # Disable pinging URIs specified in HTML <a> ping= attributes
            # http://kb.mozillazine.org/Browser.send_pings
            "browser.send_pings" = false;
            # Disable gamepad API to prevent USB device enumeration
            # https://www.w3.org/TR/gamepad/
            # https://trac.torproject.org/projects/tor/ticket/13023
            "dom.gamepad.enabled" = false;
            # Don't try to guess domain names when entering an invalid domain name in URL bar
            # http://www-archive.mozilla.org/docs/end-user/domain-guessing.html
            "browser.fixup.alternate.enabled" = false;
            # Disable telemetry
            # https://wiki.mozilla.org/Platform/Features/Telemetry
            # https://wiki.mozilla.org/Privacy/Reviews/Telemetry
            # https://wiki.mozilla.org/Telemetry
            # https://www.mozilla.org/en-US/legal/privacy/firefox.html#telemetry
            # https://support.mozilla.org/t5/Firefox-crashes/Mozilla-Crash-Reporter/ta-p/1715
            # https://wiki.mozilla.org/Security/Reviews/Firefox6/ReviewNotes/telemetry
            # https://gecko.readthedocs.io/en/latest/browser/experiments/experiments/manifest.html
            # https://wiki.mozilla.org/Telemetry/Experiments
            # https://support.mozilla.org/en-US/questions/1197144
            # https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/telemetry/internals/preferences.html#id1
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.server" = "data:,";
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.coverage.opt-out" = true;
            "toolkit.coverage.opt-out" = true;
            "toolkit.coverage.endpoint.base" = "";
            "experiments.supported" = false;
            "experiments.enabled" = false;
            "experiments.manifest.uri" = "";
            "browser.ping-centre.telemetry" = false;
            # https://mozilla.github.io/normandy/
            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";
            "app.shield.optoutstudies.enabled" = false;
            # Disable health reports (basically more telemetry)
            # https://support.mozilla.org/en-US/kb/firefox-health-report-understand-your-browser-perf
            # https://gecko.readthedocs.org/en/latest/toolkit/components/telemetry/telemetry/preferences.html
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "dom.security.https_only_mode" = true;

            # Disable crash reports
            "breakpad.reportURL" = "";
            "browser.tabs.crashReporting.sendReport" = false;
            "browser.crashReports.unsubmittedCheck.autoSubmit2" =
              false; # don't submit backlogged reports

            # Disable Form autofill
            # https://wiki.mozilla.org/Firefox/Features/Form_Autofill
            "browser.formfill.enable" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.available" = "off";
            "extensions.formautofill.creditCards.available" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.formautofill.heuristics.enabled" = false;
          };

          userChrome = builtins.readFile ../config/firefox/userChrome.css;
        };
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    git = {
      enable = true;
      delta.enable = true;
      userEmail = "christoph.urlacher@protonmail.com";
      userName = "ChUrl";
    };

    keychain = {
      enable = true;
      enableFishIntegration = true;
      enableXsessionIntegration = true;
      agents = [ "ssh" ];
      keys = [ "id_ed25519" ];
    };

    # TODO: Copy config from Arch dots
    kitty = {
      enable = true;
      font = {
        package = pkgs.victor-mono;
        name = "Victor Mono SemiBold";
        size = 12;
      };
      settings = {
        editor = "nvim";
        scrollback_lines = 10000;
        window_padding_width = 10;
        # hide_window_decorations = "yes";

        # Light Theme
        # background = "#f7f7f7";
        # foreground = "#494542";
        # selection_background = "#a4a1a1";
        # selection_foreground = "#f7f7f7";
        # cursor = "#494542";
        # color0 = "#090200";
        # color1 = "#da2c20";
        # color2 = "#00a152";
        # color3 = "#ffcc00";
        # color4 = "#00a0e4";
        # color5 = "#a06994";
        # color6 = "#0077d9";
        # color7 = "#a4a1a1";
        # color8 = "#5b5754";
        # color9 = "#e8bacf";
        # color10 = "#3a3332";
        # color11 = "#494542";
        # color12 = "#7f7c7b";
        # color13 = "#d6d4d3";
        # color14 = "#ccab53";
        # color15 = "#d2b3ff";
      };
      keybindings = {
        "kitty_mod+j" = "next_window";
        "kitty_mod+k" = "previous_window";
      };
    };

    # Gnome apps for now
    # mpv = {
    #   enable = true;
    #   scripts = with pkgs; [
    #     mpvScripts.mpris  # Make controllable with media keys
    #   ];
    # };

    neovim = {
      enable = true;
      extraConfig = ''
        set incsearch
        set hlsearch
        set ignorecase
        set autoindent
        set expandtab
        set smartindent
        set smarttab
        set shiftwidth=4
        set softtabstop=4
        set backspace=indent,eol,start
        set ruler
        set number
        set laststatus=2
        set noshowmode
        set undofile
        set undodir=~/.vim/undo
        set hidden
        set printfont=Victor\ Mono\ SemiBold:h10
        set guifont=Victor\ Mono\ SemiBold:h12
        let printencoding='utf-8'
        set encoding=utf-8
      '';
      plugins = with pkgs.vimPlugins; [
        # vim-nix
        surround-nvim
        # lightline-vim
        {
          plugin = lualine-nvim;
          config = ''
            lua << EOF
            require('lualine').setup {}
            EOF
          '';
        }
        vim-gitgutter
        # YouCompleteMe
        {

          plugin = nvim-autopairs;
          config = ''
            lua << EOF
            require('nvim-autopairs').setup {}
            EOF
          '';
        }
        {
          plugin = (nvim-treesitter.withPlugins
            (plugins: pkgs.tree-sitter.allGrammars));
          config = ''
            lua << EOF
            require('nvim-treesitter.configs').setup {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            }
            EOF
          '';
        }
      ];
      viAlias = true;
      vimAlias = true;
    };

    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    ssh.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # TODO: TexLive

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  services = {
    # lorri.enable = true; # Use nix-direnv instead

    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
