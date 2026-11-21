{
  lib,
  stdenv,
  requireFile,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  perl,
  glib,
  gtk3,
  gtkmm3,
  atkmm_2_36,
  cairomm_1_0,
  pangomm_1_4,
  glibmm_2_4,
  libsigcxx_2_0,
  libbsd,
  libuuid,
  libX11,
  webkitgtk_4_1,
  libsoup_3,
  nss,
  nspr,
  curl,
  openssl,
  procps,
  util-linux,
  coreutils,
  gnugrep,
  gnused,
  gawk,
  nettools,
  zip,
  systemd,
  iproute2,
}:
stdenv.mkDerivation rec {
  pname = "ivanti-secure-access";
  version = "25.1.0-b1399";

  # The download is behind the university's SSO (an HTML login page is served
  # to anonymous clients), so it cannot be fetched automatically. Put the deb
  # into the Nix store once:
  #
  #   nix-store --add-fixed sha256 ~/ps-pulse-linux-25.1.0-b1399-64bit-installer.deb
  #
  # To update: adjust version/hash and re-run the command with the new file.
  src = requireFile {
    name = "ps-pulse-linux-25.1.0-b1399-64bit-installer.deb";
    url = "https://service.tu-dortmund.de/documents/d/intra/ps-pulse-linux-25-1-0-b1399-64bit-installer-deb";
    hash = "sha256-Ap8mTUeHXBQ6TI3HuHLjlRFuLM80kXGkcx37hv7KpVY=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    perl
  ];

  buildInputs = [
    glib
    gtk3
    gtkmm3
    atkmm_2_36
    cairomm_1_0
    pangomm_1_4
    glibmm_2_4
    libsigcxx_2_0
    libbsd
    libuuid
    libX11
    webkitgtk_4_1
    libsoup_3
    nss
    nspr
    curl
    openssl
  ];

  # The binaries and their plugin configuration reference /opt/pulsesecure
  # unconditionally. The NixOS module copies this tree to a writable location
  # and points /opt/pulsesecure at it.
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r opt/pulsesecure $out/opt/pulsesecure

    # The deb's postinst picks the WebKit based UI for Debian/Ubuntu.
    cp $out/opt/pulsesecure/bin/pulseUI.webkit41 $out/opt/pulsesecure/bin/pulseUI

    # Scripts expect a Debian filesystem layout.
    patchShebangs $out/opt/pulsesecure/bin
    substituteInPlace $out/opt/pulsesecure/bin/startup.sh \
      --replace-fail /usr/bin/pgrep ${procps}/bin/pgrep \
      --replace-fail /usr/bin/logger ${util-linux}/bin/logger \
      --replace-fail /usr/bin/kill ${util-linux}/bin/kill

    # LogsAndDiagnostics.sh and certificate_installer.sh look commands up in
    # Debian's /usr/bin etc. Locate them through PATH instead and hardcode a
    # working echo. Missing diagnostics tools just produce empty report files.
    for script in LogsAndDiagnostics.sh certificate_installer.sh; do
      perl -0pi -e 's#if \[ -e /usr/bin/echo \];.*?\nfi\n#ECHO=${coreutils}/bin/echo\n#s' \
        $out/opt/pulsesecure/bin/$script
      perl -0pi -e 's#full_path_command\(\) \{.*?\n\}\n#full_path_command() { command -v "\$1" || true; }\n#s' \
        $out/opt/pulsesecure/bin/$script
    done

    # The installer is useless (and dangerous) on NixOS: dependencies are
    # provided by Nix, and it would try to run apt/dpkg.
    rm -f $out/opt/pulsesecure/bin/package_installer.sh \
          $out/opt/pulsesecure/bin/setup_cef.sh

    install -d $out/bin
    for prog in pulsesecure pulselauncher jamCommand; do
      makeWrapper $out/opt/pulsesecure/bin/$prog $out/bin/$prog
    done

    install -d $out/share/applications
    cat > $out/share/applications/ivanti-secure-access.desktop <<EOF
    [Desktop Entry]
    Version=1.0
    Name=Ivanti Secure Access Client
    Comment=Ivanti Secure Access Client for Linux
    Exec=pulseUI
    Icon=$out/opt/pulsesecure/resource/ivanti.png
    Terminal=false
    Type=Application
    Categories=Network;Security;
    StartupWMClass=pulseUI
    Keywords=Pulse;Ivanti;ISAC;VPN;
    EOF

    install -d $out/share/dbus-1/system.d
    cp $out/opt/pulsesecure/lib/JUNS/net.psecure.pulse.conf $out/share/dbus-1/system.d/

    runHook postInstall
  '';

  # Make the binaries find the libraries shipped next to them and the Nix
  # versions of their external dependencies.
  preFixup = ''
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/JUNS
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/dsOpenSSL
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/dispatch
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/ConnectionManager
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/ConnectionStore
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/eapService
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/iveConnectionMethod
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/JamUI
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/TnccPlugin
    addAutoPatchelfSearchPath $out/opt/pulsesecure/lib/TunnelManager
  '';

  dontWrapGApps = true;

  postFixup = ''
    makeWrapper $out/opt/pulsesecure/bin/pulseUI $out/bin/pulseUI \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [
      coreutils
      gawk
      gnugrep
      gnused
      iproute2
      nettools
      nss.tools
      openssl
      procps
      systemd
      util-linux
      zip
    ]}
  '';

  meta = {
    description = "Ivanti Secure Access Client (Pulse Secure)";
    homepage = "https://www.ivanti.com/products/secure-access-client";
    license = lib.licenses.unfree;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    platforms = ["x86_64-linux"];
    mainProgram = "pulseUI";
  };
}
