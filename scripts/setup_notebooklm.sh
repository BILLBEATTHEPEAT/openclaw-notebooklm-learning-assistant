#!/usr/bin/env bash
set -euo pipefail

if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | bash
fi

uv tool install notebooklm-mcp-cli

COOKIES_FILE="${NOTEBOOKLM_COOKIES_FILE:-$HOME/.notebooklm/cookies.txt}"
if [ ! -f "$COOKIES_FILE" ]; then
  echo "Missing cookies file: $COOKIES_FILE" >&2
  echo "Create it from your local browser DevTools cookie value." >&2
  exit 1
fi

nlm login --manual --file "$COOKIES_FILE"
mkdir -p "$HOME/.openclaw/workspace/skills"
nlm skill install openclaw
