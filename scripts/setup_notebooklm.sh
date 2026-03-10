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
