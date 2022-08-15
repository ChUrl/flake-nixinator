{ pkgs, ... }:

pkgs.writeShellScriptBin "find-gsettings-schemas" ''
  schemas=""
  for d in $(ls -1 --ignore "*.drv" /nix/store); do
      schemas_dir=$(echo /nix/store/"$d"/share/gsettings-schemas/*)
      if [[ -d "$schemas_dir" ]]; then
          schemas="$schemas''${schemas:+:}$schemas_dir"
      fi
  done

  echo "$schemas"
''