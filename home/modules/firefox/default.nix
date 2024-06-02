# TODO: https://github.com/nix-community/home-manager/commit/69d19b9839638fc487b370e0600a03577a559081
{
  inputs,
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.firefox;
in {
  options.modules.firefox = import ./options.nix {inherit lib mylib;};

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      builtins.concatLists [
        # TODO: I don't think vaapi works yet
        (optionals cfg.vaapi [
          # NOTE: I put these into hardware.opengl.extrapackages, don't know if they belong there...
          # libva
          # libvdpau
        ])

        (optionals cfg.gnomeTheme [firefox-gnome-theme])
      ];

    home.sessionVariables = mkMerge [
      {
        MOZ_USE_XINPUT2 = 1;
      }

      (optionalAttrs cfg.wayland {
        MOZ_ENABLE_WAYLAND = 1;
        EGL_PLATFORM = "wayland";
        # XDG_CURRENT_DESKTOP = "Hyprland"; # TODO: Or "sway"? # Already set by hyprland
      })

      (optionalAttrs cfg.vaapi {
        # LIBVA_DRIVER_NAME = "radeonsi"; # "nvidia" for Nvidia card
        # LIBVA_DRIVER_NAME = "nvidia"; # Specified in hardware-configuration
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
        # forceWayland = cfg.wayland; # Enabled by default now: https://github.com/NixOS/nixpkgs/commit/c156bdf40d2f0e64b574ade52c5611d90a0b6273

        # Find options by grepping for "cfg" in https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
        cfg = {
          # enablePlasmaBrowserIntegration = true; # TODO: Option, # NOTE: Interferes with mediaplayer, I don't want to start a youtube video when pressing the play key...
        };

        # About policies: https://github.com/mozilla/policy-templates#enterprisepoliciesenabled
        # NOTE: Some of these settings are duplicated in the about:config settings so they are
        #       not strictly necessary
        extraPolicies = {
          # TODO: Make library function to allow easy bookmark creation and add my default bookmarks/folders
          Bookmarks = optionalAttrs cfg.defaultBookmarks {};
          CaptivePortal = false;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          HardwareAcceleration = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          PictureInPicture = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };
      };

      profiles = {
        default = {
          id = 0; # 0 is default profile

          userChrome = concatStringsSep "\n" [
            (optionalString cfg.gnomeTheme ''
              @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/gnome-theme.css";
            '')

            (optionalString cfg.disableTabBar ''
              #TabsToolbar { display: none; }
            '')
          ];

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            amp2html
            augmented-steam
            betterttv
            # bypass-paywalls-clean
            c-c-search-extension # Press cc in searchbar and profit
            clearurls
            cookie-autodelete
            display-_anchors # Easier linking to specific website parts
            don-t-fuck-with-paste
            enhancer-for-youtube
            h264ify
            keepassxc-browser
            localcdn
            lovely-forks # Display notable forks on GitHub repos
            # octotree # Github on steroids
            # plasma-integration # TODO: Only when Plasma is used
            privacy-badger
            privacy-settings
            protondb-for-steam
            refined-github
            return-youtube-dislikes
            # search-by-image # TODO: Failed to build once
            single-file
            skip-redirect
            smart-referer # Limit referer link information
            snowflake # Help users from censored countries access the internet
            sourcegraph # Code intelligence for GitHub/GitLap for 20+ languages
            sponsorblock
            steam-database
            tab-session-manager
            to-deepl
            transparent-standalone-image
            tree-style-tab
            ublacklist
            ublock-origin
            # umatrix # NOTE: Many pages need manual intervention
            unpaywall
            view-image
            # vimium # NOTE: Shits the bed when site needs general key input outside of text field...
            # wappalyzer # Identify web technologies
            youtube-shorts-block
          ];

          settings = mkMerge [
            (optionalAttrs cfg.vaapi {
              # Firefox wayland hardware video acceleration
              # https://github.com/elFarto/nvidia-vaapi-driver/#firefox=
              # TODO: Disable and check if it works by default
              # "gfx.canvas.accelerated" = true; # Default value
              # "gfx.webrender.enabled" = true; # Does not exist?
              "gfx.x11-egl.force-enabled" = true;
              "layers.acceleration.force-enabled" = true;
              "media.av1.enabled" = true;
              "media.ffmpeg.vaapi.enabled" = true;
              "media.hardware-video-decoding.force-enabled" = true;
              "media.rdd-ffmpeg.enabled" = true; # Default value
              "widget.dmabuf.force-enabled" = true;
              # "widget.wayland-dmabuf-vaapi.enabled" = true; # Does not exist?
            })

            (let
              # NOTE: This has to be updated when something is changed inside firefox...
              customizationState = ''{"placements":{"widget-overflow-fixed-list":["jid1-mnnxcxisbpnsxq_jetpack-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","cookieautodelete_kennydo_com-browser-action","skipredirect_sblask-browser-action","_ublacklist-browser-action","umatrix_raymondhill_net-browser-action","_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action","_d133e097-46d9-4ecc-9903-fa6a722a6e0e_-browser-action","_f209234a-76f0-4735-9920-eb62507a54cd_-browser-action","dontfuckwithpaste_raim_ist-browser-action","sponsorblocker_ajay_app-browser-action","mogultv_mogultv_org-browser-action","jid1-tsgsxbhncspbwq_jetpack-browser-action","sourcegraph-for-firefox_sourcegraph_com-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_34daeb50-c2d2-4f14-886a-7160b24d66a4_-browser-action","smart-referer_meh_paranoid_pk-browser-action","jid1-ckhysaadh4nl6q_jetpack-browser-action","_e737d9cb-82de-4f23-83c6-76f70a82229c_-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","github-forks-addon_musicallyut_in-browser-action"],"nav-bar":["back-button","forward-button","downloads-button","urlbar-container","save-to-pocket-button","fxa-toolbar-menu-button","treestyletab_piro_sakura_ne_jp-browser-action","ublock0_raymondhill_net-browser-action","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","display-anchors_robwu_nl-browser-action","tab-session-manager_sienori-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","keepassxc-browser_keepassxc_org-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["firefox-view-button","tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks"]},"seen":["developer-button","ublock0_raymondhill_net-browser-action","_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action","_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action","_531906d3-e22f-4a6c-a102-8057b88a1a63_-browser-action","_74145f27-f039-47ce-a470-a662b129930a_-browser-action","_b86e4813-687a-43e6-ab65-0bde4ab75758_-browser-action","_d133e097-46d9-4ecc-9903-fa6a722a6e0e_-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","_f209234a-76f0-4735-9920-eb62507a54cd_-browser-action","_ublacklist-browser-action","cookieautodelete_kennydo_com-browser-action","dontfuckwithpaste_raim_ist-browser-action","jid1-mnnxcxisbpnsxq_jetpack-browser-action","keepassxc-browser_keepassxc_org-browser-action","skipredirect_sblask-browser-action","sponsorblocker_ajay_app-browser-action","tab-session-manager_sienori-browser-action","treestyletab_piro_sakura_ne_jp-browser-action","umatrix_raymondhill_net-browser-action","mogultv_mogultv_org-browser-action","jid1-tsgsxbhncspbwq_jetpack-browser-action","display-anchors_robwu_nl-browser-action","github-forks-addon_musicallyut_in-browser-action","_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action","_e737d9cb-82de-4f23-83c6-76f70a82229c_-browser-action","jid1-ckhysaadh4nl6q_jetpack-browser-action","smart-referer_meh_paranoid_pk-browser-action","_34daeb50-c2d2-4f14-886a-7160b24d66a4_-browser-action","_762f9885-5a13-4abd-9c77-433dcd38b8fd_-browser-action","_b11bea1f-a888-4332-8d8a-cec2be7d24b9_-browser-action","sourcegraph-for-firefox_sourcegraph_com-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":6}'';
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

              "identity.fxaccounts.account.device.name" = nixosConfig.networking.hostName;

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
              "toolkit.legacyUserProfileCustomizations.stylesheets" = cfg.gnomeTheme || cfg.disableTabBar;
              "toolkit.telemetry.unified" = false;
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.server" = "data:,";
              "toolkit.telemetry.archive.enabled" = false;
              "toolkit.telemetry.coverage.opt-out" = true;

              "widget.use-xdg-desktop-portal" = true;
            })
          ];
        };
      };
    };
  };
}
