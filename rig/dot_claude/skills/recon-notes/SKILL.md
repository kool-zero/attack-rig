---
name: recon-notes
description: Use when organizing recon notes during a security engagement or CTF.
---

# Recon Notes

Maintain ONE structured markdown file per engagement. Note-keeping only.

## Directory context

Engagements scaffolded with `just new-project <name> <ip>`:
- `notes.md` — this skill maintains this file
- `recon/` — raw scan output
- `loot/` — captured creds/hashes (gitignored)
- `bin/` — per-engagement tools (on PATH via direnv)

`$TARGET`, `$LOOT`, `$ENGAGEMENT` set by direnv on cd.

## Rules
- Read `./notes.md` first before adding
- Mask credentials — first chars + "..." — real values in `loot/`
- Never run scans or connect to targets
- Ask about scope before recording if unclear
