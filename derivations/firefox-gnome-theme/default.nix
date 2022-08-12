# Taken from https://github.com/tadfisher/flake/blob/main/pkgs/firefox-gnome-theme/default.nix

# We don't use fetchTarbal or fetchFromGithub because we are using flakes:
# - Specify the firefox-gnome-theme github repo as input in flake.nix
# - We don't need to add sha256 or commit revision because it is automatically locked in flake.lock
# - Pass the input to overlays/default.nix and from there to derivations/default.nix
# - There we plug the input into the src argument of this derivation

{ lib, stdenv, src }:

stdenv.mkDerivation {
  pname = "firefox-gnome-theme";
  version = "unstable";

  inherit src;

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/firefox-gnome-theme
    cp -r theme/* $out/share/firefox-gnome-theme
  '';

  meta = with lib; {
    description = "A GNOME theme for Firefox";
    homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    license = licenses.unlicense;
  };
}