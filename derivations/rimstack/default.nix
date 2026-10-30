{
  lib,
  appimageTools,
  fetchurl,
}: let
  pname = "rimstack";
  version = "1.1.0";
  src = fetchurl {
    url = "https://github.com/TheForgotten69/RimStack/releases/download/v${version}/RimStack-${version}-x86_64.AppImage";
    hash = "sha256-1rpQkLNXyrX7S/E0TriB4vRjg3CJ8xnaPXQsrNoP/dA=";
  };
  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraBwrapArgs = [
      "--setenv"
      "APPIMAGE"
      (placeholder "out")
    ];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/rimstack.desktop \
        -t $out/share/applications
      install -m 444 -D ${appimageContents}/rimstack.svg \
        $out/share/icons/hicolor/scalable/apps/rimstack.svg
    '';

    meta = with lib; {
      description = "A fast RimWorld mod manager written in Rust";
      homepage = "https://theforgotten69.github.io/RimStack/";
      downloadPage = "https://github.com/TheForgotten69/RimStack/releases";
      license = licenses.gpl3Only;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = pname;
    };
  }
