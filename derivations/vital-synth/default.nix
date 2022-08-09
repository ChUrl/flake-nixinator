{ stdenv , fetchurl, alsa-lib, freetype, glib, glibc, libcurl-gnutls, libgl, libglvnd, libsecret }:

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

  # - wrapGAppsHook will add the applications share directory to XDG_DATA_DIRS
  #   It is also used to populate many environment variables related to icon themes etc.
  # - makeWrapper allows to add environment variables and other stuff to the application, like a closure
  # TODO: Is wrapGAppsHook needed?
  nativeBuildInputs = [ dpkg makeWrapper wrapGAppsHook ];

  # We downloaded a .deb file, unpack it to root = [ usr/bin usr/lib usr/share ]
  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';

  dontBuild = true;
  dontWrapGApps = true; # we only want $gappsWrapperArgs here

  # From AUR pkgbuild:
  # depends=('alsa-lib>=1.0.16' 'freetype2>=2.2.1' 'gcc-libs' 'gcc>=3.3.1' 'glib2>=2.12.0' 'glibc>=2.17'
  #          'libcurl-gnutls>=7.16.2' 'libgl' 'libglvnd' 'libsecret>=0.7')
  # TODO: Verify every single dependency
  buildInputs = [
    alsa-lib freetype glib glibc libcurl-gnutls libgl libglvnd libsecret stdenv.cc.cc.lib
  ];

  # Copy the contents of the .deb package to the $out directory that nix creates for built derivations
  # Very simple as the vital .deb has a very basic format (only [ usr/bin usr/lib usr/share ])
  installPhase = ''
    runHook preInstall

    cp -r usr/* $out/
    chmod +x $out/bin/vital

    runHook postInstall
  '';
  # This was also in the bitwig-studio example but I don't think it is needed as the .desktop
  # file doesn't contain absolute paths to the executable.
  # Also it probably requires that the .desktop file isn't already in $out/share/applications,
  # but I copied it there already by copying all the contents from usr/
  # substitute usr/share/applications/vital.desktop \
  #   $out/share/applications/vital.desktop \
  #   --replace /usr/bin/vital $out/bin/vital

  # This is taken from the bitwig-studio example and I don't fully understand it...
  # Basically the output path is searched for executables, these are then pached/linked with the
  # needed libraries. These libraries are then provided through the LD_LIBRARY_PATH
  postFixup = ''
    # Find all executables that should be patched
    find $out -type f -executable \
      -not -name '*.so.*' \
      -not -name '*.so' \

    while IFS= read -r f ; do
      # I don't exactly understand this, have to read up on patchelf
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f

      wrapProgram $f \
        # I don't know what this does
        "''${gappsWrapperArgs[@]}" \

        # I don't know what binaries are needed for vital, probably not these
        # --prefix PATH : "${lib.makeBinPath [ xdg-utils ffmpeg ]}" \

        # We build the library path from our enabled buildInputs
        --suffix LD_LIBRARY_PATH : "${lib.strings.makeLibraryPath buildInputs}"
    done
  '';
  # This is specific for bitwig-studio derivation
  # find $out -type f -executable -name 'jspawnhelper' | \
  # while IFS= read -r f ; do
  #   patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f
  # done

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