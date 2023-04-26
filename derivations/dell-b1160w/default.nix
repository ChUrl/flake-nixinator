{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cups,
  libusb1,
}:
stdenv.mkDerivation rec {
  pname = "B1160_B1160w_UnifiedLinuxDriver";
  version = "1.01";

  src = fetchurl {
    url = "https://dl.dell.com/FOLDER00947576M/1/${pname}_${version}.tar.gz";
    sha256 = "10b75a899ba7aff3b95158f6fc49f09d6eef670608480ee48c179337c5337375";
    curlOptsList = ["--user-agent" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0"];
  };

  # https://nixos.org/manual/nixpkgs/unstable/#setup-hook-autopatchelfhook
  # https://nixos.wiki/wiki/Packaging/Binaries
  # https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
  # TODO: This step does not work
  nativeBuildInputs = [
    cups
    stdenv.cc.cc.lib
    libusb1
    autoPatchelfHook
  ];

  unpackCmd = ''
    mkdir -p root
    tar xvf $curSrc --directory=root
  '';

  # This is already built
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mkdir -p $out/cups
    mkdir -p $out/lib
    mkdir -p $out/lib64
    mkdir -p $out/sbin

    cp -r cdroot/Linux/x86_64/at_root/usr/sbin/* $out/sbin/
    cp -r cdroot/Linux/x86_64/at_root/usr/lib64/*.so.* $out/lib64/
    cp -r cdroot/Linux/x86_64/at_root/usr/lib64/cups/* $out/cups/
    cp -r cdroot/Linux/x86_64/at_root/opt/smfp-common/lib/* $out/lib/

    runHook postInstall
  '';

  meta = with lib; {
    description = "CUPS driver for the Dell B1160w printer.";
    longDescription = "CUPS driver for the Dell B1160w printer.";
    homepage = "https://www.dell.com/support/home/de-de/drivers/driversdetails?driverid=1m4pc";
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
  };
}
