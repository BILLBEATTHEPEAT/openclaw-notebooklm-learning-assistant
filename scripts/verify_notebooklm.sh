#!/usr/bin/env bash
set -euo pipefail

if ! command -v nlm >/dev/null 2>&1; then
  echo "nlm not found on PATH." >&2
  exit 1
fi

echo "Checking auth..."
nlm login --check

echo "Listing notebooks (may be empty if new account)..."
nlm notebook list

echo "Done."
