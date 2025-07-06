{
  lib,
  stdenv,
  stdenvNoCC,
}:
stdenv.mkDerivation {
  pname = "TEMPLATE";
  version = "";

  src = ./.;

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    touch $out/TEMPLATE

    runHook postInstall
  '';

  meta = with lib; {
    description = "TEMPLATE";
    homepage = "TEMPLATE";
    license = licenses.mit;
  };
}
# Or without cc:
# stdenvNoCC.mkDerivation {
#   pname = "TEMPLATE";
#   version = "";
#
#   src = ./.;
#
#   installPhase = ''
#     runHook preInstall
#
#     mkdir -p $out
#     touch $out/TEMPLATE
#
#     runHook postInstall
#   '';
#
#   meta = with lib; {
#     description = "TEMPLATE";
#     homepage = "TEMPLATE";
#     license = licenses.mit;
#   };
# }
