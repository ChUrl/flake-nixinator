#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/bash

set -eu
set -o pipefail

FILE="$1"
export TERM=xterm-256color
eval "$(dircolors -b "$FILE")"
printf '%s' "$LS_COLORS"
