{
  config,
  nixosConfig,
  darwinConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) jellyfin-tui color;

  systemConfig =
    if pkgs.stdenv.isLinux
    then nixosConfig
    else darwinConfig;
in {
  options.homemodules.jellyfin-tui = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf jellyfin-tui.enable {
    home = {
      packages = [
        pkgs.jellyfin-tui
      ];

      file = let
        configFile = ''
          servers:
          - name: Mafia Dortmund
            url: https://jellyfin.local.chriphost.de
            username: root
            password_file: ${systemConfig.sops.secrets.jellyfin-password.path}
            default: true

          # All following settings are OPTIONAL. What you see here are the defaults.

          # Show album cover image
          art: true
          # Save and restore the state of the player (queue, volume, etc.)
          persist: true
          # Grab the primary color from the cover image (false => uses the current theme's `accent` instead)
          auto_color: false
          # Time in milliseconds to fade between colors when the track changes
          auto_color_fade_ms: 400
          # Always show the lyrics pane, even if no lyrics are available
          lyrics: 'always' # options: 'always', 'never', 'auto'

          rounded_corners: true

          transcoding:
            bitrate: 320
            # container: mp3

          # Discord Rich Presence. Shows your listening status on your Discord profile if Discord is running.
          # NOTE: I think we're allowed to leak this to the public (hopefully)?
          discord: 1466134677537685546 # https://discord.com/developers/applications
          # Displays album art on your Discord profile if enabled
          # !!CAUTION!! - Enabling this will expose the URL of your Jellyfin instance to all Discord users!
          discord_art: false

          # Customize the title of the terminal window
          window_title: true # default -> {title} – {artist} ({year})
          # window_title: false # disable
          # Custom title: choose from current track's {title} {artist} {album} {year}
          # window_title: "\"{title}\" by {artist} ({year}) – jellyfin-tui"

          # Options specified here will be passed to mpv - https://mpv.io/manual/master/#options
          mpv:
            log-file: /tmp/mpv.log
            no-config: true
            # af: lavfi=[loudnorm=I=-23:TP=-1]
            gapless-audio: weak
            prefetch-playlist: yes
            replaygain: no
        '';
      in
        lib.mkMerge [
          (lib.optionalAttrs pkgs.stdenv.isLinux {
            ".config/jellyfin-tui/config.yaml".text = configFile;
          })
          (lib.optionalAttrs pkgs.stdenv.isDarwin {
            "Library/Application Support/jellyfin-tui/config.yaml".text = configFile;
          })
        ];
    };
  };
}
