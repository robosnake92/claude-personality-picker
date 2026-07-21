#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERSONALITY_DIR="$PLUGIN_ROOT/personalities"

for f in "$PERSONALITY_DIR"/*.md; do
  [[ -e "$f" ]] || continue
  slug="$(basename "$f" .md)"
  title="$(sed -n '1p' "$f" | sed -E 's/^# //; s/ PERSONALITY.*$//')"
  name="$(sed -n '2p' "$f" | sed -E 's/^## Name: //')"
  echo "- **${slug}** — ${title} (${name})"
done
