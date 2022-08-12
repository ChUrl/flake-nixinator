{ config, nixosConfig, lib, mylib, pkgs, ... }:

with lib;
with mylib.modules;

let
  cfg = config.modules.ranger;
in {

  options.modules.ranger = {
    enable = mkEnableOpt "Ranger";
    preview = mkBoolOpt false "Enable Ranger image preview";
  };

  # TODO: Ranger configuration

  config = mkIf cfg.enable {
    home.packages = with pkgs; lib.concatLists [
      [
        ranger
        atool
        p7zip
        zip
        unzip
        unrar
        libarchive
        exiftool
        mediainfo
      ]
      (optionals cfg.preview [
        # ueberzug # Only X11
        python310Packages.pillow
        ffmpegthumbnailer
        imagemagick
        poppler_utils
      ])
    ];

    home.file = mkMerge [
      {
        ".config/ranger/rc.conf".text = let
          # TODO: Why does mkMerge don't work here?
          settings = {
            column_ratios = "1,1";
            vcs_aware = "true";
            preview_images_method = "kitty"; # TODO: Only if kitty enabled
            unicode_ellipsis = "true";
            draw_borders = (if cfg.preview then "none" else "both"); # doesn't work well with preview
            line_numbers = "relative";
            preview_images = (if cfg.preview then "true" else "false");
            use_preview_script = (if cfg.preview then "true" else "false");
          } // (optionalAttrs cfg.preview {
            preview_script = "${config.home.homeDirectory}/.config/ranger/scope.sh";
          });

          # The settings { column_ratios = "1,1"; } get turned into { column_ratios = "set column_ratios = 1,1"; }
          settings_in_values = mapAttrs (name: value: concatStringsSep " " ["set" name value]) settings;

          # Results in [ "set column_rations = 1,1" ]
          settings_list = attrValues settings_in_values;

          settings_str = concatStringsSep "\n" settings_list;
        in settings_str;
      }

      (optionalAttrs cfg.preview {
        ".config/ranger/scope.sh".source = mkIf cfg.preview ../../config/ranger/scope.sh;
      })
    ];
  };
}
