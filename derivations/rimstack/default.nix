{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
}: let
  pname = "rimstack";
  version = "1.0.1";
  src = fetchurl {
    url = "https://github.com/TheForgotten69/RimStack/releases/download/v${version}/RimStack-${version}-x86_64.AppImage";
    hash = "sha256-ClgMNU4sxdGey2lOeLfJldNyybXLJYM3N+U693fUKhM=";
  };
  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    nativeBuildInputs = [makeWrapper];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/rimstack.desktop \
        -t $out/share/applications
      substituteInPlace $out/share/applications/rimstack.desktop \
        --replace-fail 'Exec=rimstack' 'Exec=${pname}'
      install -m 444 -D ${appimageContents}/rimstack.svg \
        $out/share/icons/hicolor/scalable/apps/rimstack.svg

      # The bundled Qt lacks the Wayland shell-integration plugins, so the
      # AppImage's wayland platform plugin fails to initialize. Force xcb
      # (works via XWayland on Wayland sessions).
      wrapProgram $out/bin/${pname} \
        --set QT_QPA_PLATFORM xcb
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
