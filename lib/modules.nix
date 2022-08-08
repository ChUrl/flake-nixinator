{ inputs, pkgs, lib, ... }:

rec {
  mkBoolOpt = def: desc:
  lib.mkOption {
    type = lib.types.bool;
    default = def;
    description = desc;
  };

  mkElse = pred: do:
  (lib.mkIf (!pred) do);

  mkLink = src: dest:
  ''
    if [ ! -L "${dest}" ]; then
      ln -sf ${src} ${dest}
    fi
  '';

  mkUnlink = dest:
  ''
    if [ -L "${dest}" ]; then
      rm ${dest}
    fi
  '';
}
