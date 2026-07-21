# personalities

A Claude Code plugin that assigns a random "personality" (from `~/.claude/personalities/*.md`)
to each session and keeps it consistent for the whole conversation — replacing an earlier
CLAUDE.md-based instruction that picked inconsistently and drifted out of character mid-session.

## How it works

- **`SessionStart` hook** (`scripts/pick-personality.sh`) — picks a random `.md` file from
  `~/.claude/personalities/`, records the choice in `state/<session_id>.personality`, and
  injects the full personality text into context with an explicit "this persists all session"
  instruction.
- **`UserPromptSubmit` hook** (`scripts/reinforce-personality.sh`) — on every user message, looks
  up the session's recorded personality and re-injects the full text as a reminder, so the
  behavior can't quietly decay over a long conversation.
- **`/personalities:switch-personality` skill** (`scripts/switch-personality.sh`) — lets the user
  switch to a named personality or reroll to a random one mid-session; updates the same state
  file so reinforcement picks up the change immediately.
- **`/personalities:add-personality` skill** — interactively drafts a new personality file in the
  same style as the existing ones and writes it to `~/.claude/personalities/`, where it's
  automatically eligible for future random selection.

## Layout

```
.claude-plugin/plugin.json   plugin manifest
hooks/hooks.json             SessionStart + UserPromptSubmit hook registration
scripts/                     hook and skill implementation scripts
skills/                      slash-command skills (add-personality, switch-personality)
state/                       per-session "which personality is active" files (gitignored, self-cleaning after 7 days)
```

## Notes

- Personality source files live in `~/.claude/personalities/`, outside this plugin, and are
  never modified by the hooks — only read.
- `state/*.personality` files are pruned automatically (>7 days old) on each `SessionStart`.
