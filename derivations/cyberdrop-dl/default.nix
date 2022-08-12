{ lib, pkgs }:

let
  inherit (pkgs.python310Packages) buildPythonPackage buildPythonApplication fetchPypi;

  # This package is not in nixpkgs
  gofile-client = buildPythonPackage rec {
    version = "1.0.1";
    pname = "gofile-client";

    src = fetchPypi {
      inherit version pname;
      sha256 = "1cc54630f1f4cbc09654ded012b4a5cd4992aa6ee67442dbba873edd63d01eff";
    };

    propagatedBuildInputs = with pkgs.python310Packages; [ requests ];
    doCheck = false;
  };

in buildPythonApplication rec {
  version = "2.30.7";
  pname = "cyberdrop-dl";

  src = fetchPypi {
    inherit version pname;
    sha256 = "ee6804e8f11aa4e3868996c39af95e18e69c9708f81ea04872f0cde148af1ba6";
  };

  propagatedBuildInputs = with pkgs.python310Packages; [
    aiofiles
    aiohttp
    beautifulsoup4
    certifi
    colorama
    gofile-client
    tqdm
    yarl
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Jules-WinnfieldX/CyberDropDownloader";
    description = "Bulk downloader for multiple file hosts";
    license = licenses.gpl3Only;
  };
}