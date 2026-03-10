# OpenClaw + NotebookLM Learning Assistant

Remote learning assistant MVP that uses OpenClaw for orchestration and
NotebookLM as the knowledge engine. The goal is a Duolingo-like experience for
any subject: recitation, review, quizzes, summaries, study guides, and audio
overviews.

## What this repo contains

- `docs/NOTEBOOKLM_OPENCLAW_MVP.md` - product and technical MVP plan
- `scripts/bootstrap_notebooklm.sh` - one-shot VPS setup + verification
- `scripts/setup_notebooklm.sh` - install + auth + skill install on a VPS
- `scripts/verify_notebooklm.sh` - sanity checks after setup

## Quick start (VPS)

1) Put your NotebookLM cookies into `~/.notebooklm/cookies.txt` (see docs).
2) Run one of the setup options:

Option A: curl | bash

```bash
curl -fsSL https://raw.githubusercontent.com/BILLBEATTHEPEAT/openclaw-notebooklm-learning-assistant/main/scripts/bootstrap_notebooklm.sh | bash
```

Option B: git clone

```bash
git clone https://github.com/BILLBEATTHEPEAT/openclaw-notebooklm-learning-assistant.git
cd openclaw-notebooklm-learning-assistant
bash scripts/bootstrap_notebooklm.sh
```

3) Verify:

```bash
bash scripts/verify_notebooklm.sh
```

## Docs

- MVP doc: `docs/NOTEBOOKLM_OPENCLAW_MVP.md`
