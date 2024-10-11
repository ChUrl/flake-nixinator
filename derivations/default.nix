{
  inputs,
  pkgs,
  ...
}: {
  # vital-synth = pkgs.callPackage ./vital-synth {}; # Kept as an example, don't know if I will fix this or keep using distrho
  # adwaita-for-steam = pkgs.callPackage ./adwaita-for-steam {src = inputs.adwaita-for-steam;};
  # dconf-editor-wrapped = pkgs.callPackage ./dconf-editor-wrapped {};
  # modules-options-doc = pkgs.callPackage ./modules-options-doc {mylib = mylib;}; # TODO: Borked
  # spotdl-4_1_6 = pkgs.callPackage ./spotdl-4_1_6 {}; # TODO: Old
  # wiiu-downloader = pkgs.callPackage ./wiiu-downloader {};

  # TODO: Those were enabled, but have to be rewritten for standalone HM
  # dell-b1160w = pkgs.callPackage ./dell-b1160w {};
  # firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme {src = inputs.firefox-gnome-theme;};
  # xdg-desktop-portal-termfilechooser = pkgs.callPackage ./xdg-desktop-portal-termfilechooser {};
  # decker = pkgs.callPackage ./decker {};
}
