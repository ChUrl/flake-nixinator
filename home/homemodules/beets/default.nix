{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.homemodules) beets;
in {
  options.homemodules.beets = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf beets.enable {
    programs.beets = {
      enable = true;
      mpdIntegration = {
        host = "127.0.0.1";
        port = config.services.mpd.network.port;
        enableUpdate = true;
        enableStats = true;
      };

      # https://beets.readthedocs.io/en/stable/reference/config.html
      settings = {
        directory = "${config.home.homeDirectory}/Music";
        library = "${config.home.homeDirectory}/Music/.beets/library.db";
        threaded = true;
        art_filename = "cover";

        ui = {
          color = true;
        };

        import = {
          write = true; # Write metadata to files
          copy = false; # Copy files to the music directory when importing
          move = true; # Move files to the music directory when importing
          log = "${config.home.homeDirectory}/Music/.beetslog.txt";
        };

        paths = {
          default = "$albumartist/$albumartist - $album/$track $title";
          singleton = "0 Singles/$artist - $title"; # Single songs
          comp = "1 Various/$album/$track $title";
        };

        plugins = [
          "badfiles" # check audio file integrity
          "duplicates"
          "edit" # edit metadata in text editor
          "fetchart" # pickup local cover art or search online
          "fish" # beet fish generates ~/.config/fish/completions file
          # "lyrics" # fetch song lyrics
          "musicbrainz" # auto tagger data source
          "replaygain" # write replaygain tags for automatic loudness adjustments
        ];

        fetchart = {
          auto = "yes";
          sources = "filesystem coverart itunes amazon albumart"; # sources are queried in this order
        };

        # lyrics = {
        #   auto = "yes"; # only embeds lyrics into metadata, needed for jellyfin but useless for rmpc
        #   synced = "yes"; # prefer synced lyrics if provided
        # };

        replaygain = {
          auto = "yes"; # analyze on import automatically
          backend = "ffmpeg";
          overwrite = true; # re-analyze files with existing replaygain tags on import
        };
      };
    };

    # Generate fish completions
    # TODO: This doesn't work if ~/Music is mounted after the activation...
    # home.activation = {
    #   beets-fish-completions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     echo "Generating beet completions for fish shell at ~/.config/fish/completions/beet.fish"
    #     beet fish
    #   '';
    # };
  };
}
