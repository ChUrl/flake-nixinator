{
  inputs,
  pkgs,
}: {
  # vital-synth = pkgs.callPackage ./vital-synth {}; # Kept as an example, don't know if I will fix this or keep using distrho
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme {src = inputs.firefox-gnome-theme;};
  adwaita-for-steam = pkgs.callPackage ./adwaita-for-steam {src = inputs.adwaita-for-steam;};
  dconf-editor-wrapped = pkgs.callPackage ./dconf-editor-wrapped {};
  dell-b1160w = pkgs.callPackage ./dell-b1160w {};
  xdg-desktop-portal-termfilechooser = pkgs.callPackage ./xdg-desktop-portal-termfilechooser {};
}
