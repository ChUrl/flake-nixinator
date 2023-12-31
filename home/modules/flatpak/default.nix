{
  config,
  nixosConfig,
  lib,
  mylib,
  pkgs,
  ...
}:
with lib;
with mylib.modules;
# NOTE: The module is also used by other modules (gaming, audio).
#       It is important that every flatpak interaction is handled through this module
#       to prevent that anything is removed by a module although it is required by another one
  let
    cfg = config.modules.flatpak;
  in {
    options.modules.flatpak = import ./options.nix {inherit lib mylib;};

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = nixosConfig.services.flatpak.enable;
          message = "Cannot use the flatpak module with flatpak disabled in nixos!";
        }
      ];

      # NOTE: Is already set by flatpak.enable in configuration.nix
      # xdg.systemDirs.data = [
      #   "/var/lib/flatpak/exports/share"
      #   "${home.homeDirectory}/.local/share/flatpak/exports/share"
      # ];

      # TODO: Currently it is not possible to define overrides for the same flatpak from different places
      # TODO: Also only filesystem overrides are applied
      home.file = let
        # Specific overrides
        # This generates the set { "<filename>" = "<overrides>"; }
        concat_override = name: value: (optionalAttrs (name != null) {".local/share/flatpak/overrides/${name}".text = "[Context]\nfilesystems=${value}";});

        # This is a list of sets: [ { "<filename>" = "<overrides>"; } { "<filename>" = "<overrides>"; } ]
        extra_overrides = map (set: concat_override (attrName set) (attrValue set)) cfg.extraOverride;

        # Global overrides

        global_default_overrides = [
          "/nix/store:ro"

          # TODO: There are irregular problems with flatpak app font antialiasing, I don't know where it comes from or when
          #       Also some icons are missing, even when icon dir is accessible
          #       I remember I did something one time that fixed it, but what was it :(?
          # NOTE: This doesn't help sadly, also steam can't launch with this because it wants to create a link to ~/.local/share/fonts?
          # "${config.home.homeDirectory}/.local/share/icons"
          # "${config.home.homeDirectory}/.local/share/fonts"

          # TODO: These are not necessary (Really?)
          # Make sure flatpaks are allowed to use the icons/fonts that are symlinked by icon/font fix
          # "/run/current-system/sw/share/X11/fonts:ro"
          # "/run/current-system/sw/share/icons:ro"
        ];

        global_overrides = builtins.concatLists [global_default_overrides cfg.extraGlobalOverride];

        str_global_overrides = builtins.concatStringsSep ";" global_overrides;
      in
        mkMerge ([
            {
              ".local/share/flatpak/overrides/global".text = "[Context]\nfilesystems=${str_global_overrides}";
            }
          ]
          ++ extra_overrides);

      home.activation = mkMerge [
        # TODO: Linking isn't always enough, some fonts should be copied aswell...
        # We link like this to be able to address the absolute location, also the fonts won't get copied to store
        # NOTE: This path contains all the fonts because fonts.fontDir.enable is true
        (mkIf cfg.fontFix {
          linkFontDir =
            lib.hm.dag.entryAfter ["writeBoundary"]
            (mkLink "/run/current-system/sw/share/X11/fonts" "${config.home.homeDirectory}/.local/share/fonts/fonts");
          copyBaseFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
            cp -f ${pkgs.lxgw-wenkai}/share/fonts/truetype/LXGWWenKaiMono-Regular.ttf ${config.home.homeDirectory}/.local/share/fonts/
            cp -f ${pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];}}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFontMono-Regular.ttf ${config.home.homeDirectory}/.local/share/fonts/
            cp -f ${pkgs.noto-fonts}/share/fonts/noto/NotoSans[wdth,wght].ttf ${config.home.homeDirectory}/.local/share/fonts/
            cp -f ${pkgs.noto-fonts-emoji}/share/fonts/noto/NotoColorEmoji.ttf ${config.home.homeDirectory}/.local/share/fonts/
          '';
        })
        (mkElse cfg.fontFix {
          unlinkFontDir =
            lib.hm.dag.entryAfter ["writeBoundary"]
            (mkUnlink "${config.home.homeDirectory}/.local/share/fonts/fonts");
          deleteBaseFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
            rm ${config.home.homeDirectory}/.local/share/fonts/LXGWWenKaiMono-Regular.ttf
            rm ${config.home.homeDirectory}/.local/share/fonts/JetBrainsMonoNerdFontMono-Regular.ttf
            rm ${config.home.homeDirectory}/.local/share/fonts/NotoSans[wdth,wght].ttf
            rm ${config.home.homeDirectory}/.local/share/fonts/NotoColorEmoji.ttf
          '';
        })

        # Fixes missing icons + cursor
        # NOTE: This path works because we have homeManager.useUserPackages = true (everything is stored in /etc/profiles/)
        (mkIf cfg.iconFix {
          linkIconDir =
            lib.hm.dag.entryAfter ["writeBoundary"]
            (mkLink "/etc/profiles/per-user/christoph/share/icons" "${config.home.homeDirectory}/.local/share/icons");
        })
        (mkElse cfg.iconFix {
          unlinkIconDir =
            lib.hm.dag.entryAfter ["writeBoundary"]
            (mkUnlink "${config.home.homeDirectory}/.local/share/icons");
        })

        # TODO: I should find a smarter way than this to make it easy to add flatpak options
        {
          # TODO: Enable this block only if any flatpak is enabled
          installFlatpaks = let
            to_install = builtins.concatLists [
              (optionals cfg.discord.enable ["com.discordapp.Discord"])
              (optionals cfg.spotify.enable ["com.spotify.Client"])
              (optionals cfg.flatseal.enable ["com.github.tchx84.Flatseal"])
              (optionals cfg.bottles.enable ["com.usebottles.bottles"])
              (optionals cfg.obsidian.enable ["md.obsidian.Obsidian"])
              (optionals cfg.jabref.enable ["org.jabref.Jabref"])
              cfg.extraInstall
            ];

            to_install_str = builtins.concatStringsSep " " to_install;
          in
            # Flatpak install can take a long time so we disconnect the process to not trigger the HM timeout (90s)
            lib.hm.dag.entryAfter ["writeBoundary"] ''
              sudo flatpak install -y ${to_install_str} &
            '';
        }

        {
          # TODO: Enable this block only if any flatpak is disabled
          removeFlatpaks = let
            to_remove = builtins.concatLists [
              (optionals (!cfg.discord.enable) ["com.discordapp.Discord"])
              (optionals (!cfg.spotify.enable) ["com.spotify.Client"])
              (optionals (!cfg.flatseal.enable) ["com.github.tchx84.Flatseal"])
              (optionals (!cfg.bottles.enable) ["com.usebottles.bottles"])
              (optionals (!cfg.obsidian.enable) ["md.obsidian.Obsidian"])
              (optionals (!cfg.jabref.enable) ["org.jabref.Jabref"])
              # Remove only the flatpaks that are not present in extraInstall
              (without cfg.extraRemove cfg.extraInstall)
            ];

            to_remove_str = builtins.concatStringsSep " " to_remove;
          in
            # By using || we make sure this command never throws any errors
            # Uninstallation is fast so HM timeout shouldn't be triggered
            lib.hm.dag.entryAfter ["writeBoundary"] ''
              sudo flatpak uninstall -y ${to_remove_str} || echo "Nothing to be removed"
            '';
        }

        (mkIf cfg.autoUpdate {
          # Flatpak install can take a long time so we disconnect the process to not trigger the HM timeout (90s)
          updateFlatpak = lib.hm.dag.entryAfter ["writeBoundary"] ''
            sudo flatpak update -y &
          '';
        })

        # Execute this after flatpak removal as there can be leftovers
        (mkIf cfg.autoPrune {
          pruneFlatpak = lib.hm.dag.entryAfter ["writeBoundary" "removeFlatpak"] ''
            sudo flatpak uninstall --unused -y
          '';
        })
      ];
    };
  }
