{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  # Convenience wrapper for "mkOption" with boolean type.
  mkBoolOption = def: desc:
    lib.mkOption {
      type = lib.types.bool;
      default = def;
      description = desc;
    };

  # Like "lib.mkIf" but the predicate is inverted.
  # Returns "do" if "pred" is false.
  mkElse = pred: do: (lib.mkIf (!pred) do);

  # Returns "true" if "base" contains "element".
  contains = base: element:
    lib.any (x: x == element) base;

  # Returns "base" without occurences of elements that are also in "remove".
  without = base: remove:
    lib.filter (x: !(contains remove x)) base;

  # Used with attrSets with a single element.
  # Returns the name of the single attr.
  attrName = set: let
    names = lib.attrNames set;
  in
    if (names != [])
    then (lib.head names)
    else null;

  # Used with attrSets with a single element.
  # Returns the value of the single attr.
  attrValue = set: let
    values = lib.attrValues set;
  in
    if (values != [])
    then (lib.head values)
    else null;
}
