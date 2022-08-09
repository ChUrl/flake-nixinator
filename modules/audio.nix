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
    carla.enable = mkBoolOpt false "Enable Carla + guitar-specific stuff";
    # TODO: Make it easier to add many yes/no options, similar to the flatpak stuff
    bitwig.enable = mkBoolOpt false "Enable Bitwig Studio digital audio workstation";
    faust.enable = mkBoolOpt false "Enable the Faust functional DSP language";
    tenacity.enable = mkBoolOpt false "Enable Tenacity";
    bottles.enable = mkBoolOpt false "Enable Bottles to emulate windows VSTs (flatpak)";
    vcvrack.enable = mkBoolOpt false "Enable the VCV-Rack Eurorack simulator";

    # TODO: Vital derivation (adapt from aur)

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
      (optionals cfg.carla.enable [ carla gamemode ])
      (optionals cfg.yabridge.enable [ yabridge yabridgectl ])
      (optionals cfg.bitwig.enable [ bitwig-studio ])
      (optionals cfg.faust.enable [ faust ])
      (optionals cfg.tenacity.enable [ tenacity ])
      (optionals cfg.vcvrack.enable [ vcv-rack ])
      (optionals nixosConfig.services.pipewire.enable [ helvum easyeffects ])
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

      (mkIf cfg.yabridge.autoSync {
        syncYabridge = hm.dag.entryAfter [ "writeBoundary" ] ''
          yabridgectl sync
        '';
      })
    ];
  };
}
