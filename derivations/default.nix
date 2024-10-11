{
  inputs,
  pkgs,
  ...
}: {
  # I am currently not using any custom derivations.
  # Old derivations are still kept in this folder, for reference.

  # modules-options-doc = pkgs.callPackage ./modules-options-doc {mylib = mylib;};
  # xdg-desktop-portal-termfilechooser = pkgs.callPackage ./xdg-desktop-portal-termfilechooser {};
  # decker = pkgs.callPackage ./decker {};
}
