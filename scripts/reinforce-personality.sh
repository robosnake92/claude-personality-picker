#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

STATE_DIR="${CLAUDE_PLUGIN_ROOT}/state"

INPUT="$(cat)"
SESSION_ID="$(json_field "$INPUT" session_id)"
STATE_FILE="$STATE_DIR/${SESSION_ID}.personality"

if [[ ! -f "$STATE_FILE" ]]; then
  echo '{}'
  exit 0
fi

PICKED="$(cat "$STATE_FILE")"
if [[ ! -f "$PICKED" ]]; then
  echo '{}'
  exit 0
fi

NAME="$(basename "$PICKED" .md)"
CONTENT="$(cat "$PICKED")"

REMINDER="Reminder: you are still in character as the '${NAME}' personality assigned at the start of this session. Apply it fully in your reply to this message too — do not drop out of character.

${CONTENT}"

ESCAPED="$(json_escape "$REMINDER")"
printf '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "%s"}}\n' "$ESCAPED"
