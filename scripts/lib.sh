#!/bin/bash
# Shared helpers, implemented in pure bash (no jq, no shuf, no bash-4+ builtins)
# so the plugin has no external dependencies beyond bash/coreutils basics.

# Escapes a string for embedding as a JSON string value.
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

# Extracts a top-level string field's value from a JSON blob.
json_field() {
  local json="$1" field="$2"
  printf '%s' "$json" | tr -d '\n' | sed -n "s/.*\"${field}\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"
}
