{
  lib,
  stdenv,
  pkgs,
}: let
  pythonPkgs = pkgs.python314Packages.overrideScope (self: super: {
    typer = super.typer.overridePythonAttrs (old: {
      version = "0.20.1";
      src = pkgs.fetchPypi {
        pname = "typer";
        version = "0.20.0";
        sha256 = "sha256-Gq9klAMXk+SHb7C6z6apErVRz0PB5jyADfixqGZyDDc=";
      };
      propagatedBuildInputs = with pythonPkgs; [
        typing-extensions
      ];
    });

    aiofiles = super.aiofiles.overridePythonAttrs (old: {
      version = "25.1.0";
      src = pkgs.fetchFromGitHub {
        owner = "Tinche";
        repo = "aiofiles";
        tag = "v25.1.0";
        hash = "sha256-NBmzoUb2una3+eWqR1HraVPibaRb9I51aYwskrjxskQ=";
      };
      # Build system changed in this version
      build-system = with pythonPkgs; [
        hatchling
        hatch-vcs
      ];
    });
  });
in
  pythonPkgs.buildPythonApplication rec {
    pname = "tiddl";
    version = "3.4.3";
    format = "pyproject";

    src = pythonPkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-45KHNS1IP59DsH8i2uQ7sua6T21vW/Yw1PQg55jzLGs=";
    };

    dontCheckRuntimeDeps = true;

    build-system = with pythonPkgs; [
      poetry-core
      setuptools
    ];

    propagatedBuildInputs = with pythonPkgs; [
      # Nixpkgs
      aiofiles
      aiohttp
      m3u8
      mutagen
      pydantic
      requests
      requests-cache
      typer
    ];
  }
