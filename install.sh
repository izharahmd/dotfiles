#!/usr/bin/env bash
# Symlink the dotfiles in this repo into $HOME.
# Usage: ./install.sh [--dry-run] [--skip <file>]...
# Files listed in .install-skip (one per line, '#' comments allowed) are also skipped.
set -euo pipefail

FILES=(.aliases .dev .gitconfig .vimrc .zshrc)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0
SKIP=()

usage() {
  echo "usage: $0 [--dry-run] [--skip <file>]..." >&2
  exit 1
}

SKIP_FILE="$DIR/.install-skip"
if [ -f "$SKIP_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [ -n "$line" ] && SKIP+=("$line")
  done < "$SKIP_FILE"
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --skip)
      [ $# -ge 2 ] || usage
      SKIP+=("$2")
      shift
      ;;
    *) usage ;;
  esac
  shift
done

is_skipped() {
  local f
  for f in ${SKIP[@]+"${SKIP[@]}"}; do
    [ "$f" = "$1" ] && return 0
  done
  return 1
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  would run: $*"
  else
    "$@"
  fi
}

link() {
  local src="$1" dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok      $dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "backup  $dest -> $dest.bak.$STAMP"
    run mv "$dest" "$dest.bak.$STAMP"
  fi

  echo "link    $dest -> $src"
  run ln -s "$src" "$dest"
}

for f in "${FILES[@]}"; do
  if is_skipped "$f"; then
    echo "skip    $HOME/$f"
    continue
  fi
  link "$DIR/$f" "$HOME/$f"
done
