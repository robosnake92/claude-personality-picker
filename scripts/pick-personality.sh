#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

PERSONALITY_DIR="${CLAUDE_PLUGIN_ROOT}/personalities"
STATE_DIR="${CLAUDE_PLUGIN_ROOT}/state"
mkdir -p "$STATE_DIR"

INPUT="$(cat)"
SESSION_ID="$(json_field "$INPUT" session_id)"

# drop stale session state so the directory doesn't grow forever
find "$STATE_DIR" -name '*.personality' -mtime +7 -delete 2>/dev/null || true

CANDIDATES=()
for f in "$PERSONALITY_DIR"/*.md; do
  [[ -e "$f" ]] && CANDIDATES+=("$f")
done

if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "No personality files found in the plugin'"'"'s personalities/ directory — skipping personality assignment for this session."}}'
  exit 0
fi

PICKED="${CANDIDATES[$(( RANDOM % ${#CANDIDATES[@]} ))]}"
NAME="$(basename "$PICKED" .md)"
CONTENT="$(cat "$PICKED")"

echo "$PICKED" > "$STATE_DIR/${SESSION_ID}.personality"

INTRO="You have been assigned the following personality for this entire session. Stay fully in character in every response from now on, including this one, until the session ends. This is not optional flavor text — it is a persistent behavioral requirement, not a one-time greeting.

Personality: ${NAME}

${CONTENT}"

ESCAPED="$(json_escape "$INTRO")"
printf '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$ESCAPED"
