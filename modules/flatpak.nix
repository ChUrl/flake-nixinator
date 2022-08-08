{ config, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.flatpak;
in {
  imports = [ ];

  options.modules.flatpak = {
    enable = mkBoolOpt false "Enable flatpak support";
    fontFix = mkBoolOpt false "Link fonts to ~/.local/share/fonts so flatpak apps can find them";
    iconFix = mkBoolOpt false "Link icons to ~/.local/share/icons so flatpak apps can find them";
    autoUpdate = mkBoolOpt false "Update flatpak apps on nixos-rebuild";
    autoPrune = mkBoolOpt false "Remove unused packages on nixos-rebuild";

    # TODO: Add library function to make this easier
    #       The flatpak name should be included and a list of all enabled apps should be available
    discord.enable = mkBoolOpt false "Enable Discord";
    spotify.enable = mkBoolOpt false "Enable Spotify";
    flatseal.enable = mkBoolOpt false "Enable Flatseal";
  };

  config = mkIf cfg.enable {

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
        # TODO: Only install new flatpaks, check with flatpak list | grep <name> | wc -l
        installFlatpaks = let
          to_install = builtins.concatLists [
            (optionals cfg.discord.enable [ "com.discordapp.Discord" ])
            (optionals cfg.spotify.enable [ "com.spotify.Client" ])
            (optionals cfg.flatseal.enable [ "com.github.tchx84.Flatseal" ])
          ];

          to_install_str = builtins.concatStringsSep " " to_install;
        in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak install -y ${to_install_str} || echo "Nothing to be installed"
          '';
      }

      {
        # TODO: Enable this block only if any flatpak is disabled
        # TODO: Only remove flatpaks that are installed, check with flatpak list | grep <name> | wc -l
        removeFlatpaks = let
          to_remove = builtins.concatLists [
            (optionals (!cfg.discord.enable) [ "com.discordapp.Discord" ])
            (optionals (!cfg.spotify.enable) [ "com.spotify.Client" ])
            (optionals (!cfg.flatseal.enable) [ "com.github.tchx84.Flatseal" ])
          ];

          to_remove_str = builtins.concatStringsSep " " to_remove;
        in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            sudo flatpak uninstall -y ${to_remove_str} || echo "Nothing to be removed"
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
