# R-Car xOS platform package (Linux SDK1 + QNX SDK3 + Linux BSP + Poky toolchain).
#
# The archives are downloaded from the Renesas Artifactory by Nix itself
# (builtin:fetchurl), which authenticates with the netrc-file from nix.conf
# (system/wslren sets it up from the sops token). Archives that are already in
# the store, e.g. from `nix-store --add-fixed sha512`, have the same store path
# and are reused.
#
# Everything ends up in a single tree, $out/rcar-xos/v<version>/:
#   cmake/, sw/, opensource/, ...   from SDK1 and SDK3 (merged, SDK3 wins on conflicts)
#   os/                             from the Linux BSP
#   tools/toolchains/poky/          Poky SDK, installed by its own installer
#
# Every version in ./versions.nix is exposed as its own package, e.g.
#   pkgs.rcar-xos_v4_40_0
# (see derivations/default.nix), rcar-xos itself is the newest one.
{
  lib,
  stdenvNoCC,
  xz,
  gnutar,
  gzip,
  which,
  python3,
  version ? lib.last (lib.sort lib.versionOlder (lib.attrNames (import ./versions.nix))),
}: let
  hashes = (import ./versions.nix).${version} or (throw "rcar-xos: no hashes for version ${version}, add them to versions.nix");

  base = "https://artifactory.global.renesas.com/artifactory/rcar-release/release/xos4/v${version}";

  mkArchive = {
    name,
    path,
    hash,
  }:
    # Not pkgs.fetchurl: only builtin:fetchurl gets the netrc-file (the
    # credentials stay with the daemon instead of the build sandbox).
    import <nix/fetchurl.nix> {
      inherit name hash;
      url = "${base}/${path}";
    };

  sdk1 = mkArchive {
    name = "rcar-xos_platform-sdk1_v${version}_release.tar.gz";
    path = "internal/rcar-xos_platform-sdk1_v${version}_release.tar.gz";
    hash = hashes.sdk1;
  };
  sdk3 = mkArchive {
    name = "rcar-xos_platform-sdk3_v${version}_release.tar.gz";
    path = "internal/rcar-xos_platform-sdk3_v${version}_release.tar.gz";
    hash = hashes.sdk3;
  };
  bsp = mkArchive {
    name = "rcar-xos_tool_linux_bsp_v${version}_release.tar.gz";
    path = "rcar-tools/rcar-xos_tool_linux_bsp_v${version}_release.tar.gz";
    hash = hashes.bsp;
  };
  poky = mkArchive {
    name = "rcar-xos_tool_poky_toolchain_ubuntu_v${version}_release.tar.gz";
    path = "rcar-tools/ubuntu/rcar-xos_tool_poky_toolchain_ubuntu_v${version}_release.tar.gz";
    hash = hashes.poky;
  };
in
  stdenvNoCC.mkDerivation {
    pname = "rcar-xos";
    inherit version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    # Huge prebuilt tree; the Poky SDK is relocated by its installer. Don't strip/patch.
    dontFixup = true;

    nativeBuildInputs = [gnutar gzip xz which python3];

    installPhase = ''
      runHook preInstall

      root=$out/rcar-xos/v${version}
      mkdir -p $out

      # SDK1 and SDK3 are rooted at rcar-xos/v${version}/
      tar -xzf ${sdk1} -C $out --no-same-owner
      tar -xzf ${sdk3} -C $out --no-same-owner --overwrite

      # BSP and Poky archives have no top-level prefix
      chmod -R u+w $out
      tar -xzf ${bsp} -C $root --no-same-owner
      tar -xzf ${poky} -C $root --no-same-owner
      chmod -R u+w $root

      # Poky installer: the SDK toolchain file looks for ../tools/toolchains/poky
      installer=$(echo $root/tools/toolchains/poky/poky-glibc-*-toolchain-*.sh)
      poky=$root/tools/toolchains/poky
      # The installer's post-relocate hooks use `#!/usr/bin/env python3`, which does not
      # exist in the sandbox. The installer therefore fails at that final step (after
      # extraction and relocation), so patch the shebangs and rerun the hook ourselves.
      sh $installer -d $poky -y || true
      test -e $poky/version-aarch64-poky-linux
      hooks=$poky/sysroots/x86_64-pokysdk-linux/post-relocate-setup.d
      if [ -d $hooks ]; then
        patchShebangs $hooks
        sh $poky/post-relocate-setup.sh $poky
      fi
      rm $installer

      runHook postInstall
    '';

    passthru = {
      inherit sdk1 sdk3 bsp poky;
      inherit (hashes) pokyVersion;
    };

    meta = {
      description = "Renesas R-Car xOS platform SDK (Linux/QNX), Linux BSP and Poky toolchain";
      homepage = "https://www.renesas.com/";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  }
