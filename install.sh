#!/usr/bin/env bash
# Install every skill in this repo globally for all supported coding agents,
# using symlinks (edit once here, every agent sees the change).
#
#   ~/.agents/skills/<skill>  -> <repo>/<skill>          (hub; read by Codex & others)
#   ~/.claude/skills/<skill>  -> ~/.agents/skills/<skill> (Claude Code)
#   ~/.gemini/antigravity-cli/skills/<skill> -> hub        (Antigravity CLI)
#   ~/.codex/skills/<skill>   -> hub                       (only if ~/.codex exists)
#
# Usage: install.sh [--uninstall]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HUB="$HOME/.agents/skills"
TARGETS=("$HOME/.claude/skills" "$HOME/.gemini/antigravity-cli/skills")
[ -d "$HOME/.codex" ] && TARGETS+=("$HOME/.codex/skills")

uninstall=0
[ "${1:-}" = "--uninstall" ] && uninstall=1

link() { # target linkpath
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "  SKIP $2 (exists and is not a symlink)"; return
  fi
  ln -sfn "$1" "$2" && echo "  link $2 -> $1"
}

mkdir -p "$HUB"
for skill_md in "$REPO"/*/SKILL.md; do
  skill="$(basename "$(dirname "$skill_md")")"
  echo "$skill"
  for t in "$HUB" "${TARGETS[@]}"; do
    if [ "$uninstall" -eq 1 ]; then
      [ -L "$t/$skill" ] && rm "$t/$skill" && echo "  removed $t/$skill"
      continue
    fi
    mkdir -p "$t"
    if [ "$t" = "$HUB" ]; then link "$REPO/$skill" "$t/$skill"
    else link "$HUB/$skill" "$t/$skill"; fi
  done
done
