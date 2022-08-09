{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.audio;
  cfgfp = config.modules.flatpak;
in {
  imports = [
    ./flatpak.nix
  ];

  options.modules.audio = {
    enable = mkBoolOpt false "Configure for realtime audio and enable a bunch of music production tools";

    # TODO: Group these in categories (like instruments/VSTs or sth)
    # TODO: Make it easier to add many yes/no options, similar to the flatpak stuff

    # Hosts/Editing
    carla.enable = mkBoolOpt false "Enable Carla + guitar-specific stuff";
    bitwig.enable = mkBoolOpt false "Enable Bitwig Studio digital audio workstation";
    tenacity.enable = mkBoolOpt false "Enable Tenacity";

    # Instruments/Plugins
    vcvrack.enable = mkBoolOpt false "Enable the VCV-Rack Eurorack simulator";
    vital.enable = mkBoolOpt false "Enable the Vital wavetable Synthesizer";

    # Misc
    faust.enable = mkBoolOpt false "Enable the Faust functional DSP language";
    bottles.enable = mkBoolOpt false "Enable Bottles to emulate windows VSTs (flatpak)";
    yabridge = {
      enable = mkBoolOpt false "Enable yabridge + yabridgectl";
      autoSync = mkBoolOpt false "Sync yabridge plugins on nixos-rebuild";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (mkIf cfg.bottles.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable Bottles without the flatpak module!";
      })
    ];

    # Use builtins.concatLists instead of mkMerge as this is more safe as the type is specified,
    # also mkMerge doesn't work in every case as it yields a set
    home.packages = with pkgs; builtins.concatLists [

      # lib.optional is preferred over mkIf or if...then...else by nix coding standards
      # lib.optional wraps its argument in a list, lib.optionals doesn't
      # This means that lib.optional can be used for single packages/arguments
      # and lib.optionals has to be used when the argument is itself a list
      # I use lib.optionals everywhere as I think this is more clear

      # Some of these include gamemode as I use that to enable performance governors for CPU/GPU and other stuff

      # Enable some default pipewire stuff if pipewire is enabled
      (optionals nixosConfig.services.pipewire.enable [ helvum easyeffects ])

      (optionals cfg.carla.enable [ carla gamemode ])
      (optionals cfg.bitwig.enable [
        # TODO: The override doesn't help, Bitwig pipewire still fails...
        # We need to force pipewire into the dependencies so bitwig can access libpipewire
        # This will probably get patched directly into nixpkgs in the future
        # NOTE: override overrides the function arguments (this part: { stdenv, fetchurl, ... })
        #       while overrideAttrs overrides the stuff inside mkDerivation { ... }
        (bitwig-studio.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [ pipewire ];
        }))
        gamemode
        # bitwig-studio
      ])
      (optionals cfg.tenacity.enable [ tenacity ])

      (optionals cfg.faust.enable [ faust ])
      (optionals cfg.yabridge.enable [ yabridge yabridgectl ])

      (optionals cfg.vcvrack.enable [ vcv-rack ])
      (optionals cfg.vital.enable [ vital-synth ])
    ];

    # NOTE: This desktop entry is created in /etc/profiles/per-user/christoph/share/applications
    #       This location is part of XDG_DATA_DIRS
    xdg.desktopEntries.guitar = mkIf cfg.carla.enable {
      name = "Guitar Amp (Carla)";
      genericName = "Guitar Amp Simulation";
      icon = "carla";
      exec = "env PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${config.home.homeDirectory}/.config/carla/GuitarDefault.carxp";
      terminal = false;
      categories = [ "Music" "Audio" ];
    };

    xdg.desktopEntries.bitwig-low-latency = mkIf cfg.bitwig.enable {
      name = "Bitwig Studio (Low Latency)";
      genericName = "Digital Audio Workstation";
      icon = "bitwig-studio";
      exec = "env PIPEWIRE_LATENCY=256/48000 gamemoderun bitwig-studio";
      terminal = false;
      categories = [ "Music" "Audio" ];
    };

    # NOTE: Important to not disable this option if another module enables it
    modules.flatpak.bottles.enable = mkIf cfg.bottles.enable true;

    home.activation = mkMerge [
      # The module includes the default carla project with ArchetypePetrucci + ArchetypeGojira
      (mkIf cfg.carla.enable {
        linkCarlaConfig = hm.dag.entryAfter [ "writeBoundary" ]
        (mkLink "${config.home.homeDirectory}/NixFlake/config/carla" "${config.home.homeDirectory}/.config/carla");
      })
      (mkElse cfg.carla.enable {
        unlinkCarlaConfig = hm.dag.entryAfter [ "writeBoundary" ]
        (mkUnlink "${config.home.homeDirectory}/.config/carla");
      })

      (mkIf cfg.vital.enable {
        linkVitalVST3 = hm.dag.entryAfter [ "writeBoundary" ]
        (mkLink "${pkgs.vital-synth}/lib/vst3/Vital.vst3/Contents/x86_64-linux/Vital.so" "${config.home.homeDirectory}/.vst3/Vital.so");
      })
      (mkElse cfg.vital.enable {
        unlinkVitalVST3 = hm.dag.entryAfter [ "writeBoundary" ]
        (mkUnlink "${config.home.homeDirectory}/.vst3/Vital.so");
      })

      (mkIf cfg.yabridge.autoSync {
        syncYabridge = hm.dag.entryAfter [ "writeBoundary" ] ''
          yabridgectl sync
        '';
      })
    ];
  };
}
