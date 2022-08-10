{ inputs, pkgs, lib, ... }:

rec {
  # Conveniance wrapper for mkOption with boolean type
  mkBoolOpt = def: desc:
  lib.mkOption {
    type = lib.types.bool;
    default = def;
    description = desc;
  };

  # Alias for consistency
  mkEnableOpt = lib.mkEnableOption;

  # Like mkIf but the predicate is inverted
  mkElse = pred: do:
  (lib.mkIf (!pred) do);

  # Creates a symlink if it doesn't exist
  mkLink = src: dest:
  ''
    if [ ! -L "${dest}" ]; then
      ln -sf ${src} ${dest}
    fi
  '';

  # Removes a symlink if it exists
  mkUnlink = dest:
  ''
    if [ -L "${dest}" ]; then
      rm ${dest}
    fi
  '';

  # TODO
  mkMultiOptStr = {  }:
  {

  };

  # TODO
  mkMultiOptPkg = { }:
  {

  };

  # Returns true if base contains element
  contains = base: element:
  lib.any (x: x == element) base;

  # Returns base without occurences of elements that are also in remove
  without = base: remove:
  lib.filter (x: !(contains remove x)) base;
}
