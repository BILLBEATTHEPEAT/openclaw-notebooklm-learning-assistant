---
name: review-flow
description: Lightweight review for an existing NotebookLM notebook.
user-invocable: true
---

# Review Flow

Use this skill when the user invokes `/review` to run a lightweight review
session based on an existing NotebookLM notebook.

## Command format

`/review "<notebook name or id>" length:<short|medium|long>`

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

3) Run the review flow in a friendly tutor tone.

### Short

- 3-bullet recap from the notebook sources.
- Ask 2-3 quick checks, one at a time.
- Generate 3 flashcards (or emulate if CLI artifact not available).
- Wrap up with brief encouragement.

### Medium (default)

- 5-bullet recap from the notebook sources.
- Ask 4-5 quick checks, one at a time.
- Generate 5 flashcards, present 5 now.
- Wrap up with brief encouragement.

### Long

- 8-bullet recap from the notebook sources.
- Ask 6-8 quick checks, one at a time.
- Generate 8-10 flashcards, present 5 now and 5 later.
- Wrap up with brief encouragement.

## NotebookLM usage

Use `nlm` CLI commands via exec.

- List notebooks: `nlm notebook list`
- Query notebook for summaries or questions: `nlm notebook query <id> --prompt "..."`
- Generate artifacts when available (quiz/flashcards) and otherwise emulate
  via `nlm notebook query` and format as flashcards.

## Output formatting

- Keep prompts concise and friendly.
- Ask one question at a time and wait for user response before continuing.
- When uncertain, ask for confirmation instead of guessing.
