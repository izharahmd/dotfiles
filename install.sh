#!/usr/bin/env bash
# Symlink the dotfiles in this repo into $HOME.
# Usage: ./install.sh [--dry-run]
set -euo pipefail

FILES=(.aliases .dev .gitconfig .vimrc .zshrc)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0

case "${1:-}" in
  --dry-run) DRY_RUN=1 ;;
  "") ;;
  *) echo "usage: $0 [--dry-run]" >&2; exit 1 ;;
esac

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
  link "$DIR/$f" "$HOME/$f"
done
