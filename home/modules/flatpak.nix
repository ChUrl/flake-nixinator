{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.flatpak;
in {
  imports = [ ];

  options.modules.flatpak = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable flatpak support";
    };

    fontFix = mkOption {
      type = types.bool;
      default = false;
      description = "Link fonts to ~/.local/share/fonts so flatpak apps can find them";
    };

    iconFix = mkOption {
      type = types.bool;
      default = false;
      description = "Link icons to ~/.local/share/icons so flatpak apps can find them";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = "Update flatpak apps on nixos-rebuild";
    };

    autoPrune = mkOption {
      type = types.bool;
      default = false;
      description = "Remove unused packages on nixos-rebuild";
    };

    discord = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Discord";
    };

    spotify = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Spotify";
    };

    flatseal = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Flatseal";
    };

    # NOTE: Disabled as these won't be removed automatically when disabled
    #       Will see if it works well enough without this flexibility
    # extraPackages = mkOption {
    #   type = types.listOf types.str;
    #   default = [ ];
    #   description = "List of additionally enabled flatpaks";
    # };
  };

  config = mkIf cfg.enable {

    # NOTE: Is already set by flatpak.enable in configuration.nix
    # xdg.systemDirs.data = [
    #   "/var/lib/flatpak/exports/share"
    #   "${home.homeDirectory}/.local/share/flatpak/exports/share"
    # ];

    home.activation = (mkMerge [
      (mkIf cfg.fontFix {
        # We link like this to be able to address the absolute location, also the fonts won't get copied to store
        # NOTE: This path contains all the fonts because fonts.fontDir.enable is true
        linkFontDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -L "${config.home.homeDirectory}/.local/share/fonts" ]; then
            ln -sf /run/current-system/sw/share/X11/fonts ${config.home.homeDirectory}/.local/share/fonts
          fi
        '';
      })

      (mkIf cfg.iconFix {
        # NOTE: This path works because we have homeManager.useUserPackages = true (everything is stored in /etc/profiles/)
        linkIconDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -L "${config.home.homeDirectory}/.local/share/icons" ]; then
            ln -sf /etc/profiles/per-user/christoph/share/icons ${config.home.homeDirectory}/.local/share/icons
          fi
        '';
      })

      {
        installFlatpak =
        let
          # For some reason (mkIf ...) evaluates to a set { _type = "if"; condition = ... } so nothing can
          # be merged. I don't understand why the set isn't evaluated, it worked previously
          to_install = (builtins.concatLists [
            # (mkIf cfg.discord [ "com.discordapp.Discord" ])
            # (mkIf cfg.spotify [ "com.spotify.Client" ])
            # (mkIf cfg.flatseal [ "com.github.tchx84.Flatseal" ])
            (if cfg.discord then [ "com.discordapp.Discord" ] else [ ])
            (if cfg.spotify then [ "com.spotify.Client" ] else [ ])
            (if cfg.flatseal then [ "com.github.tchx84.Flatseal" ] else [ ])
            # cfg.extraPackages
          ]);

          to_install_str = (builtins.concatStringsSep " " to_install);
        in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak install -y ${to_install_str}
          '';

        # NOTE: This only removes named flatpaks, nothing from extraPackages
        removeFlatpak =
        let
          to_remove = (builtins.concatLists [
            (if ! cfg.discord then [ "com.discordapp.Discord" ] else [ ])
            (if ! cfg.spotify then [ "com.spotify.Client" ] else [ ])
            (if ! cfg.flatseal then [ "com.github.tchx84.Flatseal" ] else [ ])
          ]);

          to_remove_str = (builtins.concatStringsSep " " to_remove);
        in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak uninstall -y ${to_remove_str}
          '';
      }

      (mkIf cfg.autoUpdate {
        updateFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          sudo flatpak update -y
        '';
      })

      (mkIf cfg.autoPrune {
        pruneFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" "removeFlatpak" ] ''
          sudo flatpak uninstall --unused -y
        '';
      })
    ]);

    # TODO: Add option for extra overrides and concatenate this string together
    # Allow access to linked fonts/icons
    home.file.".local/share/flatpak/overrides/global".text = ''
      [Context]
      filesystems=/run/current-system/sw/share/X11/fonts:ro;/run/current-system/sw/share/icons:ro;/nix/store:ro
    '';
  };
}
