{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  SDL2,
  gtk3,
  readline,
}:
stdenv.mkDerivation {
  pname = "xemu";
  version = "20260129235930";

  src = fetchurl {
    url = "https://github.com/lgblgblgb/xemu-binaries/raw/binary-linux-master/xemu_current_amd64.deb";
    hash = "sha256-pioTtIpJDq9BaOL0lBZX7qEunuGkz+nSYpJa176ru80=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    SDL2
    gtk3
    readline
  ];

  unpackCmd = ''
    mkdir -p root
    dpkg-deb -x $curSrc root
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Collection of software emulations of some (mainly 8-bit) computers";
    longDescription = ''
      X-Emulators (Xemu) is a collection of software emulators targeting
      various computers, including the Commodore LCD, Commodore 65, MEGA65
      and Enterprise 128. It uses SDL2 and GTK3.
    '';
    homepage = "https://github.com/lgblgblgb/xemu";
    downloadPage = "https://github.lgb.hu/xemu/";
    license = licenses.gpl2Only;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
  };
}
