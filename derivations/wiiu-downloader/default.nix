{
  lib,
  stdenv,
  pkgs,
  fetchurl
}:
pkgs.appimageTools.wrapType2 rec {
  name = "WiiUDownloader";
  version = "v1.32";

  src = fetchurl {
    url = "https://github.com/Xpl0itU/WiiUDownloader/releases/download/${version}/WiiUDownloader-Linux-x86_64.AppImage";
    sha256 = "";
  };

  extraPackages = with pkgs; [];
}
