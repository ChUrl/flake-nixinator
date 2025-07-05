{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) rmpc;
in {
  options.modules.rmpc = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf rmpc.enable {
    assertions = [
      {
        assertion = config.services.mpd.enable;
        message = "Enabling rmpc requires mpd!";
      }
    ];

    programs.rmcp.enable = true;

    home.file = {
      ".config/rmpc/config.ron".text = ''
        address: "127.0.0.1:${builtins.toString config.services.mpd.network.port}"
        theme: "chriphost"
        rewind_to_start_sec: 30 // rewind skips to start of the same track if more than 30 seconds were played
        // show_playlists_in_browser: All
      '';

      ".config/rmpc/themes/chriphost.ron".text = ''
        cava: (
          framerate: 60, // default 60
          autosens: true, // default true
          sensitivity: 100, // default 100
          lower_cutoff_freq: 50, // not passed to cava if not provided
          higher_cutoff_freq: 10000, // not passed to cava if not provided

          input: (
            method: Fifo,
            source: "/tmp/mpd.fifo",
            sample_rate: 44100,
            channels: 2,
            sample_bits: 16,
          ),

          smoothing: (
            noise_reduction: 77, // default 77
            monstercat: false, // default false
            waves: false, // default false
          ),

          // this is a list of floating point numbers thats directly passed to cava
          // they are passed in order that they are defined
          eq: []
        ),

      '';
    };
  };
}
