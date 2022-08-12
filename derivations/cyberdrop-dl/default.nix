{ lib, fetchPypi, buildPythonPackage }:

buildPythonPackage rec {
  version = "2.30.7";
  pname = "cyberdrop-dl";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ee6804e8f11aa4e3868996c39af95e18e69c9708f81ea04872f0cde148af1ba6";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/Jules-WinnfieldX/CyberDropDownloader";
    description = "Bulk downloader for multiple file hosts";
    license = licenses.gpl3Only;
  };
}