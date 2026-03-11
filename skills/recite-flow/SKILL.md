---
name: recite-flow
description: One-line recitation/refresh flow for existing NotebookLM notebooks.
user-invocable: true
---

# Recite Flow

Use this skill when the user invokes `/recite` to run a recitation/refresh
session based on an existing NotebookLM notebook.

## Command format

`/recite "<notebook name or id>" length:<short|medium|long>`

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

3) Run the recitation flow in a friendly tutor tone.

### Short (5-7 min)

- 3-bullet recap from the notebook sources.
- Ask 3 quick questions and wait after each answer.
- Generate 3 flashcards (or emulate if CLI artifact not available).
- Wrap up with a short encouragement.

### Medium (12-18 min)

- 6-bullet recap and ask the user to paraphrase each bullet one-by-one.
- Ask 5 concept checks, one at a time.
- Generate a 5-question quiz, one at a time.
- Generate 5 flashcards, present 5 now.
- End with a 7-day review plan.

### Long (uncapped, explicit stop only)

- Cover all major sections without fixed limits.
- For each section: concept checks and a quiz set.
- Generate flashcards for weak points.
- Periodically ask: continue, go deeper, or move on.
- Do not end unless the user says "stop", "end", or "pause".

## NotebookLM usage

Use `nlm` CLI commands via exec.

- List notebooks: `nlm notebook list`
- Query notebook for summaries or questions: `nlm notebook query <id> --prompt "..."`
- Generate artifacts when available (quiz/flashcards) and otherwise emulate
  via `nlm notebook query` and format as quiz/flashcards.

## Output formatting

- Keep prompts concise and friendly.
- Ask one question at a time and wait for user response before continuing.
- When uncertain, ask for confirmation instead of guessing.
