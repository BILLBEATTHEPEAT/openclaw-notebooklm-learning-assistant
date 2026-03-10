# NotebookLM Cookie Extraction

This document explains how to extract the NotebookLM cookie on your local
machine so the VPS can authenticate via `nlm login --manual`.

## Steps

1) Go to `https://notebooklm.google.com` and log in.
2) Open DevTools (F12 or Cmd+Option+I).
3) Open the Network tab and filter by `batchexecute`.
4) Trigger any request (click a notebook).
5) Open a `batchexecute` request and find `cookie:` in Request Headers.
6) Copy only the value after `cookie:`.
7) Paste it into `~/.notebooklm/cookies.txt` on the VPS.

Then run:

```bash
nlm login --manual --file ~/.notebooklm/cookies.txt
```
