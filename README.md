# OpenClaw + NotebookLM Learning Assistant

Remote learning assistant MVP that uses OpenClaw for orchestration and
NotebookLM as the knowledge engine. The goal is a Duolingo-like experience for
any subject: recitation, review, quizzes, summaries, study guides, and audio
overviews.

## What this repo contains

- `docs/NOTEBOOKLM_OPENCLAW_MVP.md` - product and technical MVP plan
- `scripts/setup_notebooklm.sh` - install + auth + skill install on a VPS
- `scripts/verify_notebooklm.sh` - sanity checks after setup

## Quick start (VPS)

1) Put your NotebookLM cookies into `cookies.txt` (see docs).
2) Run the setup script:

```bash
bash scripts/setup_notebooklm.sh
```

3) Verify:

```bash
bash scripts/verify_notebooklm.sh
```

## Docs

- MVP doc: `docs/NOTEBOOKLM_OPENCLAW_MVP.md`
