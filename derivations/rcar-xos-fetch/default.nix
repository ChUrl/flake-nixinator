# TUI to list the R-Car xOS SDK versions on the Renesas Artifactory (jfrog-cli)
# and print their derivations/rcar-xos/versions.nix entries from the published
# SHA512 files. The archives themselves are downloaded by Nix. See ./rcar-xos-fetch.py.
#
# tokenFile is the default for --token-file (the sops secret path on the host).
# nix/nix-store (versions.nix evaluation, store status) come from the system.
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
    description = "Print versions.nix entries for R-Car xOS SDK versions on Artifactory";
    license = lib.licenses.mit;
    mainProgram = "rcar-xos-fetch";
    platforms = lib.platforms.linux;
  };
}
