#!/usr/bin/env bash
# Bootstrap the living-docs workflow in a project. Idempotent: never overwrites
# existing docs.
#
# Usage: bootstrap.sh [--vendor] [project-dir]
#   --vendor   also copy the skill into <project>/.agents/skills/living-docs and
#              link it into <project>/.claude/skills (for shared repos / cloud agents)

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TPL="$SKILL_DIR/templates"

vendor=0
project="."
for arg in "$@"; do
  case "$arg" in
    --vendor) vendor=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) project="$arg" ;;
  esac
done
mkdir -p "$project"
cd "$project"
project="$(pwd)"
name="$(basename "$project")"
today="$(date +%F)"

say() { echo "  $*"; }
echo "living-docs bootstrap → $project"

# 1. git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q && say "git: initialized repository"
fi

# 2. docs skeleton
mkdir -p docs/decisions
copy_tpl() { # src dst
  if [ -e "$2" ]; then say "skip: $2 exists"
  else
    sed -e "s/{Project name}/$name/g" -e "s/{YYYY-MM-DD}/$today/g" "$1" > "$2"
    say "created: $2"
  fi
}
copy_tpl "$TPL/ARCHITECTURE.md"        docs/ARCHITECTURE.md
copy_tpl "$TPL/PLAN.md"                docs/PLAN.md
copy_tpl "$TPL/decisions-README.md"    docs/decisions/README.md

# 3. AGENTS.md managed block (replace block if present, else append)
block="$TPL/AGENTS.block.md"
if [ ! -f AGENTS.md ]; then
  { echo "# AGENTS.md — $name"; echo; cat "$block"; } > AGENTS.md
  say "created: AGENTS.md"
elif grep -q 'living-docs:start' AGENTS.md; then
  awk -v blk="$block" '
    /living-docs:start/ { while ((getline l < blk) > 0) print l; skip=1; next }
    /living-docs:end/   { skip=0; next }
    !skip' AGENTS.md > AGENTS.md.tmp && mv AGENTS.md.tmp AGENTS.md
  say "updated: AGENTS.md (managed block)"
else
  { echo; cat "$block"; } >> AGENTS.md
  say "appended: AGENTS.md (managed block)"
fi

# 4. CLAUDE.md → imports AGENTS.md
if [ ! -f CLAUDE.md ]; then
  cp "$TPL/CLAUDE.md" CLAUDE.md && say "created: CLAUDE.md"
elif ! grep -qx '@AGENTS.md' CLAUDE.md; then
  { echo '@AGENTS.md'; echo; cat CLAUDE.md; } > CLAUDE.md.tmp && mv CLAUDE.md.tmp CLAUDE.md
  say "updated: CLAUDE.md (added @AGENTS.md import)"
else
  say "skip: CLAUDE.md already imports AGENTS.md"
fi

# 5. commit-msg hook (versioned in .githooks/)
mkdir -p .githooks
cp "$SKILL_DIR/scripts/commit-msg" .githooks/commit-msg
chmod +x .githooks/commit-msg
current="$(git config core.hooksPath || true)"
if [ -z "$current" ] || [ "$current" = ".githooks" ]; then
  git config core.hooksPath .githooks
  say "hook: .githooks/commit-msg installed (core.hooksPath=.githooks)"
else
  say "WARNING: core.hooksPath is '$current'; copy .githooks/commit-msg there manually"
fi

# 6. optional vendoring
if [ "$vendor" -eq 1 ]; then
  mkdir -p .agents/skills .claude/skills
  rm -rf .agents/skills/living-docs
  cp -R "$SKILL_DIR" .agents/skills/living-docs
  ln -sfn ../../.agents/skills/living-docs .claude/skills/living-docs
  say "vendored: .agents/skills/living-docs (+ .claude/skills link)"
fi

echo "done. Note: after cloning, run 'git config core.hooksPath .githooks' to enable the hook."
