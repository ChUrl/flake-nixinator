{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  bzip2,
  ncurses,
  gmp
}:
stdenv.mkDerivation rec {
  pname = "decker";
  version = "0.13.4";

  src = fetchurl {
    url = "https://github.com/decker-edu/decker/releases/download/v0.13.4/${pname}-v${version}-Linux-X64";
    sha256 = "sha256-LZ0j2X0zCP9XsWglc488nL25w3VmWh/TYxK1x6K6yOI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  unpackCmd = ''
    mkdir -p root
    cp $curSrc root/decker
  '';

  dontBuild = true;

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    bzip2
    ncurses
    gmp
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp decker $out/bin/decker
    chmod +x $out/bin/decker
    runHook postInstall
  '';

  meta = with lib; {
    description = "A tool to create interactive web-based presentations.";
    homepage = "https://decker.cs.tu-dortmund.de";
    license = licenses.gpl3Only;
    platforms = ["x86_64-linux"];
  };
}
