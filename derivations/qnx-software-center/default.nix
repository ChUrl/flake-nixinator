# QNX Software Center (Eclipse RCP application with a bundled JRE).
#
# The installer cannot be downloaded automatically (myQNX login required), so
# it has to be added to the store by hand once:
#
#   nix-store --add-fixed sha256 ~/Downloads/qnx-setup-2.0.4-202501021438-linux.run
#
# The makeself archive is unpacked at build time (--noexec, the start.sh would
# only copy it to ~/qnx anyway). The prebuilt binaries expect an FHS layout,
# hence buildFHSEnv. The install tree is read-only, so the wrapper copies the
# Eclipse configuration area to ~/.qnx/qnxsoftwarecenter-<version> on first run.
{
  lib,
  stdenvNoCC,
  requireFile,
  buildFHSEnv,
  writeShellScript,
  makeDesktopItem,
}: let
  version = "2.0.4";
  installerName = "qnx-setup-${version}-202501021438-linux.run";

  src = requireFile {
    name = installerName;
    sha256 = "5695a0ec8a1fd91840753b2cba86a9325f6052d4f69c757166cc61b09bcbe507";
    message = ''
      The QNX Software Center installer cannot be downloaded automatically.
      Download ${installerName} from https://www.qnx.com/download/ (myQNX login)
      and add it to the Nix store:

        nix-store --add-fixed sha256 ~/Downloads/${installerName}

      (or: nix-prefetch-url --type sha256 file://$HOME/Downloads/${installerName})
    '';
  };

  unpacked = stdenvNoCC.mkDerivation {
    pname = "qnx-software-center-unwrapped";
    inherit version src;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true; # keep the binaries untouched, the FHS env provides the loader

    installPhase = ''
      runHook preInstall

      sh $src --noexec --target extracted > /dev/null
      mkdir -p $out/opt
      cp -r extracted/qnxsoftwarecenter $out/opt/qnxsoftwarecenter
      chmod -R u+w $out/opt
      install -Dm644 extracted/qnxsoftwarecenter/icon.xpm $out/share/pixmaps/qnx-software-center.xpm

      runHook postInstall
    '';
  };

  launcher = writeShellScript "qnx-software-center-launcher" ''
    root=${unpacked}/opt/qnxsoftwarecenter
    state="''${QNX_SWC_HOME:-$HOME/.qnx/qnxsoftwarecenter-${version}}"

    if [ ! -d "$state/configuration" ]; then
      mkdir -p "$state"
      cp -r --no-preserve=mode,ownership "$root/configuration" "$state/configuration"
    fi
    mkdir -p "$state/workspace"

    exec "$root/qnxsoftwarecenter" \
      -configuration "file:$state/configuration" \
      -data "$state/workspace" \
      "$@"
  '';
in
  buildFHSEnv {
    pname = "qnx-software-center";
    inherit version;

    runScript = launcher;

    targetPkgs = pkgs:
      with pkgs; [
        # Eclipse / SWT (GTK3)
        gtk3
        glib
        gsettings-desktop-schemas
        adwaita-icon-theme
        cairo
        pango
        gdk-pixbuf
        atk
        at-spi2-atk
        dbus
        webkitgtk_4_1
        libsoup_3
        # Bundled Chromium (swt.browser.chromium) and the JRE's AWT
        nss
        nspr
        alsa-lib
        cups
        expat
        fontconfig
        freetype
        libdrm
        libgbm
        libGL
        mesa
        libxkbcommon
        xorg.libX11
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXi
        xorg.libXrandr
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        # The installer scripts and qnxsoftwarecenter_clt
        bash
        coreutils
        gnugrep
        gnused
        gawk
        zlib
        stdenv.cc.cc.lib
        # Used when installing packages (license/ssl)
        openssl
        curl
        which
        unzip
        gnutar
        gzip
      ];

    extraInstallCommands = ''
      install -Dm644 ${unpacked}/share/pixmaps/qnx-software-center.xpm \
        $out/share/pixmaps/qnx-software-center.xpm
      install -Dm644 ${makeDesktopItem {
        name = "qnx-software-center";
        desktopName = "QNX Software Center";
        exec = "qnx-software-center";
        icon = "qnx-software-center";
        categories = ["Development"];
      }}/share/applications/qnx-software-center.desktop \
        $out/share/applications/qnx-software-center.desktop
    '';

    meta = {
      description = "QNX Software Center, the package manager for QNX SDP";
      homepage = "https://www.qnx.com/products/everywhere/";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "qnx-software-center";
    };
  }
