#!/usr/bin/env bash
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | bash
fi

uv tool install notebooklm-mcp-cli

COOKIES_FILE="${NOTEBOOKLM_COOKIES_FILE:-$HOME/.notebooklm/cookies.txt}"
if [ ! -f "$COOKIES_FILE" ]; then
  echo "Missing cookies file: $COOKIES_FILE" >&2
  echo "Place your NotebookLM cookie value in this file." >&2
  exit 1
fi

nlm login --manual --file "$COOKIES_FILE"
nlm login --check
mkdir -p "$HOME/.openclaw/skills"
mkdir -p "$HOME/.openclaw/workspace/skills"
nlm skill install openclaw
nlm notebook list
