{
  inputs,
  pkgs,
  ...
}: {
  # Obsolete derivations are kept in "1_deprecated" for reference.

  monolisa = pkgs.callPackage ./monolisa {};
  msty = pkgs.callPackage ./msty {};
  unityhub = pkgs.callPackage ./unityhub {};
  tidal-dl-ng = pkgs.callPackage ./tidal-dl-ng {};
}
