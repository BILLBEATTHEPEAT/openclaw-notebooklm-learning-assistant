#!/usr/bin/env bash
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | bash
fi

uv tool install notebooklm-mcp-cli

if ! command -v jq >/dev/null 2>&1; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y jq
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y jq
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y jq
  else
    echo "jq is required but no package manager was found." >&2
    exit 1
  fi
fi

COOKIES_FILE="${NOTEBOOKLM_COOKIES_FILE:-$HOME/.notebooklm/cookies.txt}"
if [ ! -f "$COOKIES_FILE" ]; then
  echo "Missing cookies file: $COOKIES_FILE" >&2
  echo "Create it from your local browser DevTools cookie value." >&2
  exit 1
fi

nlm login --manual --file "$COOKIES_FILE"
mkdir -p "$HOME/.openclaw/skills"
mkdir -p "$HOME/.openclaw/workspace/skills"
CONFIG_PATH="${OPENCLAW_CONFIG_PATH:-$HOME/.openclaw/openclaw.json}"
if [ ! -f "$CONFIG_PATH" ]; then
  echo "OpenClaw config not found: $CONFIG_PATH" >&2
  exit 1
fi
tmp_file="$(mktemp)"
jq '
  .tools = (.tools // {})
  | .tools.allow = ((.tools.allow // []) + ["group:runtime"] | unique)
  | .tools.exec = ((.tools.exec // {})
    | .security = (.security // "allowlist")
    | .ask = (.ask // "on-miss")
    | .allowCommands = ((.allowCommands // []) + ["nlm"] | unique)
  )
' "$CONFIG_PATH" > "$tmp_file"
mv "$tmp_file" "$CONFIG_PATH"
echo "Updated $CONFIG_PATH with runtime allowlist for nlm."
echo "Restart OpenClaw to apply: openclaw gateway restart"
SKILL_DIR_USER="$HOME/.openclaw/skills/nlm-skill"
SKILL_DIR_WORKSPACE="$HOME/.openclaw/workspace/skills/nlm-skill"
if [ -d "$SKILL_DIR_USER" ] || [ -d "$SKILL_DIR_WORKSPACE" ]; then
  echo "NotebookLM skill already installed. Skipping install."
else
  nlm skill install openclaw
fi
RECITE_DIR="$HOME/.openclaw/skills/recite-flow"
RECITE_SKILL="$RECITE_DIR/SKILL.md"
if [ ! -f "$RECITE_SKILL" ]; then
  mkdir -p "$RECITE_DIR"
  cat <<'EOF' > "$RECITE_SKILL"
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
EOF
  echo "Installed recite-flow skill at $RECITE_SKILL"
else
  echo "recite-flow skill already present. Skipping install."
fi
REVIEW_DIR="$HOME/.openclaw/skills/review-flow"
REVIEW_SKILL="$REVIEW_DIR/SKILL.md"
if [ ! -f "$REVIEW_SKILL" ]; then
  mkdir -p "$REVIEW_DIR"
  cat <<'EOF' > "$REVIEW_SKILL"
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
EOF
  echo "Installed review-flow skill at $REVIEW_SKILL"
else
  echo "review-flow skill already present. Skipping install."
fi
DRILL_DIR="$HOME/.openclaw/skills/drill-flow"
DRILL_SKILL="$DRILL_DIR/SKILL.md"
if [ ! -f "$DRILL_SKILL" ]; then
  mkdir -p "$DRILL_DIR"
  cat <<'EOF' > "$DRILL_SKILL"
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
EOF
  echo "Installed drill-flow skill at $DRILL_SKILL"
else
  echo "drill-flow skill already present. Skipping install."
fi
