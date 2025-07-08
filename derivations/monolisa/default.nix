{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "monolisa";
  version = "2.016";

  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    tar -xzf fonts.tar.gz -C $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Programming Font with Ligatures and Cursives";
    homepage = "https://www.monolisa.dev/";
    license = licenses.mit;
  };
}
