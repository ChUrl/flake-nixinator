#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix
set -euo pipefail

cd "$(dirname "$0")"

src_url="https://github.com/lgblgblgb/xemu-binaries/raw/binary-linux-master/xemu_current_amd64.deb"
version_url="https://raw.githubusercontent.com/lgblgblgb/xemu-binaries/binary-linux-master/versioninfo"

new_version="$(curl -fsSL "$version_url")"
old_version="$(sed -nE 's/^[[:space:]]*version = "([0-9]+)";$/\1/p' ./default.nix)"

if [[ "$new_version" == "$old_version" ]]; then
  echo "xemu-8bit is up to date ($old_version)"
  exit 0
fi

new_hash="$(nix store prefetch-file --json --hash-type sha256 "$src_url" | jq -r .hash)"

sed -i "s/version = \"$old_version\";/version = \"$new_version\";/" ./default.nix
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$new_hash\";|" ./default.nix

echo "Updated xemu-8bit: $old_version -> $new_version"
