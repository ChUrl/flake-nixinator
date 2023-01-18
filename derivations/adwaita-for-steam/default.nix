{
  lib,
  stdenv,
  src,
}:
stdenv.mkDerivation {
  pname = "adwaita-for-steam";
  version = "unstable";

  inherit src;

  dontConfigure = true;
  dontBuild = true;
  doCheck = false;

  installPhase = ''
    mkdir -p $out/share/adwaita-for-steam
    cp -r Adwaita $out/share/adwaita-for-steam/
  '';

  meta = with lib; {
    description = "A GNOME theme for Steam";
    homepage = "https://github.com/tkashkin/Adwaita-for-Steam";
    license = licenses.mit;
  };
}
