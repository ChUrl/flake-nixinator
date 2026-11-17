# TUI to download R-Car xOS SDK archives from the Renesas Artifactory (jfrog-cli),
# add them to the store and print the matching derivations/rcar-xos/versions.nix
# entries. See ./rcar-xos-fetch.py.
#
# tokenFile is the default for --token-file (the sops secret path on the host).
# nix-store/nix are taken from the system, not bundled.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  python3,
  jfrog-cli,
  tokenFile ? null,
}:
stdenvNoCC.mkDerivation {
  pname = "rcar-xos-fetch";
  version = "1.0";

  src = ./rcar-xos-fetch.py;
  dontUnpack = true;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/libexec/rcar-xos-fetch.py
    makeWrapper ${python3.interpreter} $out/bin/rcar-xos-fetch \
      --add-flags "-I $out/libexec/rcar-xos-fetch.py" \
      --prefix PATH : ${lib.makeBinPath [jfrog-cli]} \
      ${lib.optionalString (tokenFile != null) "--set-default RCAR_XOS_TOKEN_FILE ${tokenFile}"}

    runHook postInstall
  '';

  meta = {
    description = "Download R-Car xOS SDK archives from Artifactory into the Nix store";
    license = lib.licenses.mit;
    mainProgram = "rcar-xos-fetch";
    platforms = lib.platforms.linux;
  };
}
