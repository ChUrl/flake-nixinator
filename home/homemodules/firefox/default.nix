{
  config,
  lib,
  mylib,
  pkgs,
  hostname,
  ...
}: let
  inherit (config.homemodules) firefox color;
in {
  options.homemodules.firefox = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf firefox.enable {
    textfox = {
      enable = firefox.textfox;
      useLegacyExtensions = false;
      profiles = ["default"];

      config = {
        background = {
          color = color.hexS.base;
        };

        border = {
          color = color.hexS.overlay0;
          width = "2px";
          transition = "1.0s ease";
          radius = "3px";
        };

        displayWindowControls = true;
        displayNavButtons = true;
        displayUrlbarIcons = true;
        displaySidebarTools = false;
        displayTitles = false;

        icons = {
          toolbar.extensions.enable = true;
          context.extensions.enable = true;
          context.firefox.enable = true;
        };

        tabs = {
          horizontal.enable = !firefox.disableTabBar;
          vertical.enable = firefox.disableTabBar;
          # vertical.margin = "1rem";
        };

        font = {
          family = color.font;
          size = "14px";
          accent = color.hexS.accent;
        };
      };
    };

    home.packages = with pkgs; [vdhcoapp];

    home.sessionVariables = lib.mkMerge [
      {
        MOZ_USE_XINPUT2 = 1;
      }

      (lib.optionalAttrs firefox.wayland {
        MOZ_ENABLE_WAYLAND = 1;
        EGL_PLATFORM = "wayland";
      })

      (lib.optionalAttrs firefox.vaapi {
        MOZ_DISABLE_RDD_SANDBOX = 1;
      })
    ];

    # Not required with rofi -drun-show-actions
    # xdg.desktopEntries.firefox-private = {
    #   name = "Firefox (Incognito)";
    #   genericName = "Private web browser";
    #   icon = "firefox";
    #   exec = "firefox --private-window %U";
    #   terminal = false;
    #   categories = ["Network" "WebBrowser"];
    # };

    programs.firefox = {
      enable = true;

      # firefox-unwrapped is the pure firefox browser, wrapFirefox adds configuration ontop
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        # About policies: https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
        # TODO: To separate file
        extraPolicies = {
          CaptivePortal = false;
          DisableAppUpdate = true;
          DisableFirefoxAccounts = true;
          DisableFirefoxScreenshots = true;
          DisableFirefoxStudies = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = true;
          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };
          FirefoxHome = {
            Highlights = false;
            Search = true;
            Snippets = false;
            SponsoredTopSites = false;
            TopSites = false;
          };
          FirefoxSuggest = {
            ImproveSuggest = false;
            SponsoredSuggestions = false;
            WebSuggestions = false;
          };
          HardwareAcceleration = true;
          # NoDefaultBookmarks = true; # Prevents HM from applying bookmarks
          OfferToSaveLogins = false;
          PictureInPicture = true;
          SanitizeOnShutdown = {
            Cache = false;
            Cookies = false;
            FormData = true;
            History = false;
            Sessions = false;
            SiteSettings = false;
          };
          UserMessaging = {
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            MoreFromMozilla = false;
            SkipOnboarding = true;
            UrlbarInteventions = false;
          };
        };
      };

      profiles = {
        default = {
          id = 0; # 0 is default profile

          userChrome = lib.concatStringsSep "\n" [
            (lib.optionalString firefox.disableTabBar ''
              #TabsToolbar { display: none; }
            '')
          ];

          # TODO: To separate file
          search = {
            force = true; # Always override search engines
            default = "kagi";
            privateDefault = "kagi";
            order = [
              "kagi"
              "wiki"
              "nixos-packages"
              "nixos-functions"
              "nixos-wiki"
              "google"
            ];

            engines = {
              kagi = {
                name = "Kagi";
                urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
                iconMapObj."16" = "https://kagi.com/favicon.ico";
                definedAliases = ["@k"];
              };

              wiki = {
                name = "Wikipedia";
                urls = [{template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}";}];
                iconMapObj."16" = "https://en.wikipedia.org/favicon.ico";
                definedAliases = ["@w"];
              };

              nixos-packages = {
                name = "NixOS Packages";
                urls = [{template = "https://searchix.ovh/?query={searchTerms}";}];
                iconMapObj."16" = "https://nixos.org/favicon.ico";
                definedAliases = ["@np"];
              };

              nixos-functions = {
                name = "NixOS Functions";
                urls = [{template = "https://noogle.dev/q?term={searchTerms}";}];
                iconMapObj."16" = "https://nixos.org/favicon.ico";
                definedAliases = ["@nf"];
              };

              nixos-wiki = {
                name = "NixOS Wiki";
                urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
                iconMapObj."16" = "https://nixos.org/favicon.ico";
                definedAliases = ["@nw"];
              };

              arch-wiki = {
                name = "Arch Wiki";
                urls = [{template = "https://wiki.archlinux.org/?search={searchTerms}";}];
                iconMapObj."16" = "https://wiki.archlinux.org/favicon.ico";
                definedAliases = ["@aw"];
              };

              nixpkgs-issues = {
                name = "Nixpkgs Issues";
                urls = [{template = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue%20{searchTerms}";}];
                iconMapObj."16" = "https://github.com/favicon.ico";
                definedAliases = ["@i"];
              };

              github = {
                name = "GitHub";
                urls = [{template = "https://github.com/search?q={searchTerms}&type=repositories";}];
                iconMapObj."16" = "https://github.com/favicon.ico";
                definedAliases = ["@gh"];
              };

              google.metaData.alias = "@g";

              # Hide bullshit
              bing.metaData.hidden = true;
              ddg.metaData.hidden = true;
              ecosia.metaData.hidden = true;
              wikipedia.metaData.hidden = true;
            };
          };

          # TODO: To separate file
          extensions = {
            force = true; # Always override extensions

            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              absolute-enable-right-click # Force enable right click to copy text
              amp2html
              augmented-steam
              betterttv
              # bypass-paywalls-clean
              # c-c-search-extension # Press cc in searchbar and profit
              catppuccin-mocha-mauve
              # catppuccin-web-file-icons
              clearurls
              # cookie-autodelete
              # dark-background-light-text
              display-_anchors # Easier linking to specific website parts
              don-t-fuck-with-paste
              # enhancer-for-youtube # Discontinued, use tweaks-for-youtube
              fastforwardteam # skip URL shorteners
              # faststream # replace video players with a faster one
              frankerfacez # twitch emotes
              indie-wiki-buddy
              keepassxc-browser
              localcdn
              lovely-forks # Display notable forks on GitHub repos
              # move-unloaded-tabs-for-tst # move tst tabs without them becoming active
              native-mathml # native MathML instead of MathJax/MediaWiki
              no-pdf-download # open pdf in browser without downloading
              open-in-freedium
              # plasma-integration
              privacy-badger
              privacy-settings
              protondb-for-steam
              proton-vpn
              purpleadblock # twitch adblocker
              return-youtube-dislikes
              # rust-search-extension
              search-by-image
              single-file
              skip-redirect
              smart-referer # Limit referer link information
              snowflake # Help users from censored countries access the internet
              # sourcegraph # Code intelligence for GitHub/GitLap for 20+ languages
              sponsorblock
              steam-database
              # tab-session-manager
              # to-deepl
              transparent-standalone-image
              # tree-style-tab
              # tst-fade-old-tabs
              tweaks-for-youtube
              twitch-auto-points
              ublacklist
              ublock-origin
              unpaywall
              video-downloadhelper
              view-image
              web-clipper-obsidian
              youtube-shorts-block
              zotero-connector
            ];
          };

          bookmarks = {
            # Always override bookmarks (so we don't forget to add them through here)
            force = true;
            settings = import ./bookmarks.nix;
          };

          settings = lib.mkMerge [
            (import ./settings.nix)

            {
              # NOTE: This has to be updated when something is changed inside firefox...
              "browser.uiCustomization.state" = builtins.readFile ./customizationState.json;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = firefox.disableTabBar;
              "identity.fxaccounts.account.device.name" = hostname;
            }

            (lib.optionalAttrs firefox.vaapi {
              # https://github.com/elFarto/nvidia-vaapi-driver/#firefox=
              "media.ffmpeg.vaapi.enabled" = true;
              "media.rdd-ffmpeg.enabled" = true; # Default value
              "media.av1.enabled" = true;
              "gfx.x11-egl.force-enabled" = true;
              "widget.dmabuf.force-enabled" = true;
            })
          ];
        };
      };
    };
  };
}
