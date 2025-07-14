{
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
}
