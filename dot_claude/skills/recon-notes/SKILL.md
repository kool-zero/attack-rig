---
name: recon-notes
description: Use when organizing reconnaissance notes during a security engagement or CTF. Trigger when the user says things like "log this host", "add these ports", "note this cred", "start engagement notes", "summarize what we've found", or pastes nmap/tool output and asks you to record it.
---

# Recon Notes

Keep messy recon output organized as you go. Maintains ONE structured markdown
file per engagement. Note-keeping only — never scans, exploits, or connects to anything.

## Directory context

Engagements are scaffolded with `just new-project <name> <ip>` which creates:

```
<name>/
├── notes.md        ← the file this skill maintains
├── recon/          ← raw scan output (nmap .txt files)
├── loot/           ← captured creds, hashes, flags (gitignored)
├── exploits/       ← PoC code used against this target
├── notes/          ← additional reference notes
├── scans/          ← raw scanner output
└── bin/            ← per-engagement tools (on PATH via direnv)
```

When in an engagement directory, `$TARGET`, `$LOOT`, and `$ENGAGEMENT` are set by
direnv automatically. Payloads to drop on targets are at `~/.local/share/payloads/`
(symlinked as `~/payloads`).

## The file

Work in `./notes.md` in the current directory (create if missing). Layout:

```markdown
# <engagement-name>

- Platform: HTB / THM / WKL / HackSmarter
- IP: <ip>
- OS: <guess>
- Started: <date>

## Hosts

### <ip> (<hostname if known>)
- **OS:**
- **Ports:**
  | Port | Proto | Service | Version | Notes |
  |------|-------|---------|---------|-------|
  |      |       |         |         |       |
- **Findings:**

## Credentials

| User | Secret (masked) | Source | Works on | Notes |
|------|-----------------|--------|----------|-------|

## Flags

| Flag | Value | Location |
|------|-------|----------|

## Open / to-do
- [ ]
```

## Rules

- One `./notes.md` per engagement — extend, never rewrite from scratch.
- Read the file first before adding anything, so you don't duplicate.
- **Mask credentials** — store only enough to recognize it (first chars + `…`);
  real values go in `loot/` which is gitignored.
- Never run scans, exploit anything, or connect to targets.
- If scope is unclear, ask before recording a host.

## Tool context

- **nxc / netexec** — SMB/LDAP enum and spraying
- **ligolo** — pivot via `ligolo start`, route via `ligolo route <cidr>` (wrapper script)
- **chisel** — alternate pivot via `chisel server` / `chisel client` (wrapper script)
- **certipy** — ADCS enum via `certipy find -vulnerable`
- **bloodhound** — AD graph (`docker compose up -d` in the bloodhound dir)
- **penelope** — reverse shell catcher; `penelope <port> --mcp` for Claude Code integration
- **payloads** — `~/payloads/` contains chisel.exe, agent.exe, agent-linux for dropping on targets
