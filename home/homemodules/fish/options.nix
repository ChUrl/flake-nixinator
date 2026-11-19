{
  lib,
  mylib,
  ...
}:
with lib;
with mylib.modules; {
  enable = mkEnableOption "Fish";

  kittySshAbbr = mkBoolOption true ''
    Add the `ssh` abbreviation that runs `kitty +kitten ssh`.
    Only works when ssh is started from a kitty window (the kitten needs the
    kitty terminal), so hosts that run their shells in Windows Terminal
    (the WSL hosts) disable it.
  '';
}
