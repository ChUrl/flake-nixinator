# TODO: Easier mkLink/mkUnlink (include more hm.dag stuff into the function)
{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
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
  mkElse = pred: do: (lib.mkIf (!pred) do);

  # Creates a symlink if it doesn't exist
  # If it exists renew the link
  mkLink = src: dest: ''
    if [ -L "${dest}" ]; then
      rm ${dest}
    fi
    ln -sf ${src} ${dest}
  '';

  # Removes a symlink if it exists
  mkUnlink = dest: ''
    if [ -L "${dest}" ]; then
      rm ${dest}
    fi
  '';

  # Returns true if base contains element
  contains = base: element:
    lib.any (x: x == element) base;

  # Returns base without occurences of elements that are also in remove
  without = base: remove:
    lib.filter (x: !(contains remove x)) base;

  # For use with single element sets
  attrName = set: let
    names = lib.attrNames set;
  in (
    if (names != [])
    then (lib.head names)
    else null
  );

  # For use with single element sets
  attrValue = set: let
    values = lib.attrValues set;
  in (
    if (values != [])
    then (lib.head values)
    else null
  );
}
