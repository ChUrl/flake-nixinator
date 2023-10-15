{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  pkgs,
  gcc,
  glib,
  glibc,
  zlib
}:
stdenv.mkDerivation rec {
  pname = "decker";
  version = "0.13.4";

  src = fetchurl {
    url = "https://github.com/decker-edu/decker/releases/download/v0.13.4/${pname}-v${version}-Linux-X64";
    sha512 = "";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  dontBuild = true;

  buildInputs = [
    
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp ${pname}-v${version}-Linux-X64 $out/bin/decker
    runHook postInstall
  '';

  meta = with lib; {
    description = "A tool to create interactive web-based presentations.";
    homepage = "https://decker.cs.tu-dortmund.de";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
  };
}
