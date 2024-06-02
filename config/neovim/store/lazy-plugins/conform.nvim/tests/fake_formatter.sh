#!/nix/store/306znyj77fv49kwnkpxmb0j2znqpa8bj-bash-5.2p26/bin/bash

set -e

CODE=0
if [ "$1" = "--fail" ]; then
  shift
  echo "failure" >&2
  CODE=1
fi
if [ "$1" = "--timeout" ]; then
  shift
  echo "timeout" >&2
  sleep 4
fi

output_file="$1"

if [ -n "$output_file" ] && [ -e "$output_file" ]; then
  cat "$output_file"
else
  cat
fi

exit $CODE
