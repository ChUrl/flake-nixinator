#!/usr/bin/env bash
#
# Rewrite stale gitea SSH remotes after the gitea migration.
#
# Gitea now runs as the OS user `gitea` (the old container ran as `git`), so the
# built-in SSH server only accepts `gitea@`. This walks every git repository
# below $HOME and rewrites remotes of the form
#
#     ssh://git@gitea.local.chriphost.de:222/...   →  ssh://gitea@...
#     ssh://git@gitea.vps.chriphost.de:222/...     →  ssh://gitea@...
#     git@gitea.<host>:...                         →  gitea@...
#
# Only remotes pointing at the gitea hosts are touched; github/gitlab/etc. are
# left alone. Idempotent: running it twice changes nothing the second time.
#
# Usage:
#   ./fix-gitea-remotes.sh            # dry run (default)
#   ./fix-gitea-remotes.sh --apply    # actually rewrite
#   ./fix-gitea-remotes.sh --apply /some/other/dir
#
set -euo pipefail

apply=0
root="$HOME"

for arg in "$@"; do
  case "$arg" in
    --apply) apply=1 ;;
    --dry-run) apply=0 ;;
    -h | --help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "unknown option: $arg" >&2
      exit 2
      ;;
    *) root="$arg" ;;
  esac
done

root="${root%/}"
[ -d "$root" ] || {
  echo "not a directory: $root" >&2
  exit 1
}

# Skip known-large/irrelevant trees; only .git/config files are considered.
mapfile -t configs < <(
  find "$root" \
    \( -name .cache -o -name .local -o -name .nix-profile -o -name .direnv \
    -o -name node_modules -o -name result \) -prune -o \
    -type f -path '*/.git/config' -print 2>/dev/null
)

found=0
changed=0

for cfg in "${configs[@]}"; do
  repo="$(dirname "$(dirname "$cfg")")"

  while IFS= read -r line; do
    [ -n "$line" ] || continue

    key="${line%% *}"   # remote.origin.url
    url="${line#* }"    # the URL
    remote="${key#remote.}"
    remote="${remote%.url}"

    new_url="$url"
    case "$url" in
      ssh://git@gitea.local.chriphost.de:* | ssh://git@gitea.vps.chriphost.de:*)
        new_url="ssh://gitea@${url#ssh://git@}"
        ;;
      git@gitea.local.chriphost.de:* | git@gitea.vps.chriphost.de:*)
        new_url="gitea@${url#git@}"
        ;;
    esac

    if [ "$new_url" != "$url" ]; then
      found=$((found + 1))
      printf '%s\n' "$repo"
      printf '  %-8s %s\n' "$remote:" "$url"
      printf '  %-8s %s\n' "->" "$new_url"

      if [ "$apply" -eq 1 ]; then
        git config --file "$cfg" "$key" "$new_url"
        changed=$((changed + 1))
      fi
    fi
  done < <(git config --file "$cfg" --get-regexp '^remote\..*\.url$' 2>/dev/null || true)
done

echo
echo "repositories scanned: ${#configs[@]}"
echo "stale remotes found:  $found"
if [ "$apply" -eq 1 ]; then
  echo "remotes rewritten:    $changed"
else
  echo "dry run — re-run with --apply to rewrite"
fi
