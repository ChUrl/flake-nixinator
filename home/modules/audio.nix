{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.audio;
in {
  imports = [ ];

  options.modules.audio = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Configure for realtime audio and enable a bunch of music production tools";
    };

    carla = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Carla + guitar-specific stuff";
    };

    yabridge = {
      enable = {
        type = types.bool;
        default = false;
        description = "Enable yabridge + yabridgectl";
      };

      autosync = {
        type = types.bool;
        default = false;
        description = "Sync yabridge plugins on nixos-rebuild";
      };
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; (mkMerge [
      (mkIf cfg.carla [ carla ])

      (mkIf cfg.yabridge.enable [ yabridge yabridgectl ])
    ]);


    # NOTE: This desktop entry is created in /etc/profiles/per-user/christoph/share/applications
    #       This location is part of XDG_DATA_DIRS
    xdg.desktopEntries.guitar = mkIf cfg.carla {
      name = "Guitar Amp (Carla)";
      genericName = "Guitar Amp Simulation";
      icon = "carla";
      exec = "env PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${home.homeDirectory}/.config/carla/GuitarDefault.carxp";
      terminal = false;
      categories = [ "Music" "Audio" ];
    };

    home.activation = (mkMerge [
      (mkIf cfg.carla {

        # The module includes the default carla project with ArchetypePetrucci + ArchetypeGojira
        # TODO: I don't know if I should keep this
        linkCarlaConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -L "${config.home.homeDirectory}/.config/carla" ]; then
            ln -sf ${config.home.homeDirectory}/NixFlake/config/carla ${config.home.homeDirectory}/.config/carla
          fi
        '';
      })

      (mkIf cfg.yabridge.autosync {
        syncYabridge = hm.dag.entryAfter [ "writeBoundary" ] ''
          yabridgectl sync
        '';
      })
    ]);

  };
}
