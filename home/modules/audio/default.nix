{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules; let
  cfg = config.modules.audio;
  cfgfp = config.modules.flatpak;
in {
  imports = [
    ../flatpak
  ];

  options.modules.audio = import ./options.nix { inherit lib mylib; };

  config = mkIf cfg.enable {
    assertions = [
      (mkIf cfg.bottles.enable {
        assertion = cfgfp.enable;
        message = "Cannot enable Bottles without the flatpak module!";
      })
    ];

    # Use builtins.concatLists instead of mkMerge as this is more safe as the type is specified,
    # also mkMerge doesn't work in every case as it yields a set
    home.packages = with pkgs;
      builtins.concatLists [
        # lib.optional is preferred over mkIf or if...then...else by nix coding standards
        # lib.optional wraps its argument in a list, lib.optionals doesn't
        # This means that lib.optional can be used for single packages/arguments
        # and lib.optionals has to be used when the argument is itself a list
        # I use lib.optionals everywhere as I think this is more clear

        # Some of these include gamemode as I use that to enable performance governors for CPU/GPU and other stuff

        # Enable some default pipewire stuff if pipewire is enabled
        (optionals nixosConfig.services.pipewire.enable [
          # TODO: Disabled on 03.02.2023 because of temporary build error
          # helvum
        ])

        (optionals cfg.carla.enable [carla gamemode])
        (optionals cfg.bitwig.enable [
          bitwig-studio
          gamemode
        ])
        (optionals cfg.tenacity.enable [tenacity])

        (optionals cfg.faust.enable [faust])
        (optionals cfg.yabridge.enable [yabridge yabridgectl])
        (optionals cfg.noisesuppression.noisetorch.enable [noisetorch])

        # (optionals cfg.vcvrack.enable [ vcv-rack ]) # Replaced by cardinal
        (optionals cfg.cardinal.enable [cardinal])
        # (optionals cfg.vital.enable [ vital-synth ]) # Replaced by distrho
        (optionals cfg.distrho.enable [distrho])
      ];

    services.easyeffects = mkIf cfg.noisesuppression.easyeffects.enable {
      enable = true;
      preset = optionalString cfg.noisesuppression.easyeffects.autostart "noise_supression";
    };

    # NOTE: This desktop entry is created in /etc/profiles/per-user/christoph/share/applications
    #       This location is part of XDG_DATA_DIRS
    xdg.desktopEntries.guitar = mkIf cfg.carla.enable {
      name = "Guitar Amp (Carla)";
      genericName = "Guitar Amp Simulation";
      icon = "carla";
      exec = "env PIPEWIRE_LATENCY=256/48000 gamemoderun carla ${config.home.homeDirectory}/.config/carla/GuitarDefault.carxp";
      terminal = false;
      categories = ["Music" "Audio"];
    };

    xdg.desktopEntries.bitwig-low-latency = mkIf cfg.bitwig.enable {
      name = "Bitwig Studio (Low Latency)";
      genericName = "Digital Audio Workstation";
      icon = "bitwig-studio";
      exec = "env PIPEWIRE_LATENCY=256/48000 gamemoderun bitwig-studio";
      terminal = false;
      categories = ["Music" "Audio"];
    };

    # TODO: Disable only for plasma
    # TODO: After pipewire.target or partof pipewire.service?
    systemd.user.services = {
      # autostart-noisetorch =
      # (mkIf (cfg.noisesuppression.noisetorch.enable && cfg.noisesuppression.noisetorch.autostart) {
      #   Unit = {
      #     Type = "oneshot";
      #     Description = "Noisetorch noise suppression";
      #     PartOf = [ "graphical-session.target" ];
      #     After = [ "graphical-session.target" ];
      #   };

      #   Service = {
      #     Environment = "PATH=${config.home.profileDirectory}/bin"; # Leads to /etc/profiles/per-user/christoph/bin
      #     ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i";
      #     Restart = "on-failure";
      #   };

      #   Install.WantedBy = [ "graphical-session.target" ];
      # });
    };

    # NOTE: Important to not disable this option if another module enables it
    modules.flatpak.bottles.enable = mkIf cfg.bottles.enable true;

    home.activation = mkMerge [
      # The module includes the default carla project with ArchetypePetrucci + ArchetypeGojira
      (mkIf cfg.carla.enable {
        linkCarlaConfig =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "${config.home.homeDirectory}/NixFlake/config/carla" "${config.home.homeDirectory}/.config/carla");
      })
      (mkElse cfg.carla.enable {
        unlinkCarlaConfig =
          hm.dag.entryAfter ["writeBoundary"]
          (mkUnlink "${config.home.homeDirectory}/.config/carla");
      })

      # Replaced by distrho
      # (mkIf cfg.vital.enable {
      #   linkVitalVST3 = hm.dag.entryAfter [ "writeBoundary" ]
      #   (mkLink "${pkgs.vital-synth}/lib/vst3/Vital.vst3" "${config.home.homeDirectory}/.vst3/Vital.vst3");
      # })
      # (mkElse cfg.vital.enable {
      #   unlinkVitalVST3 = hm.dag.entryAfter [ "writeBoundary" ]
      #   (mkUnlink "${config.home.homeDirectory}/.vst3/Vital.vst3");
      # })

      (mkIf cfg.distrho.enable {
        linkDistrhoLV2 =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "${pkgs.distrho}/lib/lv2" "${config.home.homeDirectory}/.lv2/distrho");
        linkDistrhoVST =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "${pkgs.distrho}/lib/vst" "${config.home.homeDirectory}/.vst/distrho");
        linkDistrhoVST3 =
          hm.dag.entryAfter ["writeBoundary"]
          (mkLink "${pkgs.distrho}/lib/vst3" "${config.home.homeDirectory}/.vst3/distrho");
      })
      (mkElse cfg.distrho.enable {
        unlinkDistrhoLV2 =
          hm.dag.entryAfter ["writeBoundary"]
          (mkUnlink "${config.home.homeDirectory}/.lv2/distrho");
        unlinkDistrhoVST =
          hm.dag.entryAfter ["writeBoundary"]
          (mkUnlink "${config.home.homeDirectory}/.vst/distrho");
        unlinkDistrhoVST3 =
          hm.dag.entryAfter ["writeBoundary"]
          (mkUnlink "${config.home.homeDirectory}/.vst3/distrho");
      })

      (mkIf (cfg.yabridge.enable && cfg.yabridge.autoSync) {
        syncYabridge = hm.dag.entryAfter ["writeBoundary"] ''
          yabridgectl sync
        '';
      })
    ];
  };
}
