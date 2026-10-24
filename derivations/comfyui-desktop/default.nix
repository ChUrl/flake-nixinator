{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  appimageTools,
}: let
  pname = "comfyui-desktop";
  version = "1.1.8";

  # Todesktop only exposes a "latest" endpoint; there is no version-pinned URL.
  # Bump `version` and `hash` together (hash: `nix store prefetch-file <url>`).
  src = fetchurl {
    url = "https://download.comfy.org/linux/appimage/x64";
    hash = "sha256-Pz1LcQ7Nf2wNOku0Wh0M2KX1qo9NBTl1WAo94eu3UKc=";
  };

  # Upstream names everything after the todesktop app id, not the product.
  appName = "comfyui-desktop-2";

  appimageContents = appimageTools.extract {inherit pname version src;};

  # The AppImage is an Electron app, so run it in an FHS env.
  fhsEnv = appimageTools.wrapType2 {inherit pname version src;};
in
  stdenvNoCC.mkDerivation {
    inherit pname version;

    dontUnpack = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/1024x1024/apps

      # Upstream ships "AppRun --no-sandbox" in its desktop file: the extracted
      # AppImage loses the setuid chrome-sandbox helper. Add Wayland flags the
      # same way nixpkgs' `morgen` does.
      makeWrapper ${fhsEnv}/bin/${pname} $out/bin/${pname} \
        --add-flags "--no-sandbox" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}}"

      install -Dm644 ${appimageContents}/${appName}.desktop $out/share/applications/${appName}.desktop
      substituteInPlace $out/share/applications/${appName}.desktop \
        --replace-fail "Exec=AppRun --no-sandbox" "Exec=${pname}"

      install -Dm644 ${appimageContents}/usr/share/icons/hicolor/1024x1024/apps/${appName}.png \
        $out/share/icons/hicolor/1024x1024/apps/${appName}.png

      runHook postInstall
    '';

    meta = with lib; {
      description = "ComfyUI Desktop - official desktop application for ComfyUI";
      homepage = "https://www.comfy.org/";
      downloadPage = "https://www.comfy.org/download";
      license = licenses.gpl3Only;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
    };
  }
