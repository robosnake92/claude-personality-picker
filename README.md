# personalities

A Claude Code plugin that assigns a random "personality" (from `personalities/*.md` in this
repo) to each session and keeps it consistent for the whole conversation — replacing an earlier
CLAUDE.md-based instruction that picked inconsistently and drifted out of character mid-session.

## How it works

- **`SessionStart` hook** (`scripts/pick-personality.sh`) — picks a random `.md` file from
  `personalities/`, records the choice in `state/<session_id>.personality`, and injects the full
  personality text into context with an explicit "this persists all session" instruction.
- **`UserPromptSubmit` hook** (`scripts/reinforce-personality.sh`) — on every user message, looks
  up the session's recorded personality and re-injects the full text as a reminder, so the
  behavior can't quietly decay over a long conversation.
- **`/personalities:switch-personality` skill** (`scripts/switch-personality.sh`) — lets the user
  switch to a named personality or reroll to a random one mid-session; updates the same state
  file so reinforcement picks up the change immediately.
- **`/personalities:add-personality` skill** — interactively drafts a new personality file in the
  same style as the existing ones, validates it against the structural convention, and writes it
  to `personalities/`, where it's automatically eligible for future random selection.
- **`/personalities:list-personalities` skill** (`scripts/list-personalities.sh`) — prints every
  personality currently in the rotation with its title and in-character name.
- **`scripts/validate-personality.sh`** — checks a personality file (or all of them, if run with
  no argument) against the structural convention: title header, name subheading, address-forms
  bullet, caps-usage rule, emoji bullet, MUSIC bullet, closing memory/anecdote bullet. Run it any
  time to audit the whole `personalities/` directory for drift.

## Layout

```
.claude-plugin/plugin.json   plugin manifest
hooks/hooks.json             SessionStart + UserPromptSubmit hook registration
scripts/                     hook and skill implementation scripts
skills/                      slash-command skills (add-personality, switch-personality)
personalities/               personality definition files (*.md), one per persona
state/                       per-session "which personality is active" files (gitignored, self-cleaning after 7 days)
```

## Dependencies

None beyond bash and standard coreutils (`cat`, `find`, `sed`, `tr`, `basename`, `mkdir`). No
`jq`, no `shuf`, no bash-4+ builtins (e.g. `mapfile`) — JSON escaping/parsing and random
selection are implemented in pure bash (`scripts/lib.sh`, sourced by the hook scripts), and
picking works with plain arrays + `$RANDOM`. This keeps it working out of the box on macOS's
stock bash 3.2 as well as Linux, with nothing to install first.

## Notes

- `state/*.personality` files are pruned automatically (>7 days old) on each `SessionStart`.
