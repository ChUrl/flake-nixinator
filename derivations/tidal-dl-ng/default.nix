# https://github.com/exislow/tidal-dl-ng/issues/472
# https://gist.github.com/xaolanx/4c88d0cbc0dee90764bae767006103f8
{
  lib,
  stdenv,
  pkgs,
}: let
  #
  # Dependencies
  #
  requests_2_32_4 = pkgs.python3Packages.requests.overridePythonAttrs (old: {
    version = "2.32.4";
    src = pkgs.python3Packages.fetchPypi {
      inherit (old) pname;
      version = "2.32.4";
      sha256 = "sha256-J9AxZoLIopg00yZIIAJLYqNpQgg9Usry8UwFkTNtNCI=";
    };
    patches =
      builtins.filter (
        p: !pkgs.lib.strings.hasInfix "CVE-2024-47081" (toString p)
      )
      old.patches;
  });

  pycryptodome_3_23_0 = pkgs.python3Packages.pycryptodome.overridePythonAttrs (old: {
    version = "3.23.0";
    src = pkgs.python3Packages.fetchPypi {
      inherit (old) pname;
      version = "3.23.0";
      sha256 = "sha256-RHcAplcYLWAzi6sJ/bJ1GPiFauzYCuTGvd22f/XaRO8=";
    };
  });

  pathvalidate_3_3_1 = pkgs.python3Packages.pathvalidate.overridePythonAttrs (old: {
    version = "3.3.1";
    src = pkgs.python3Packages.fetchPypi {
      inherit (old) pname;
      version = "3.3.1";
      sha256 = "sha256-sYwHISv+rWJDRbuOHWFBzc8Vo5c2mU6guUA1rSsboXc=";
    };
  });

  typer_0_16_0 = pkgs.python3Packages.typer.overridePythonAttrs (old: {
    version = "0.16.0";
    src = pkgs.python3Packages.fetchPypi {
      inherit (old) pname;
      version = "0.16.0";
      sha256 = "sha256-rzd/+u4dvjeulEDLTo8RaG6lzk6brgG4SufGO4fx3Ts=";
    };
  });

  tidalDlNg = pkgs.python3Packages.buildPythonApplication rec {
    pname = "tidal-dl-ng";
    version = "0.26.2";
    format = "pyproject";

    src = pkgs.fetchFromGitHub {
      owner = "exislow";
      repo = "tidal-dl-ng";
      rev = "v${version}";
      sha256 = "sha256-9C7IpLKeR08/nMbePltwGrzIgXfdaVfyOeFQnfCwMKg=";
    };

    doCheck = false;
    catchConflicts = false;

    nativeBuildInputs = with pkgs.python3Packages; [poetry-core setuptools];

    propagatedBuildInputs = with pkgs.python3Packages; [
      requests_2_32_4
      coloredlogs
      dataclasses-json
      m3u8
      mpegdash
      mutagen
      pathvalidate_3_3_1
      pycryptodome_3_23_0
      python-ffmpeg
      rich
      tidalapi
      toml
      typer_0_16_0
      pyside6
      pyqtdarktheme
    ];

    # pythonOutputDistPhase = ''
    #   echo "⚠️Skipping pythonOutputDistPhase"
    # '';
    # pythonCatchConflictsPhase = ''
    #   echo "🛑 Skipping pythonCatchConflictsPhase"
    # '';
  };

  #
  # Wrapped applications
  #

  tidal-dl-ng = pkgs.writeShellApplication {
    name = "tdn";
    runtimeInputs = [tidalDlNg];
    text = ''exec tidal-dl-ng "$@"'';
  };

  tidal-dl-ng-gui = pkgs.writeShellApplication {
    name = "tdng";
    runtimeInputs = [
      tidalDlNg
      pkgs.kdePackages.qtbase
      pkgs.kdePackages.qtsvg
    ];
    text = ''
      export QT_QPA_PLATFORM=xcb
      export QT_PLUGIN_PATH=${pkgs.kdePackages.qtbase}/lib/qt-6/plugins
      exec tidal-dl-ng-gui "$@"
    '';
  };

  tidal-dl-ng-gui-desktopfile = pkgs.stdenv.mkDerivation {
    pname = "tdng";
    version = "0.26.2";
    dontUnpack = true;

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      mkdir -p $out/bin
      cp ${tidal-dl-ng-gui}/bin/tdng $out/bin/

      mkdir -p $out/share/applications
      cat > $out/share/applications/tdng.desktop << EOF
      [Desktop Entry]
      Name=Tidal Downloader NG
      Comment=Download music from Tidal
      Exec=tdng
      Icon=audio-x-generic
      Terminal=false
      Type=Application
      Categories=AudioVideo;Audio;Player;
      EOF
    '';
  };
in
  # Combine the outputs into a single package
  pkgs.buildEnv {
    name = "tidal-dl-ng-env";
    paths = [tidal-dl-ng tidal-dl-ng-gui-desktopfile];
  }
