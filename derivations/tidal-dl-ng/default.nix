# https://github.com/exislow/tidal-dl-ng/issues/472
# https://gist.github.com/xaolanx/4c88d0cbc0dee90764bae767006103f8
{
  lib,
  stdenv,
  pkgs,
}: let
  #
  # Custom Dependencies
  #
  pythonPkgs = pkgs.python313Packages.overrideScope (self: super: {
    typer = super.typer.overridePythonAttrs (old: {
      version = "0.20.0";
      src = super.fetchPypi {
        inherit (old) pname;
        version = "0.20.0";
        sha256 = "sha256-Gq9klAMXk+SHb7C6z6apErVRz0PB5jyADfixqGZyDDc=";
      };
    });

    rich = super.rich.overridePythonAttrs (old: {
      version = "14.2.0";
      src = super.fetchPypi {
        inherit (old) pname;
        version = "14.2.0";
        sha256 = "sha256-c/9Qx8DBx3yCQweSg/Tts3bw9kQkM67LjOfm0LktH+Q=";
      };
      doCheck = false;
    });
  });

  # typer_0_20_0 = pkgs.python313Packages.typer.overridePythonAttrs (old: {
  #   version = "0.20.0";
  #   src = pkgs.python313Packages.fetchPypi {
  #     inherit (old) pname;
  #     version = "0.20.0";
  #     sha256 = "sha256-Gq9klAMXk+SHb7C6z6apErVRz0PB5jyADfixqGZyDDc=";
  #   };
  # });
  #
  # rich_14_2_0 = pkgs.python313Packages.rich.overridePythonAttrs (old: {
  #   version = "14.2.0";
  #   src = pkgs.python313Packages.fetchPypi {
  #     inherit (old) pname;
  #     version = "14.2.0";
  #     sha256 = "sha256-c/9Qx8DBx3yCQweSg/Tts3bw9kQkM67LjOfm0LktH+Q=";
  #   };
  #   doCheck = false;
  # });

  # rich_14_2_0 = pkgs.python313Packages.rich.overridePythonAttrs (old: {
  #   version = "14.2.0";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "Textualize";
  #     repo = "rich";
  #     tag = "v14.2.0";
  #     hash = "sha256-oQbxRbZnVr/Ln+i/hpBw5FlpUp3gcp/7xsxi6onPkn8=";
  #   };
  # });

  tidalDlNg = pythonPkgs.buildPythonApplication rec {
    pname = "tidal-dl-ng";
    version = "0.31.3";
    format = "pyproject";

    # TODO: The official repo was deleted, find the new one once it pops up
    # src = pkgs.fetchFromGitHub {
    #   owner = "exislow";
    #   repo = "tidal-dl-ng";
    #   rev = "v${version}";
    #   sha256 = "sha256-PUT0anx1yivgXwW21jah7Rv1/BabOT+KPoW446NFNyg=";
    # };

    src = pkgs.fetchFromGitHub {
      owner = "rodvicj";
      repo = "tidal_dl_ng-Project";
      rev = "4573142c76ef045ebf8e80c34657dd2bec96f17d";
      sha256 = "sha256-3sO2qj8V4KXOWK7vQsFAOYeTZo2rsc/M36SwRnC0oVg=";
    };

    doCheck = false;
    catchConflicts = false;

    nativeBuildInputs = with pythonPkgs; [poetry-core setuptools];

    # https://github.com/exislow/tidal-dl-ng/blob/master/pyproject.toml
    propagatedBuildInputs = with pythonPkgs; [
      # Nixpkgs
      requests
      mutagen
      dataclasses-json
      pathvalidate
      m3u8
      coloredlogs
      pyside6
      pyqtdarktheme
      toml
      pycryptodome
      tidalapi
      python-ffmpeg
      ansi2html

      # Custom Deps
      typer
      rich
    ];
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
    version = "0.31.3";
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
