# We need to wrap the dconf-editor to use the correct XDG_DATA_DIRS
# By default XDG_DATA_DIRS on NixOS contains paths to the gsettings-schemas like
# /nix/store/z3gxkwakzgiswvakfrpbirhpcach509j-mutter-42.3/share/gsettings-schemas/mutter-42.3
# but this is the wrong path for dconf-editor to find the schema, correct one would be
# /nix/store/z3gxkwakzgiswvakfrpbirhpcach509j-mutter-42.3/share/gsettings-schemas/mutter-42.3/glib-2.0/schemas

# override derivation attributes
prev.gnome.dconf-editor.overrideAttrs (oldAttrs: {
  # add `makeWrapper` to existing dependencies
  buildInputs = oldAttrs.buildInputs ++ [ final.makeWrapper ];

  # wrap the binary in a script where the appropriate env var is set
  postInstall = oldAttrs.postInstall or "" + ''
    schemas=""
    for p in $NIX_PROFILES; do
        if [[ -d "$p" ]]; then
            for d in $(nix-store --query --references "$p"); do
                schemas_dir=$(echo "$d"/share/gsettings-schemas/*/glib-2.0/schemas)
                if [[ -d "$schemas_dir" ]]; then
                    schemas="$schemas''${schemas:+:}$schemas_dir"
                fi
            done
        fi
    done

    wrapProgram "$out/bin/dconf-editor" --set XDG_DATA_DIRS $schemas
  '';
})
