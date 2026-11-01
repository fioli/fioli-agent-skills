#!/usr/bin/env bash
# Create a new MADR 4 ADR with the next number and add it to the index.
#
# Usage: new-adr.sh [--minimal] "Short title" [project-dir]

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
MADR="$SKILL_DIR/references/madr"

template="$MADR/adr-template.md"
title=""
project="."
for arg in "$@"; do
  case "$arg" in
    --minimal) template="$MADR/adr-template-minimal.md" ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) if [ -z "$title" ]; then title="$arg"; else project="$arg"; fi ;;
  esac
done
[ -z "$title" ] && { echo "error: title required" >&2; exit 1; }

dir="$project/docs/decisions"
mkdir -p "$dir"

last="$(ls "$dir" | grep -E '^[0-9]{4}-' | sort | tail -1 | cut -c1-4 || true)"
num="$(printf '%04d' $((10#${last:-0} + 1)))"
slug="$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
file="$dir/$num-$slug.md"
today="$(date +%F)"

if grep -q '^---$' <(head -1 "$template"); then
  # Full template: fill status/date in the existing front matter, set title.
  sed -E \
    -e "s/^status: .*/status: proposed/" \
    -e "s/^date: .*/date: $today/" \
    -e "s/^# \{short title.*\}$/# $title/" \
    "$template" > "$file"
else
  # Minimal template: prepend status/date front matter, set title.
  { printf -- '---\nstatus: proposed\ndate: %s\n---\n\n' "$today"
    sed -E "s/^# \{short title.*\}$/# $title/" "$template"; } > "$file"
fi

index="$dir/README.md"
if [ -f "$index" ]; then
  echo "| [$num]($num-$slug.md) | $title | proposed | $today |" >> "$index"
fi

echo "$file"
