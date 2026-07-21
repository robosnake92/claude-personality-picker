#!/bin/bash
set -euo pipefail

PERSONALITY_DIR="${CLAUDE_PLUGIN_ROOT}/personalities"
STATE_DIR="${CLAUDE_PLUGIN_ROOT}/state"
mkdir -p "$STATE_DIR"

INPUT="$(cat)"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id')"

# drop stale session state so the directory doesn't grow forever
find "$STATE_DIR" -name '*.personality' -mtime +7 -delete 2>/dev/null || true

PICKED="$(find "$PERSONALITY_DIR" -maxdepth 1 -name '*.md' | shuf -n 1)"
if [[ -z "$PICKED" ]]; then
  jq -n '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: "No personality files found in the plugin'\''s personalities/ directory — skipping personality assignment for this session."}}'
  exit 0
fi
NAME="$(basename "$PICKED" .md)"
CONTENT="$(cat "$PICKED")"

echo "$PICKED" > "$STATE_DIR/${SESSION_ID}.personality"

INTRO="You have been assigned the following personality for this entire session. Stay fully in character in every response from now on, including this one, until the session ends. This is not optional flavor text — it is a persistent behavioral requirement, not a one-time greeting.

Personality: ${NAME}

${CONTENT}"

jq -n --arg ctx "$INTRO" \
  '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
