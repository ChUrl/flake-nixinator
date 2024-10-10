{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  # NOTE: Taken from NixVim https://github.com/nix-community/nixvim/blob/main/lib/to-lua.nix
  toLuaObject = args:
    if builtins.isAttrs args
    then
      if lib.hasAttr "__raw" args
      then args.__raw
      else if lib.hasAttr "__empty" args
      then "{ }"
      else
        "{"
        + (lib.concatStringsSep "," (
          lib.mapAttrsToList (
            n: v: let
              valueString = toLuaObject v;
            in
              if lib.hasPrefix "__unkeyed" n
              then valueString
              else if lib.hasPrefix "__rawKey__" n
              then ''[${lib.removePrefix "__rawKey__" n}] = '' + valueString
              else if n == "__emptyString"
              then "[''] = " + valueString
              else "[${toLuaObject n}] = " + valueString
          ) (lib.filterAttrs (n: v: v != null && (toLuaObject v != "{}")) args)
        ))
        + "}"
    else if builtins.isList args
    then "{" + lib.concatMapStringsSep "," toLuaObject args + "}"
    else if builtins.isString args
    then
      # This should be enough!
      builtins.toJSON args
    else if builtins.isPath args
    then builtins.toJSON (toString args)
    else if builtins.isBool args
    then "${lib.boolToString args}"
    else if builtins.isFloat args
    then "${toString args}"
    else if builtins.isInt args
    then "${toString args}"
    else if (args == null)
    then "nil"
    else "";

  toLuaKeymap = args: let
    removeDeprecatedMapAttrs = v: builtins.removeAttrs v ["lua"];
  in ''
    -- Set up keybinds using mylib.generators.toLuaKeymap {{{
    do
      local __nixvim_binds = ${toLuaObject (map removeDeprecatedMapAttrs args)}
      for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
      end
    end
    -- }}}
  '';
}
