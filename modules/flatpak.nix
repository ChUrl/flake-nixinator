{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

# NOTE: The module is also used by other modules (gaming, audio).
#       It is important that every flatpak interaction is handled through this module
#       to prevent that anything is removed by a module although it is required by another one

# TODO: Also need a library function to enable and concatenate different flatpak overrides (also global overrides)

let
  cfg = config.modules.flatpak;
in {
  imports = [ ];

  options.modules.flatpak = {
    enable = mkBoolOpt false "Enable flatpak support";
    fontFix = mkBoolOpt true "Link fonts to ~/.local/share/fonts so flatpak apps can find them";
    iconFix = mkBoolOpt true "Link icons to ~/.local/share/icons so flatpak apps can find them";
    autoUpdate = mkBoolOpt false "Update flatpak apps on nixos-rebuild";
    autoPrune = mkBoolOpt false "Remove unused packages on nixos-rebuild";

    # TODO: Add library function to make this easier
    # TODO: The flatpak name should be included and a list of all enabled apps should be available
    # TODO: Do this for strings + packages
    discord.enable = mkBoolOpt false "Enable Discord";
    spotify.enable = mkBoolOpt false "Enable Spotify";
    flatseal.enable = mkBoolOpt true "Enable Flatseal";
    bottles.enable = mkBoolOpt false "Enable Bottles";

    # This is mainly used by other modules to allow them to use flatpak packages
    extraInstall = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Flatpaks that will be installed additionally";
    };

    # This doesn't uninstall if any flatpak is still present in the extraInstall list
    extraRemove = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Flatpaks that will be removed additionally (use with extraInstall)";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (mkIf cfg.enable {
        assertion = nixosConfig.services.flatpak.enable;
        message = "Cannot use the flatpak module with flatpak disabled in nixos!";
      })
    ];

    # NOTE: Is already set by flatpak.enable in configuration.nix
    # xdg.systemDirs.data = [
    #   "/var/lib/flatpak/exports/share"
    #   "${home.homeDirectory}/.local/share/flatpak/exports/share"
    # ];

    home.activation = mkMerge [
      # We link like this to be able to address the absolute location, also the fonts won't get copied to store
      # NOTE: This path contains all the fonts because fonts.fontDir.enable is true
      (mkIf cfg.fontFix {
        linkFontDir = lib.hm.dag.entryAfter [ "writeBoundary" ]
        (mkLink "/run/current-system/sw/share/X11/fonts" "${config.home.homeDirectory}/.local/share/fonts");
      })
      (mkElse cfg.fontFix {
        unlinkFontDir = lib.hm.dag.entryAfter [ "writeBoundary" ]
        (mkUnlink "${config.home.homeDirectory}/.local/share/fonts");
      })

      # Fixes missing icons + cursor
      # NOTE: This path works because we have homeManager.useUserPackages = true (everything is stored in /etc/profiles/)
      (mkIf cfg.iconFix {
        linkIconDir = lib.hm.dag.entryAfter [ "writeBoundary" ]
        (mkLink "/etc/profiles/per-user/christoph/share/icons" "${config.home.homeDirectory}/.local/share/icons");
      })
      (mkElse cfg.iconFix {
        unlinkIconDir = lib.hm.dag.entryAfter [ "writeBoundary" ]
        (mkUnlink "${config.home.homeDirectory}/.local/share/icons");
      })

      # TODO: I should find a smarter way than this to make it easy to add flatpak options
      {
        # TODO: Enable this block only if any flatpak is enabled
        installFlatpaks = let
          to_install = builtins.concatLists [
            (optionals cfg.discord.enable [ "com.discordapp.Discord" ])
            (optionals cfg.spotify.enable [ "com.spotify.Client" ])
            (optionals cfg.flatseal.enable [ "com.github.tchx84.Flatseal" ])
            (optionals cfg.bottles.enable [ "com.usebottles.bottles" ])
            cfg.extraInstall
          ];

          to_install_str = builtins.concatStringsSep " " to_install;
        in
          # By using || we make sure this command never throws any errors
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak install -y ${to_install_str} || echo "Nothing to be installed"
          '';
      }

      {
        # TODO: Enable this block only if any flatpak is disabled
        removeFlatpaks = let
          to_remove = builtins.concatLists [
            (optionals (!cfg.discord.enable) [ "com.discordapp.Discord" ])
            (optionals (!cfg.spotify.enable) [ "com.spotify.Client" ])
            (optionals (!cfg.flatseal.enable) [ "com.github.tchx84.Flatseal" ])
            (optionals (!cfg.bottles.enable) [ "com.usebottles.bottles" ])
            # Remove only the flatpaks that are not present in extraInstall
            (without cfg.extraRemove cfg.extraInstall)
          ];

          to_remove_str = builtins.concatStringsSep " " to_remove;
        in
          # By using || we make sure this command never throws any errors
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak uninstall -y ${to_remove_str} || echo "Nothing to be removed"
          '';
      }

      (mkIf cfg.autoUpdate {
        updateFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          sudo flatpak update -y
        '';
      })

      # Execute this after flatpak removal as there can be leftovers
      (mkIf cfg.autoPrune {
        pruneFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" "removeFlatpak" ] ''
          sudo flatpak uninstall --unused -y
        '';
      })
    ];

    # TODO: Add option for extra overrides and concatenate this string together
    # Allow access to linked fonts/icons
    home.file.".local/share/flatpak/overrides/global".text = ''
      [Context]
      filesystems=/run/current-system/sw/share/X11/fonts:ro;/run/current-system/sw/share/icons:ro;/nix/store:ro
    '';
  };
}
