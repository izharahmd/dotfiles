#!/usr/bin/env bash
# Install zsh completions:
#   1. the zsh-completions oh-my-zsh plugin (enabled in .zshrc via `plugins=(... zsh-completions)`)
#   2. generated completions for each tool in TOOLS, written to $ZSH/completions/_<tool>
# Usage: ./install-completions.sh [--dry-run]
# Re-running updates the plugin and regenerates the completion files.
set -euo pipefail

# Tools to generate completions for. Each entry is either:
#   name                 runs `name completion zsh`
#   name=command...      runs the given command instead, e.g. "gh=gh completion -s zsh"
# Machine-local entries go in .install-completion-tools (gitignored): one entry per line,
# same format, '#' comments and blank lines allowed. They are added to this list.
TOOLS=(
  docker
  databricks
  "uv=uv generate-shell-completion zsh"
  "gh=gh completion -s zsh"
)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_FILE="$DIR/.install-completion-tools"
if [ -f "$TOOLS_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    # drop comments (a '#' at line start or after whitespace) and trim surrounding whitespace
    line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*#.*//' -e 's/[[:space:]]#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -n "$line" ] && TOOLS+=("$line")
  done < "$TOOLS_FILE"
fi

REPO_URL="https://github.com/zsh-users/zsh-completions.git"
OMZ="${ZSH:-$HOME/.oh-my-zsh}"
PLUGIN_DEST="${ZSH_CUSTOM:-$OMZ/custom}/plugins/zsh-completions"
COMP_DIR="$OMZ/completions"
DRY_RUN=0
FAILED=0

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

install_plugin() {
  if [ -d "$PLUGIN_DEST/.git" ]; then
    echo "update  $PLUGIN_DEST"
    run git -C "$PLUGIN_DEST" pull --ff-only
  elif [ -e "$PLUGIN_DEST" ]; then
    echo "error: $PLUGIN_DEST exists but is not a git checkout" >&2
    exit 1
  else
    echo "clone   $REPO_URL -> $PLUGIN_DEST"
    run git clone --depth 1 "$REPO_URL" "$PLUGIN_DEST"
  fi
}

generate() {
  local entry="$1" name cmd out tmp
  name="${entry%%=*}"
  if [ "$name" = "$entry" ]; then
    cmd="$name completion zsh"
  else
    cmd="${entry#*=}"
  fi
  out="$COMP_DIR/_$name"

  if ! command -v "$name" >/dev/null 2>&1; then
    echo "skip    $name (not installed)"
    return
  fi

  echo "gen     $out  ($cmd)"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  would run: $cmd > $out"
    return
  fi

  # Write to a temp file first so a failing command never leaves an empty/partial completion.
  tmp="$(mktemp)"
  if $cmd > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
    mv "$tmp" "$out"
  else
    rm -f "$tmp"
    echo "fail    $name: '$cmd' failed or produced no output" >&2
    FAILED=1
  fi
}

if [ ! -d "$OMZ" ]; then
  echo "error: oh-my-zsh not found at $OMZ" >&2
  exit 1
fi

install_plugin

run mkdir -p "$COMP_DIR"
for entry in ${TOOLS[@]+"${TOOLS[@]}"}; do
  generate "$entry"
done

echo "done    restart your shell (or run: exec zsh) to pick up the completions"
exit "$FAILED"
