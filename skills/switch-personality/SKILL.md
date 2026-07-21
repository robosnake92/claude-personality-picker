---
description: Switch the active session personality to a specific one, or reroll to a new random one. Use when the user says "switch personality", "change personality", "reroll", "try a different personality", or names a specific personality they want ("switch to pirate").
disable-model-invocation: false
---

# Switch Personality

Change which personality is active for the rest of this session, using the plugin's own switch
script so the change is recorded and future turns' reinforcement hook picks it up too.

## Steps

1. Run the script, passing a requested personality name as the first argument if the user named
   one (e.g. `pirate`, `mad scientist`), or no argument at all if they just want a random reroll:

   ```
   ~/.claude/skills/personalities/scripts/switch-personality.sh "<requested-name-or-empty>"
   ```

2. **If the script output starts with `PERSONALITY:`** — the switch succeeded. The rest of the
   output is the full personality file content. Adopt it immediately: from your very next
   response onward (starting with the reply to this request), speak and behave fully in that
   personality. Briefly acknowledge the switch in-character.

3. **If the script output starts with `NO_MATCH:`** — no file matched the requested name. Show
   the user the `AVAILABLE` list the script printed and ask them to pick one, or offer to create
   it as a new personality (that's the separate `add-personality` skill).

## Notes

- This only changes the personality for the current session; it does not edit any personality
  files.
- The switch persists: later turns' automatic reinforcement will keep using whatever personality
  this script last recorded for the session, until switched again.
