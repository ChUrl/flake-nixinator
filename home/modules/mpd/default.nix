{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) mpd;
in {
  options.modules.mpd = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf mpd.enable {
    services.mpd = {
      enable = true;
      dataDir = "${config.home.homeDirectory}/Music/.mpd";
      musicDirectory = "${config.home.homeDirectory}/Music";
      network = {
        listenAddress = "127.0.0.1"; # Listen on all addresses: "any"
        port = 6600;
      };
      extraArgs = ["--verbose"];

      extraConfig = ''
        # Refresh the database whenever files in the musicDirectory change
        auto_update "yes"

        # Don't start playback after startup
        restore_paused "yes"

        # Use track tags on shuffle and album tags on album play (auto)
        # Use album's tags (album)
        # Use track's tags (track)
        # replaygain "auto"

        # PipeWire main output
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"

          # Use hardware mixer instead of software volume filter (replaygain_handler "software")
          # mixer_type "hardware"
          # replay_gain_handler "mixer"
        }

        # FiFo output for cava visualization
        audio_output {
          type   "fifo"
          name   "my_fifo"
          path   "/tmp/mpd.fifo"
          format "44100:16:2"
        }

        # Pre-cache 1GB of the queue
        # input_cache {
        #   size "1 GB"
        # }

        # follow_outside_symlinks "no" # If mpd should follow symlinks pointing outside the musicDirectory
        # follow_inside_symlinks "yes" # If mpd should follow symlinks pointing inside the musicDirectory
      '';
    };
  };

  # MPD integration with mpris (used by player-ctl).
  # We want to use mpris as it also supports other players (e.g. Spotify) or browsers.
  services.mpd-mpris = {
    enable = true;
    mpd.useLocal = true;
  };
}
