{
  lib,
  stdenv,
  pkgs,
  fetchurl,
  fetchFromGitHub,
  gsettings-desktop-schemas,
  gtk3
}:

# TODO: This doesn't run. Why does it work like this (APPIMAGE_DEBUG_EXEC=bash appimage-run WiiUDownloader-Linux-x86_64.AppImage) though?
# pkgs.appimageTools.wrapType2 rec {
#   name = "WiiUDownloader";
#   version = "v1.32";

#   src = fetchurl {
#     url = "https://github.com/Xpl0itU/WiiUDownloader/releases/download/${version}/WiiUDownloader-Linux-x86_64.AppImage";
#     sha256 = "sha256-YWLQd/Wmz5BDyc+oe6JQkT849DaPc5HtJXIDZKUdHNE=";
#   };

#   profile = ''
#     export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
#   '';

#   # extraPkgs = pkgs: with pkgs; [
#   # ];
# }
let
  titlesfile = fetchurl {
    url = "https://napi.nbg01.v10lator.de/db";
    sha256 = "sha256-7B37evlqSE9ZmUM3bND+/I8IUhU4kbvIfwtGrNu0i9A=";
    curlOptsList = ["--user-agent" "NUSspliBuilder/2.1"];
  };

  wiiu-downloader = stdenv.mkDerivation {
    name = "WiiUDownloader";

    src = fetchFromGitHub {
      owner = "Xpl0itU";
      repo = "WiiUDownloader";
      rev = "v1.32";

      # NOTE: When supplying the hash without submodules for fetchFromGitHub with fetchSubmodules = true, the derivation
      #       will just fail, without a hash mismatch but empty submodule directories!!!
      sha256 = "sha256-R3FiNiK27Q2x5HbHmWw3F4LPJNKz5BAoOyl4fYAEQlc=";

      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      gcc
      gnumake
      cmake
      pkg-config
      python310
    ];

    buildInputs = with pkgs; [
      gsettings-desktop-schemas
      gtk3
      gtkmm3
      mbedtls
      curl
    ];

    dontUseCmakeConfigure = true;

    patches = [
      ./gtitles.patch
    ];

    buildPhase = ''
      cp ${titlesfile} src/gtitles.c
      python build.py
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp build/WiiUDownloader $out/bin

      runHook postInstall
    '';
  };
in pkgs.writeShellScriptBin "wiiu-downloader-wrapped" ''
  XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS" ${wiiu-downloader}/bin/WiiUDownloader
''
