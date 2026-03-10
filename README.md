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
- Cookie extraction: `docs/COOKIE_EXTRACTION.md`

## OpenClaw skill install note

If OpenClaw was installed in a non-default location, make sure the skill
directory exists before running the setup scripts. The scripts create both
`~/.openclaw/skills` and `~/.openclaw/workspace/skills` to avoid interactive
prompts.

## Cookie extraction (local machine)

1) Go to `https://notebooklm.google.com` and log in.
2) Open DevTools (F12 or Cmd+Option+I).
3) Open the Network tab and filter by `batchexecute`.
4) Trigger any request (click a notebook).
5) Open a `batchexecute` request and find `cookie:` in Request Headers.
6) Copy only the value after `cookie:`.
7) Save it to `~/.notebooklm/cookies.txt` on the VPS.
