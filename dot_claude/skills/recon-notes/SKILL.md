---
name: recon-notes
description: Use when organizing reconnaissance notes during a security engagement or CTF. Trigger when the user says things like "log this host", "add these ports", "note this cred", "start engagement notes", "summarize what we've found", or pastes nmap/tool output and asks you to record it.
---

# Recon Notes

Maintain ONE structured markdown file per engagement. Note-keeping only — never
scans, exploits, or connects to anything.

## Directory context

Engagements scaffolded with `just new-project <name> <ip>`:

```
<name>/
├── notes.md        ← this skill maintains this file
├── recon/          ← raw scan output
├── loot/           ← captured creds, hashes, flags (gitignored)
├── exploits/       ← PoC code
├── bin/            ← per-engagement tools (on PATH via direnv)
```

`$TARGET`, `$LOOT`, `$ENGAGEMENT` set by direnv on cd.
Payloads at `~/payloads` (symlink to `~/.local/share/payloads/`).

## File layout

```markdown
# <name>

- Platform: HTB / THM / WKL / HackSmarter
- IP: <ip>
- OS:
- Started: <date>

## Hosts

### <ip>
- **Ports:**
  | Port | Proto | Service | Version | Notes |
  |------|-------|---------|---------|-------|

## Credentials

| User | Secret (masked) | Source | Works on | Notes |
|------|-----------------|--------|----------|-------|

## Flags

| Flag | Value | Location |
|------|-------|----------|

## To-do
- [ ]
```

## Rules

- Read `./notes.md` first before adding anything
- Mask credentials — first chars + "..." — real values in `loot/`
- Never run scans or connect to targets
- Ask about scope before recording if unclear
