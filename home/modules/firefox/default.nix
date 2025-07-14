# TODO: https://github.com/nix-community/home-manager/commit/69d19b9839638fc487b370e0600a03577a559081
{
  config,
  lib,
  mylib,
  pkgs,
  hostname,
  ...
}: let
  inherit (config.modules) firefox;
in {
  options.modules.firefox = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf firefox.enable {
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
          NoDefaultBookmarks = true;
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

              google.metaData.alias = "@g"; # builtin engines only support specifying one additional alias

              # Hide bullshit
              bing.metaData.hidden = true;
              ddg.metaData.hidden = true;
              ecosia.metaData.hidden = true;
              wikipedia.metaData.hidden = true;
            };
          };

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
              catppuccin-web-file-icons
              clearurls
              cookie-autodelete
              display-_anchors # Easier linking to specific website parts
              don-t-fuck-with-paste
              enhancer-for-youtube
              fastforwardteam # skip URL shorteners
              # faststream # replace video players with a faster one
              frankerfacez # twitch emotes
              indie-wiki-buddy
              keepassxc-browser
              localcdn
              lovely-forks # Display notable forks on GitHub repos
              move-unloaded-tabs-for-tst # move tst tabs without them becoming active
              native-mathml # native MathML instead of MathJax/MediaWiki
              no-pdf-download # open pdf in browser without downloading
              open-in-freedium
              # plasma-integration # TODO: Only when Plasma is used
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
              tab-session-manager
              # to-deepl
              transparent-standalone-image
              tree-style-tab
              tst-fade-old-tabs
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
            force = true; # Always override bookmarks (so we don't forget to add them through here)
            settings = import ./bookmarks.nix;
          };

          settings = lib.mkMerge [
            (lib.optionalAttrs firefox.vaapi {
              # Firefox wayland hardware video acceleration
              # https://github.com/elFarto/nvidia-vaapi-driver/#firefox=
              # TODO: Disable and check if it works by default
              # "gfx.canvas.accelerated" = true; # Default value
              # "gfx.webrender.enabled" = true; # Does not exist?

              "media.ffmpeg.vaapi.enabled" = true;
              "media.rdd-ffmpeg.enabled" = true; # Default value
              "media.av1.enabled" = true;
              "gfx.x11-egl.force-enabled" = true;
              "widget.dmabuf.force-enabled" = true;

              # "layers.acceleration.force-enabled" = true;
              # "media.hardware-video-decoding.force-enabled" = true;
              # "widget.wayland-dmabuf-vaapi.enabled" = true; # Does not exist?
            })

            (let
              # NOTE: This has to be updated when something is changed inside firefox...
              customizationState = builtins.readFile ./customizationState.json;
            in {
              "accessibility.force_disabled" = 1;
              "app.normandy.enabled" = false; # https://mozilla.github.io/normandy/
              "app.normandy.api_url" = "";
              "app.update.auto" = false;
              "app.shield.optoutstudies.enabled" = false;

              "beacon.enabled" = false; # https://developer.mozilla.org/en-US/docs/Web/API/navigator.sendBeacon
              "breakpad.reportURL" = "";
              "browser.aboutConfig.showWarning" = false; # Warning when opening about:config
              "browser.contentblocking.category" = "standard";
              "browser.crashReports.unsubmittedCheck.autoSubmit2" = false; # don't submit backlogged reports
              "browser.disableResetPrompt" = true; # "Looks like you haven't started Firefox in a while."
              "browser.discovery.enabled" = false;
              "browser.fixup.alternate.enabled" = false; # http://www-archive.mozilla.org/docs/end-user/domain-guessing.html
              "browser.formfill.enable" = false;
              "browser.newtabpage.enabled" = false;
              "browser.newtab.url" = "about:blank";
              "browser.newtab.preload" = false;
              "browser.newtabpage.activity-stream.asrouter.userprefs.cfr" = false;
              "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
              "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
              "browser.newtabpage.activity-stream.enabled" = false; # https://wiki.mozilla.org/Firefox/Activity_Stream
              "browser.newtabpage.activity-stream.telemetry" = false;
              "browser.newtabpage.directory.ping" = "";
              "browser.newtabpage.directory.source" = "data:text/plain,{}";
              "browser.newtabpage.enhanced" = false;
              "browser.newtabpage.introShown" = true;
              "browser.onboarding.enabled" = false; # "New to Firefox? Let's get started!" tour
              "browser.ping-centre.telemetry" = false;
              "browser.send_pings" = false; # http://kb.mozillazine.org/Browser.send_pings
              "browser.sessionstore.interval" = "1800000"; # Reduce File IO / SSD abuse by increasing write interval
              "browser.shell.checkDefaultBrowser" = false;
              "browser.tabs.crashReporting.sendReport" = false;
              "browser.toolbars.bookmarks.visibility" = "always";
              "browser.uiCustomization.state" = customizationState;
              "browser.urlbar.dnsResolveSingleWordsAfterSearch" = 0; # https://bugzilla.mozilla.org/1642623
              "browser.urlbar.shortcuts.bookmarks" = false; # This is only the button to search in bookmarks, bookmark search works anyway if enabled
              "browser.urlbar.shortcuts.history" = false;
              "browser.urlbar.shortcuts.tabs" = false;
              "browser.urlbar.showSearchSuggestionsFirst" = false;
              "browser.urlbar.speculativeConnect.enabled" = false;
              "browser.urlbar.suggest.calculator" = true;
              "browser.urlbar.suggest.engines" = false;
              "browser.urlbar.suggest.openpage" = false;
              "browser.urlbar.suggest.searches" = true;
              "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
              "browser.urlbar.suggest.quicksuggest.sponsored" = false;
              "browser.urlbar.unitConversion.enabled" = true;
              "browser.urlbar.trimURLs" = false;

              "datareporting.healthreport.uploadEnabled" = false;
              "datareporting.healthreport.service.enabled" = false;
              "datareporting.policy.dataSubmissionEnabled" = false;
              "dom.battery.enabled" = false;
              "dom.forms.autocomplete.formautofill" = false;
              "dom.gamepad.enabled" = false; # Disable gamepad API to prevent USB device enumeration
              "dom.security.https_only_mode" = true;

              "experiments.enabled" = false;
              "experiments.manifest.uri" = "";
              "experiments.supported" = false;
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.available" = "off";
              "extensions.formautofill.creditCards.available" = false;
              "extensions.formautofill.creditCards.enabled" = false;
              "extensions.formautofill.heuristics.enabled" = false;
              "extensions.getAddons.showPane" = false; # uses Google Analytics
              "extensions.htmlaboutaddons.discover.enabled" = false;
              "extensions.htmlaboutaddons.recommendations.enabled" = false;
              "extensions.pocket.enabled" = false;
              "extensions.shield-recipe-client.enabled" = false;

              "general.autoScroll" = false;
              "general.smoothScroll" = true;
              "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
              "geo.provider.use_gpsd" = false;

              "identity.fxaccounts.account.device.name" = hostname;

              "media.hardwaremediakeys.enabled" = false; # Do not interfere with spotify
              "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;

              "narrate.enabled" = false;

              "privacy.donottrackheader.enabled" = true;
              "privacy.donottrackheader.value" = 1;
              "privacy.purge_trackers.enabled" = true;
              "privacy.webrtc.legacyGlobalIndicator" = false;
              "privacy.webrtc.hideGlobalIndicator" = true;

              "reader.parse-on-load.enabled" = false; # "reader view"

              "security.family_safety.mode" = 0;
              "security.pki.sha1_enforcement_level" = 1; # https://blog.mozilla.org/security/2016/10/18/phasing-out-sha-1-on-the-public-web/
              "security.tls.enable_0rtt_data" = false; # https://github.com/tlswg/tls13-spec/issues/1001
              "signon.autofillForms" = false;
              "signon.generateion.enabled" = false;
              "signon.rememberSignons" = false;

              "toolkit.coverage.opt-out" = true;
              "toolkit.coverage.endpoint.base" = "";
              "toolkit.legacyUserProfileCustomizations.stylesheets" = firefox.gnomeTheme || firefox.disableTabBar;
              "toolkit.telemetry.unified" = false;
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.server" = "data:,";
              "toolkit.telemetry.archive.enabled" = false;
              "toolkit.telemetry.coverage.opt-out" = true;

              "widget.use-xdg-desktop-portal" = true;
              "widget.use-xdg-desktop-portal.file-picker" = 1; # 1: always, 2: auto
              "widget.use-xdg-desktop-portal.location" = 2;
              "widget.use-xdg-desktop-portal.mime-handler" = 2;
              "widget.use-xdg-desktop-portal.native-messaging" = 0;
              "widget.use-xdg-desktop-portal.open-uri" = 2;
              "widget.use-xdg-desktop-portal.settings" = 2;
            })
          ];
        };
      };
    };
  };
}
