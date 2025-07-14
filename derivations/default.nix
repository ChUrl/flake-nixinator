{
  inputs,
  pkgs,
  ...
}: {
  # Obsolete derivations are kept in "1_deprecated" for reference.

  monolisa = pkgs.callPackage ./monolisa {};
  msty = pkgs.callPackage ./msty {};
}
