{
  stdenv,
  lib,
  pkgs,
}: let
  inherit (pkgs.python310Packages) buildPythonPackage buildPythonApplication fetchPypi;

  # Too old in nixpkgs
  my-aiofiles = buildPythonPackage rec {
    version = "22.1.0";
    pname = "aiofiles";

    src = fetchPypi {
      inherit version pname;
      sha256 = "9107f1ca0b2a5553987a94a3c9959fe5b491fdf731389aa5b7b1bd0733e32de6";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [];
    doCheck = false;
  };

  # Too old in nixpkgs
  my-aiohttp = buildPythonPackage rec {
    version = "3.8.3";
    pname = "aiohttp";

    src = fetchPypi {
      inherit version pname;
      sha256 = "3828fb41b7203176b82fe5d699e0d845435f2374750a44b480ea6b930f6be269";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [
      aiosignal
      async-timeout
      asynctest
      attrs
      charset-normalizer
      frozenlist
      multidict
      typing-extensions
      yarl
    ];
    doCheck = false;
  };

  # Too old in nixpkgs
  my-certifi = buildPythonPackage rec {
    version = "2022.9.24";
    pname = "certifi";

    src = fetchPypi {
      inherit version pname;
      sha256 = "0d9c601124e5a6ba9712dbc60d9c53c21e34f5f641fe83002317394311bdce14";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [];
    doCheck = false;
  };

  # This package is not in nixpkgs
  gofile-client = buildPythonPackage rec {
    version = "1.0.1";
    pname = "gofile-client";

    src = fetchPypi {
      inherit version pname;
      sha256 = "1cc54630f1f4cbc09654ded012b4a5cd4992aa6ee67442dbba873edd63d01eff";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [requests];
    doCheck = false;
  };

  # This package is not in nixpkgs
  myjdapi = buildPythonPackage rec {
    version = "1.1.6";
    pname = "myjdapi";

    src = fetchPypi {
      inherit version pname;
      sha256 = "252a9c6eee001d67bb000ceb8fdf99729c06cf46ff18a00fc89468672388de1e";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [requests pycryptodome];
    doCheck = false;
  };
  # TODO: When new version is in nixpkgs update this derivation
  # Too old in nixpkgs
  # my-setuptools = buildPythonPackage rec {
  #   version = "65.5.0";
  #   pname = "setuptools";
  #   src = fetchPypi {
  #     inherit version pname;
  #     sha256 = "512e5536220e38146176efb833d4a62aa726b7bbff82cfbc8ba9eaa3996e0b17";
  #   };
  #   # From https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/python-modules/setuptools/default.nix#L75
  #   # nativeBuildInputs = [
  #   #   bootstrapped-pip
  #   #   (pipInstallHook.override{pip=null;})
  #   #   (setuptoolsBuildHook.override{setuptools=null; wheel=null;})
  #   # ];
  #   # preBuild = lib.optionalString (!stdenv.hostPlatform.isWindows) ''
  #   #   export SETUPTOOLS_INSTALL_WINDOWS_SPECIFIC_FILES=0
  #   # '';
  #   pipInstallFlags = [ "--ignore-installed" ];
  #   # Adds setuptools to nativeBuildInputs causing infinite recursion.
  #   # catchConflicts = false;
  #   propagatedBuildInputs = with pkgs.python310Packages; [ ];
  #   doCheck = false;
  # };
in
  buildPythonApplication rec {
    version = "3.4.14";
    pname = "cyberdrop-dl";

    src = fetchPypi {
      inherit version pname;
      sha256 = "bdf1e21452571a74bf4448d32b158b8600381f210696dd60d16fc83213793559";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [
      my-aiofiles
      my-aiohttp
      beautifulsoup4
      my-certifi
      colorama
      gofile-client
      myjdapi
      pyyaml
      # Needed in the latest versions, don't know how to make it work right now...
      # my-setuptools
      tqdm
      yarl
    ];

    doCheck = false;

    # Otherwise duplicates are found in closure (certifi), don't know why this happens
    # TODO: Investigate duplicates
    catchConflicts = false;

    meta = with lib; {
      homepage = "https://github.com/Jules-WinnfieldX/CyberDropDownloader";
      description = "Bulk downloader for multiple file hosts";
      license = licenses.gpl3Only;
    };
  }
