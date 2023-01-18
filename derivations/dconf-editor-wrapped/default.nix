# We need to wrap the dconf-editor to use the correct XDG_DATA_DIRS
# By default XDG_DATA_DIRS on NixOS contains paths to the gsettings-schemas like
# /nix/store/z3gxkwakzgiswvakfrpbirhpcach509j-mutter-42.3/share/gsettings-schemas/mutter-42.3
# but this is the wrong path for dconf-editor to find the schema, correct one would be
# /nix/store/z3gxkwakzgiswvakfrpbirhpcach509j-mutter-42.3/share/gsettings-schemas/mutter-42.3/glib-2.0/schemas
{pkgs}: let
  find-gsettings-schemas = pkgs.callPackage ./find-gsettings-schemas.nix {};

  dconf-editor-wrapped = pkgs.writeShellScriptBin "dconf-editor-wrapped" ''
    XDG_DATA_DIRS=$(${find-gsettings-schemas}/bin/find-gsettings-schemas) ${pkgs.gnome.dconf-editor}/bin/dconf-editor
  '';

  desktop-icon = pkgs.makeDesktopItem {
    name = "Dconf Editor (Wrapped)";
    desktopName = "Dconf Editor (Wrapped)";
    exec = "${dconf-editor-wrapped}/bin/dconf-editor-wrapped";
    icon = "ca.desrt.dconf-editor";
    comment = "Modify the Gnome/GTK settings database";
    genericName = "Desktop application to manage Gnome/GTK settings.";
    categories = ["GNOME" "GTK" "System"];
  };
in
  # Combine multiple derivations into a single store path
  pkgs.symlinkJoin {
    name = "dconf-editor-wrapped";
    paths = [
      dconf-editor-wrapped
      desktop-icon
    ];
  }
