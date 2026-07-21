#!/bin/bash
set -euo pipefail

STATE_DIR="${CLAUDE_PLUGIN_ROOT}/state"

INPUT="$(cat)"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id')"
STATE_FILE="$STATE_DIR/${SESSION_ID}.personality"

if [[ ! -f "$STATE_FILE" ]]; then
  # No personality recorded for this session (e.g. hook added mid-session).
  # Say nothing rather than guessing.
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

jq -n --arg ctx "$REMINDER" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
