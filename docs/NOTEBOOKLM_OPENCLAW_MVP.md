# NotebookLM + OpenClaw MVP (Remote Learning Assistant)

## Purpose

Build a minimal, production-viable MVP for a remote learning assistant that
leverages NotebookLM as the knowledge engine and OpenClaw as the orchestration
layer. The assistant should support learning workflows (recitation, review,
quizzing, summaries, study guides, audio overviews) across any subject area,
not only languages.

## Background

We evaluated two unofficial NotebookLM tools:

1) https://github.com/teng-lin/notebooklm-py
2) https://github.com/jacob-bd/notebooklm-mcp-cli

We also reviewed OpenClaw docs covering:

- Getting started, skills, skill creation, and skills config
- Plugins and channel integrations

The deployment target is a remote VPS with limited resources (2GB RAM) running
Alibaba Cloud Linux 3 (OpenAnolis Edition).

## Decision Summary

### Chosen NotebookLM tool: notebooklm-mcp-cli

Reasoning:

- It ships a built-in OpenClaw skill installer: `nlm skill install openclaw`
  (no hand-made SKILL.md required).
- It provides a headless-friendly authentication flow with manual cookies
  (`nlm login --manual --file cookies.txt`) which avoids browser automation on
  the VPS.
- It integrates cleanly into OpenClaw and supports both CLI usage and the
  Model Context Protocol (MCP) server.

### Install method on VPS: uv tool install

Reasoning:

- Lower overhead than a full venv or pipx on a 2GB RAM VPS.
- Fast and resource-efficient for a simple CLI tool install.

## What the MVP Can Do

The MVP should enable the assistant to:

- Ingest sources into NotebookLM (URLs, PDFs, Drive docs, text).
- Ask questions and retrieve grounded answers from NotebookLM sources.
- Generate learning artifacts:
  - quizzes, flashcards, study guides, briefings
  - slide decks, mind maps, data tables
  - audio overviews (podcast-style)
- Export artifacts to standard formats (JSON, Markdown, CSV, PPTX, PDF).

These capabilities support Duolingo-like learning flows but for any topic:

- Guided learning sessions
- Daily review and spaced repetition
- Summary and recitation
- Knowledge checks and feedback

## Architecture Overview

OpenClaw provides:

- Gateway runtime and message routing
- Skills system (AgentSkills compatible)
- Plugins for channels (Discord/WhatsApp already set up)

NotebookLM provides:

- Source ingestion, research, and chat
- Artifact generation and export

Integration approach:

- Install `notebooklm-mcp-cli` on the VPS
- Authenticate via manual cookies
- Install the OpenClaw skill bundled by the CLI
- OpenClaw uses the installed skill to invoke `nlm` commands

## Comparison Notes (Tooling)

### notebooklm-py

Pros:
- Strong Python API for custom pipelines
- Supports CI-friendly `NOTEBOOKLM_AUTH_JSON`

Cons for this MVP:
- Requires browser-based login on a local machine to produce storage_state.json
- Extra overhead if only needed for CLI + OpenClaw integration

### notebooklm-mcp-cli

Pros:
- Purpose-built for CLI + MCP usage
- First-class OpenClaw skill installer
- Manual cookie flow is easy for headless VPS

Cons:
- Still depends on undocumented Google APIs (same as notebooklm-py)

## MVP Setup Plan (Assumes OpenClaw + Channels Already Running)

1) Install uv
2) Install notebooklm-mcp-cli
3) Authenticate with manual cookies
4) Install OpenClaw skill
5) Verify by sending a message to OpenClaw

## Minimal Script (MVP)

Save this on the VPS as `setup_notebooklm.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1) Install uv if missing
curl -fsSL https://astral.sh/uv/install.sh | bash

# 2) Install NotebookLM CLI
uv tool install notebooklm-mcp-cli

# 3) Login (manual cookie file)
nlm login --manual --file ./cookies.txt

# 4) Install OpenClaw skill
nlm skill install openclaw
```

## Authentication Notes

Manual cookie flow (recommended for VPS):

1) Open local Chrome/Brave and go to https://notebooklm.google.com
2) Open DevTools -> Network -> filter `batchexecute`
3) Click any request -> Request Headers -> copy the `cookie:` value
4) Paste into `cookies.txt` on the VPS
5) Run `nlm login --manual --file cookies.txt`

## Risks and Constraints

- Both tools use undocumented Google APIs. Changes can break them.
- Cookies expire periodically; re-login is required.
- VPS has limited RAM; keep installs minimal and avoid heavy services.

## Next Steps (Post-MVP)

- Add skill overrides in `~/.openclaw/skills` for custom pedagogy
- Add automation hooks (daily reviews, spaced repetition)
- Add artifact post-processing (formatting, indexing, export pipelines)
- Consider a small database for tracking learner progress
