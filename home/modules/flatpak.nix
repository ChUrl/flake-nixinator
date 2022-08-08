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

    discord.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Discord";
    };

    spotify.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Spotify";
    };

    flatseal.enable = mkOption {
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

    home.activation = mkMerge [
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
        installFlatpak = let
          to_install = builtins.concatLists [
            (optionals cfg.discord.enable [ "com.discordapp.Discord" ])
            (optionals cfg.spotify.enable [ "com.spotify.Client" ])
            (optionals cfg.flatseal.enable [ "com.github.tchx84.Flatseal" ])
          ];

          to_install_str = builtins.concatStringsSep " " to_install;
        in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak install -y ${to_install_str}
          '';

        removeFlatpak = let
          to_remove = builtins.concatLists [
            (optionals (!cfg.discord.enable) [ "com.discordapp.Discord" ])
            (optionals (!cfg.spotify.enable) [ "com.spotify.Client" ])
            (optionals (!cfg.flatseal.enable) [ "com.github.tchx84.Flatseal" ])
          ];

          to_remove_str = builtins.concatStringsSep " " to_remove;
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
    ];

    # TODO: Add option for extra overrides and concatenate this string together
    # Allow access to linked fonts/icons
    home.file.".local/share/flatpak/overrides/global".text = ''
      [Context]
      filesystems=/run/current-system/sw/share/X11/fonts:ro;/run/current-system/sw/share/icons:ro;/nix/store:ro
    '';
  };
}
