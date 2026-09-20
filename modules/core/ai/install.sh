#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Symlink pi extensions and skills from this repo into ~/.pi/agent/
link() {
  local src="$SCRIPT_DIR/$1"
  local dst="$HOME/.pi/agent/$2"

  if [[ ! -e "$src" ]]; then
    echo "Skipping $src (not found)"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    rm "$dst"  # remove old symlink
  elif [[ -e "$dst" ]]; then
    local backup="${dst}.backup.$(date +%s)"
    echo "Backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

link "pi/AGENTS.md" "AGENTS.md"
link "pi/skills/caveman" "skills/caveman"
link "pi/skills/lavish" "skills/lavish"
link "pi/extensions/caveman" "extensions/caveman"

echo "Done. Start a new pi session to pick up changes."
