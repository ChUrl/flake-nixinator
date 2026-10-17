{
  inputs,
  pkgs,
  ...
}: {
  # Obsolete derivations are kept in "1_deprecated" for reference.

  monolisa = pkgs.callPackage ./monolisa {};
  raddbg = pkgs.callPackage ./raddbg {};
  rimstack = pkgs.callPackage ./rimstack {};
  tiddl = pkgs.callPackage ./tiddl {};
  xemu-8bit = pkgs.callPackage ./xemu-8bit {};
}
