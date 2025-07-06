{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "monolisa";
  version = "1.0";

  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    mv MonoLisa-italic.ttf $out/share/fonts/truetype/
    mv MonoLisa-normal.ttf $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Programming Font with Ligatures and Cursives";
    homepage = "https://www.monolisa.dev/";
    license = licenses.mit;
  };
}
