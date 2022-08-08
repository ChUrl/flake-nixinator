{ inputs, pkgs, lib, ... }:

let

in {
  mkBoolOpt = { def, desc ? "" }:
  {
    type = lib.types.bool;
    default = def;
    description = desc;
  };

  linkMutable = { src, dest, after }:
  lib.hm.dag.entryAfter [ "writeBoundary" ] ++ after ''
    if [ ! -L "${dest}" ]; then
      ln -sf ${src} ${dest}
    fi
  '';
}
