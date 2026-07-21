#!/bin/bash
# Checks a personality file (or all of them) against the structural conventions
# established across the existing personalities/*.md files: header format, name
# subheading, address-forms bullet, caps-usage rule, emoji list, MUSIC bullet,
# and a closing memory/anecdote bullet.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERSONALITY_DIR="$PLUGIN_ROOT/personalities"

check_file() {
  local f="$1"
  local name
  name="$(basename "$f")"
  local failures=()

  head -n1 "$f" | grep -qE '^# .+PERSONALITY' || failures+=("missing '# ... PERSONALITY' title header on line 1")
  sed -n '2p' "$f" | grep -qE '^## Name:' || failures+=("missing '## Name: ...' subheading on line 2")
  grep -qEi '(address|refer to) (the user|friend-user)' "$f" || failures+=("missing an address-the-user-as bullet")
  grep -qEi 'caps|capital' "$f" || failures+=("missing a caps-usage rule bullet")
  grep -qi 'emoji' "$f" || failures+=("missing an emoji-usage bullet")
  grep -qEi '^- (MUSIC|music):' "$f" || failures+=("missing a 'MUSIC:' recommendation bullet")
  grep -qE 'REAL [A-Za-z '"'"'-]*(STORIES|MEMORIES)' "$f" || failures+=("missing a closing memory/anecdote bullet (no 'REAL ... STORIES/MEMORIES' phrase found)")

  if [[ ${#failures[@]} -eq 0 ]]; then
    echo "OK   $name"
    return 0
  else
    echo "FAIL $name"
    for reason in "${failures[@]}"; do
      echo "       - $reason"
    done
    return 1
  fi
}

TARGET="${1:-}"
STATUS=0

if [[ -n "$TARGET" ]]; then
  [[ -f "$TARGET" ]] || TARGET="$PERSONALITY_DIR/$TARGET"
  [[ "$TARGET" == *.md ]] || TARGET="$TARGET.md"
  if [[ ! -f "$TARGET" ]]; then
    echo "No such personality file: $TARGET" >&2
    exit 2
  fi
  check_file "$TARGET" || STATUS=1
else
  for f in "$PERSONALITY_DIR"/*.md; do
    check_file "$f" || STATUS=1
  done
fi

exit $STATUS
