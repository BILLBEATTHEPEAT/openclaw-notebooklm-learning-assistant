---
name: drill-flow
description: Intensive weak-point drilling for an existing NotebookLM notebook.
user-invocable: true
---

# Drill Flow

Use this skill when the user invokes `/drill` to run an intensive drill session
based on an existing NotebookLM notebook.

## Command format

`/drill "<notebook name or id>" length:<short|medium|long>`

- Notebook name is required.
- `length` is optional. Default to `medium`.

## Behavior

1) Parse the command arguments.
   - Extract the notebook query string.
   - Extract `length:` when provided.
   - If length is invalid or missing, set to `medium`.

2) Find the notebook.
   - Run `nlm notebook list`.
   - Choose the best match using: exact > prefix > substring > fuzzy.
   - If ambiguous or low confidence, ask for confirmation and show top 3.
   - Accept confirmation by number (1/2/3) or full title.

3) Run the drill flow in a friendly tutor tone.

### Short

- Run a quick diagnostic.
- Target 3 weak points.
- Ask 6-8 drill questions, one at a time.
- Generate flashcards for weak points.

### Medium (default)

- Run a diagnostic to identify weak areas.
- Target 5 weak points.
- Ask 10-12 drill questions, one at a time.
- Use explain-back prompts and correct with hints.
- Generate flashcards for weak points.

### Long (uncapped, explicit stop only)

- Run a diagnostic and prioritize weak areas.
- Continue drilling weak points without fixed limits.
- Use iterative correction and hints.
- Generate flashcards for each weak area.
- Do not end unless the user says "stop", "end", or "pause".

## Weak-point priority

- Prefer weak points from the current session (incorrect or uncertain answers).
- If no performance yet, infer from notebook sections and ask for confidence.

## NotebookLM usage

Use `nlm` CLI commands via exec.

- List notebooks: `nlm notebook list`
- Query notebook for questions: `nlm notebook query <id> --prompt "..."`
- Generate artifacts when available (quiz/flashcards) and otherwise emulate
  via `nlm notebook query` and format as flashcards.

## Output formatting

- Keep prompts concise and friendly.
- Ask one question at a time and wait for user response before continuing.
- When uncertain, ask for confirmation instead of guessing.
