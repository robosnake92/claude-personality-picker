---
description: Interactively create a new personality file for the personalities plugin. Use when the user says "add a personality", "create a new personality", "make a new Claude persona", or similar — for this plugin's random session-personality system, not general character/roleplay requests.
disable-model-invocation: false
---

# Add Personality

Help the user create a new personality markdown file in `~/.claude/skills/personalities/personalities/`, matching the
style of the existing files in that directory, so it becomes eligible for random selection by
this plugin's `SessionStart` hook.

## Steps

1. **Look at existing personalities first.** Read 1-2 files from `~/.claude/skills/personalities/personalities/*.md`
   (e.g. `caveman.md`, `pirate.md`) to internalize the established format before writing a new
   one. Each file is a freeform markdown persona spec, roughly:
   - `# NAME PERSONALITY <emoji>` heading
   - `## Name: <in-character full name/title>` subheading
   - A short in-character opening line
   - A bulleted list of concrete behavioral rules: speech pattern, vocabulary quirks, how it maps
     technical concepts (functions, bugs, git, etc.) to its theme, emotional reactions to
     good/bad outcomes, recurring flavor references, and usually a music-recommendation quirk and
     an "unprompted anecdote" quirk.
   - Instructions are written as direct imperatives ("SPEAK LIKE X", "ALWAYS Y"), not
     descriptions of the character in third person.

2. **Ask the user** (if $ARGUMENTS doesn't already specify it) what persona they want — a theme
   or character is enough ("pirate", "film noir detective", "surfer", etc.). Don't demand they
   spec out every bullet point themselves; you should flesh it out.

3. **Draft the full file content** yourself, in the same style and level of detail as the
   existing files — same section shape, similarly thorough bullet list, code/dev-concept mappings
   specific to the new theme, emojis used consistently with the theme. Keep the tone fun and the
   voice consistent throughout the bullets themselves (i.e. if the persona speaks in a particular
   register, the instructions describing it can lean into that register too, as `caveman.md` does).

   **Isolate this draft from whatever personality is currently active in this session.** A
   personality may currently be injected into your context (via this plugin's own `SessionStart`/
   `UserPromptSubmit` hooks) — its voice, vocabulary, and quirks are for your own conversational
   behavior right now and must not leak into the new file's content. The new personality's speech
   patterns, vocabulary, tech-concept mappings, emoji set, music picks, and anecdotes must come
   only from its own theme, never from the currently-active one. Before writing, sanity-check the
   draft: if any phrase, quirk, or vocabulary item traces back to the active personality rather
   than the new theme, cut it.

4. **Pick a filename**: lowercase, underscore-separated, derived from the persona name (e.g.
   `film_noir_detective.md`). Confirm it doesn't already exist in `~/.claude/skills/personalities/personalities/`.

5. **Show the user the drafted content** and ask for confirmation or edits before writing.

6. **Write the file** to `~/.claude/skills/personalities/personalities/<name>.md` once approved.

7. Tell the user the personality is now in the rotation — no other setup needed, since the
   plugin's hooks pick randomly from every `.md` file in that directory at session start.

## Notes

- Do not modify, rename, or delete any existing personality files.
- Do not touch this plugin's other files (`hooks/`, `scripts/`, `state/`, `.claude-plugin/`) as
  part of this workflow — this skill only ever writes new files into `personalities/`.
