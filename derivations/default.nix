{
  inputs,
  pkgs,
  ...
}:
{
  # Obsolete derivations are kept in "1_deprecated" for reference.

  comfyui-desktop = pkgs.callPackage ./comfyui-desktop {};
  monolisa = pkgs.callPackage ./monolisa {};
  pulsesecure = pkgs.callPackage ./pulsesecure {};
  qnx-software-center = pkgs.callPackage ./qnx-software-center {};
  raddbg = pkgs.callPackage ./raddbg {};
  rcar-xos = pkgs.callPackage ./rcar-xos {};
  rcar-xos-fetch = pkgs.callPackage ./rcar-xos-fetch {};
  rimstack = pkgs.callPackage ./rimstack {};
  tiddl = pkgs.callPackage ./tiddl {};
  vscode-remote-server = pkgs.callPackage ./vscode-remote-server {};
  xemu-8bit = pkgs.callPackage ./xemu-8bit {};
}
# One package per R-Car xOS version in versions.nix: pkgs.rcar-xos_v4_40_0
# (builtins only: the attribute names of an overlay must not depend on pkgs)
// builtins.listToAttrs (map (version: {
  name = "rcar-xos_v${builtins.replaceStrings ["."] ["_"] version}";
  value = pkgs.callPackage ./rcar-xos {inherit version;};
}) (builtins.attrNames (import ./rcar-xos/versions.nix)))
