{
  config,
  lib,
  mylib,
  pkgs,
  ...
}: let
  inherit (config.modules) fonts;
in {
  options.modules.fonts = import ./options.nix {inherit lib mylib;};

  config = lib.mkIf fonts.enable {
    fonts = {
      # Some default fonts for unicode coverage
      enableDefaultPackages = true;

      # Puts fonts to /run/current-system/sw/share/X11/fonts
      # https://wiki.nixos.org/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
      fontDir.enable = true;

      # Font packages go here.
      # They are installed system-wide so they land in fontdir,
      # this is required for flatpak to find them.
      packages = with pkgs; [
        # Monospace fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.victor-mono
        monolisa

        # Sans/Serif fonts
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        lxgw-wenkai
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        hinting.enable = true;
        hinting.autohint = true;
        cache32Bit = true;

        # https://wiki.nixos.org/wiki/Fonts#Noto_Color_Emoji_doesn.27t_render_on_Firefox
        useEmbeddedBitmaps = true;

        defaultFonts = {
          serif = [fonts.defaultSerifFont] ++ fonts.fallbackSerifFonts;
          sansSerif = [fonts.defaultSansSerifFont] ++ fonts.fallbackSansSerifFonts;
          monospace = [fonts.defaultMonoFont] ++ fonts.fallbackMonoFonts;
        };
      };
    };
  };
}
