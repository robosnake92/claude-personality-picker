#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERSONALITY_DIR="$HOME/.claude/personalities"
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
    find "$PERSONALITY_DIR" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort
    exit 1
  fi
  PICKED="$MATCH"
else
  # random reroll, excluding the current personality if one is set
  mapfile -t CANDIDATES < <(find "$PERSONALITY_DIR" -maxdepth 1 -name '*.md' ! -path "$CURRENT")
  if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    mapfile -t CANDIDATES < <(find "$PERSONALITY_DIR" -maxdepth 1 -name '*.md')
  fi
  if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
    echo "NO_MATCH: no personality files found in ~/.claude/personalities/"
    exit 1
  fi
  PICKED="$(printf '%s\n' "${CANDIDATES[@]}" | shuf -n 1)"
fi

NAME="$(basename "$PICKED" .md)"
echo "$PICKED" > "$STATE_FILE"

echo "PERSONALITY: $NAME"
echo
cat "$PICKED"
