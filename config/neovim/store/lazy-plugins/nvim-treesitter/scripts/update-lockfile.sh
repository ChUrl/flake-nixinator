#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/bash

make_ignored() {
  if [[ -n $1 ]]; then
    while read -r lang; do
      if [[ $lang != "$1" ]]; then
        printf '%s,' "$lang"
      fi
    done < <(jq -r 'keys[]' lockfile.json)
  fi
}

SKIP_LOCKFILE_UPDATE_FOR_LANGS="$(make_ignored "$1")" \
  nvim --headless -c 'luafile ./scripts/write-lockfile.lua' +q

# Pretty print
cp lockfile.json /tmp/lockfile.json
jq --sort-keys > lockfile.json < /tmp/lockfile.json
