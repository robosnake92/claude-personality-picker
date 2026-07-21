#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERSONALITY_DIR="$PLUGIN_ROOT/personalities"
STATE_DIR="$PLUGIN_ROOT/state"
mkdir -p "$STATE_DIR"

: "${CLAUDE_CODE_SESSION_ID:?CLAUDE_CODE_SESSION_ID is not set in this environment}"
STATE_FILE="$STATE_DIR/${CLAUDE_CODE_SESSION_ID}.personality"

REQUESTED="${1:-}"

CURRENT=""
if [[ -f "$STATE_FILE" ]]; then
  CURRENT="$(cat "$STATE_FILE")"
fi

if [[ -n "$REQUESTED" ]]; then
  # normalize: lowercase, spaces -> underscores, strip a trailing .md if given
  SLUG="$(echo "$REQUESTED" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')"
  SLUG="${SLUG%.md}"
  MATCH="$PERSONALITY_DIR/${SLUG}.md"

  if [[ ! -f "$MATCH" ]]; then
    echo "NO_MATCH: no personality file matches '${REQUESTED}'"
    echo "AVAILABLE:"
    for f in "$PERSONALITY_DIR"/*.md; do
      [[ -e "$f" ]] && basename "$f" .md
    done | sort
    exit 1
  fi
  PICKED="$MATCH"
else
  # random reroll, excluding the current personality if one is set
  CANDIDATES=()
  for f in "$PERSONALITY_DIR"/*.md; do
    [[ -e "$f" ]] || continue
    [[ "$f" == "$CURRENT" ]] && continue
    CANDIDATES+=("$f")
  done
  if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    for f in "$PERSONALITY_DIR"/*.md; do
      [[ -e "$f" ]] && CANDIDATES+=("$f")
    done
  fi
  if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    echo "NO_MATCH: no personality files found in the plugin's personalities/ directory"
    exit 1
  fi
  PICKED="${CANDIDATES[$(( RANDOM % ${#CANDIDATES[@]} ))]}"
fi

NAME="$(basename "$PICKED" .md)"
echo "$PICKED" > "$STATE_FILE"

echo "PERSONALITY: $NAME"
echo
cat "$PICKED"
