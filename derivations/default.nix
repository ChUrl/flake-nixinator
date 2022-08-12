{ inputs, pkgs }:

{
  # vital-synth = pkgs.callPackage ./vital-synth {}; # Kept as an example, don't know if I will fix this or keep using distrho
  cyberdrop-dl = pkgs.callPackage ./cyberdrop-dl {};
  firefox-gnome-theme = pkgs.callPackage ./firefox-gnome-theme { src = inputs.firefox-gnome-theme; };
  adwaita-for-steam = pkgs.callPackage ./adwaita-for-steam { src = inputs.adwaita-for-steam; };
}