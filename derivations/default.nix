{
  inputs,
  pkgs,
  ...
}: {
  # Obsolete derivations are kept in "1_deprecated" for reference.

  monolisa = pkgs.callPackage ./monolisa {};
  msty = pkgs.callPackage ./msty {};
  raddbg = pkgs.callPackage ./raddbg {};
  rimstack = pkgs.callPackage ./rimstack {};
  unityhub = pkgs.callPackage ./unityhub {};
  tidal-dl-ng = pkgs.callPackage ./tidal-dl-ng {};
  tiddl = pkgs.callPackage ./tiddl {};
  xemu-8bit = pkgs.callPackage ./xemu-8bit {};
}
