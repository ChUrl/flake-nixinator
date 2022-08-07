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

    packages = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of enabled flatpaks";
    };

    autoInstall = mkOption {
      type = types.bool;
      default = false;
      description = "Install enabled flatpaks on nixos-rebuild";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = "Update flatpak apps on nixos-rebuild";
    };
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

      (mkIf cfg.autoInstall {
        installFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          flatpak install -y ${builtins.concatStringsSep " " cfg.packages}
        '';
      })

      (mkIf cfg.autoUpdate {
        updateFlatpak = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          flatpak update -y
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
