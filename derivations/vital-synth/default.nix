# Has a problem with vertically offset UI, replaced by distrho for now but kept as an example

# Damn I hate this style
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, alsa-lib
, freetype
, gcc
, glib
, glibc
, curlWithGnuTls
, libGL
, libglvnd
, libsecret
}:

# Adapted from https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=vital-synth
# Example https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/audio/bitwig-studio/bitwig-studio4.nix

let
  # Variables from AUR pkgbuild
  maintainer = "jackreeds";
  pkgname_deb = "VitalInstaller";

in stdenv.mkDerivation rec {
  pname = "vital-synth";
  version = "1.0.8";

  src = fetchurl {
    url = "https://github.com/${maintainer}/${pkgname_deb}/releases/download/${version}/${pkgname_deb}.deb";
    sha512 = "829d29a0c41ac9f79ca6d069e2e4f404a501abdcdc487fbb4e1e8afd44bf870c6c41095587c98f810fb946d946179468f8d5f417e67785313152a1613cf4a832";
  };

  # autoPatchelfHook patches the binary to use the dynamic loader and "tells it" where all the libraries are that
  # the program wants to dynamically load at runtime.
  # This is necessary because NixOS doesn't have the linux typical static location where these libraries are placed,
  # so the binary needs the correct paths to the nix store for each one.
  # autoPatchelfHook propagates all the buildInputs so they are available at runtime.
  # View also:
  # https://nixos.org/manual/nixpkgs/unstable/#setup-hook-autopatchelfhook
  # https://nixos.wiki/wiki/Packaging/Binaries
  # https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  # We downloaded a .deb file, unpack it to root = [ usr/bin usr/lib usr/share ]
  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';

  # This is already built
  dontBuild = true;

  # From AUR pkgbuild:
  # depends=('alsa-lib>=1.0.16' 'freetype2>=2.2.1' 'gcc-libs' 'gcc>=3.3.1' 'glib2>=2.12.0' 'glibc>=2.17'
  #          'libcurl-gnutls>=7.16.2' 'libgl' 'libglvnd' 'libsecret>=0.7')
  buildInputs = [
    alsa-lib freetype gcc.cc.lib gcc.cc glib glibc curlWithGnuTls libGL libglvnd libsecret
  ];

  # Copy the contents of the .deb package to the $out directory that nix creates for built derivations
  # Very simple as the vital .deb has a very basic format (only [ usr/bin usr/lib usr/share ])
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    chmod +x $out/bin/vital
    runHook postInstall
  '';

  meta = with lib; {
    description = "A wavetable synthesizer.";
    longDescription = ''
      Powerful wavetable synthesizer with realtime modulation feedback.
      Vital is a MIDI enabled polyphonic music synthesizer with an easy to use
      parameter modulation system with real-time graphical feedback.
    '';
    homepage = "https://vital.audio/";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}