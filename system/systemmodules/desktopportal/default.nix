{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.systemmodules) desktopportal;
in {
  options.systemmodules.desktopportal = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf desktopportal.enable {
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        wlr.enable = true;

        # TODO: Replace lib.optional(s) throughout the config with mkMerge
        config = lib.mkMerge [
          {
            # https://discourse.nixos.org/t/clicked-links-in-desktop-apps-not-opening-browers/29114/26
            common.default = ["*"];
          }

          (lib.mkIf desktopportal.termfilechooser.enable {
            common."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
          })

          (lib.mkIf desktopportal.hyprland.enable {
            hyprland.default = ["hyprland"];
          })

          (lib.mkIf
            (desktopportal.hyprland.enable && desktopportal.termfilechooser.enable) {
              hyprland."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
            })

          (lib.mkIf desktopportal.niri.enable {
            niri.default = ["gtk" "gnome"];
          })

          (lib.mkIf (desktopportal.niri.enable && desktopportal.termfilechooser.enable) {
            niri."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
          })
        ];

        extraPortals = with pkgs;
          lib.mkMerge [
            [
              xdg-desktop-portal-gtk # Fallback
            ]

            # We don't need to install that explicitly
            # (lib.mkIf desktopportal.hyprland.enable [
            #   xdg-desktop-portal-hyprland
            # ])

            (lib.mkIf desktopportal.termfilechooser.enable [
              xdg-desktop-portal-termfilechooser # Filechooser using yazi
            ])
          ];
      };
    };
  };
}
