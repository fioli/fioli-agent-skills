#!/usr/bin/env bash
# Install skills from this repo globally for all supported coding agents,
# using symlinks (edit once here, every agent sees the change).
#
#   ~/.agents/skills/<skill>  -> <repo>/<skill>           (hub; read by Codex & others)
#   ~/.claude/skills/<skill>  -> ~/.agents/skills/<skill>  (Claude Code)
#   ~/.gemini/antigravity-cli/skills/<skill> -> hub        (Antigravity CLI)
#   ~/.codex/skills/<skill>   -> hub                       (only if ~/.codex exists)
#
# Usage:
#   install.sh --list                     list available skills and their status
#   install.sh <skill> [<skill> ...]      install the given skills
#   install.sh --all                      install every skill in this repo
#   install.sh --uninstall <skill> ...    remove the given skills
#   install.sh --uninstall --all          remove every skill of this repo

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HUB="$HOME/.agents/skills"
TARGETS=("$HOME/.claude/skills" "$HOME/.gemini/antigravity-cli/skills")
[ -d "$HOME/.codex" ] && TARGETS+=("$HOME/.codex/skills")

usage() { sed -n '10,15p' "$0" | sed 's/^# \{0,1\}//'; }

available() { # names of all skills in the repo (dirs with SKILL.md)
  for f in "$REPO"/*/SKILL.md; do [ -f "$f" ] && basename "$(dirname "$f")"; done
}

description() { # first sentence of the description field of a SKILL.md
  awk '
    /^description:/ { on=1; sub(/^description:[ \t]*(>-|>|\|)?[ \t]*/, ""); d=$0; next }
    on && /^[a-zA-Z_-]+:|^---/ { exit }
    on { sub(/^[ \t]+/, ""); d = d (d=="" ? "" : " ") $0 }
    END { sub(/\. .*/, ".", d); print d }' "$REPO/$1/SKILL.md"
}

list() {
  echo "Available skills in $REPO:"
  for s in $(available); do
    if [ "$(readlink "$HUB/$s" 2>/dev/null)" = "$REPO/$s" ]; then st="installed"; else st="not installed"; fi
    printf "  %-20s [%s]  %s\n" "$s" "$st" "$(description "$s")"
  done
}

link() { # target linkpath
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "  SKIP $2 (exists and is not a symlink)"; return
  fi
  ln -sfn "$1" "$2" && echo "  link $2 -> $1"
}

install_skill() {
  echo "install: $1"
  mkdir -p "$HUB"
  link "$REPO/$1" "$HUB/$1"
  for t in "${TARGETS[@]}"; do mkdir -p "$t"; link "$HUB/$1" "$t/$1"; done
}

uninstall_skill() {
  echo "uninstall: $1"
  for t in "$HUB" "${TARGETS[@]}"; do
    if [ -L "$t/$1" ]; then rm "$t/$1" && echo "  removed $t/$1"; fi
  done
}

mode="install"; all=0; skills=()
for arg in "$@"; do
  case "$arg" in
    --list|-l) list; exit 0 ;;
    --all) all=1 ;;
    --uninstall) mode="uninstall" ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: unknown option $arg" >&2; usage >&2; exit 1 ;;
    *) skills+=("$arg") ;;
  esac
done

if [ "$all" -eq 1 ]; then
  mapfile -t skills < <(available)
elif [ "${#skills[@]}" -eq 0 ]; then
  usage; echo; list; exit 1
fi

for s in "${skills[@]}"; do
  if [ ! -f "$REPO/$s/SKILL.md" ]; then
    echo "error: unknown skill '$s' (see --list)" >&2; exit 1
  fi
done

for s in "${skills[@]}"; do "${mode}_skill" "$s"; done
