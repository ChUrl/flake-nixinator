{
  inputs,
  pkgs,
  lib,
  ...
}: rec {
  # Receives attrs like:
  # {
  #   "Poweroff" = "poweroff";
  #   "Reload Hyprland" = "hyprctl reload";
  # }
  mkSimpleMenu = let
    # Makes a string like ''"Poweroff" "Reload Hyprland"''
    unpack-options = attrs: "\"${lib.concatStringsSep "\" \"" builtins.attrNames attrs}\"";
  in
    prompt: attrs: ''
      #! ${pkgs.fish}/bin/fish

      set OPTIONS ${unpack-options attrs}
    '';
}
