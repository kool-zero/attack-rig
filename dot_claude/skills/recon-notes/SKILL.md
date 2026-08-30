---
name: recon-notes
description: Use when organizing reconnaissance notes during a security engagement or CTF - track discovered hosts, their open ports and services, and any credentials found, in a single structured engagement.md file. Trigger when the user says things like "log this host", "add these open ports", "note this cred", "start engagement notes", or "summarize what we've found so far".
---

# Recon notes

Keep messy recon output organized as you go. This skill maintains ONE structured
markdown file per engagement so hosts, services, and credentials never get lost in
scrollback. It is a note-keeping helper; it does not scan, exploit, or connect to
anything.

## The file

Work in `./engagement.md` in the current project directory (create it if missing). Use
this layout and keep it sorted by host/IP:

```markdown
# Engagement: <name or scope>

_Started: <date> · Scope: <in-scope hosts/CIDRs>_

## Hosts

### <ip> (<hostname>)
- **OS:** <os guess>
- **Ports:**
  | Port | Proto | Service | Version | Notes |
  |------|-------|---------|---------|-------|
  | 22   | tcp   | ssh     | OpenSSH 9.x | |
  | 445  | tcp   | smb     | | null session? |
- **Findings:** <short bullets: what's interesting, what to try next>

## Credentials

| User | Secret (masked) | Source host | Works on | Notes |
|------|-----------------|-------------|----------|-------|
| svc_web | `S3c…` (see vault) | web01 | smb@dc01 | domain cred |

## Open questions / to-do
- [ ] <next action>
```

## How to use it

1. **Read `engagement.md` first** (if it exists) so you extend it rather than clobber it.
2. **Adding a host or ports:** find the host's `###` section (create it if new), then
   add/update rows in its Ports table. Don't duplicate a port row; update it in place.
3. **Adding a credential:** append a row to the Credentials table. In the notes file,
   **mask secrets**: store only enough to recognize it (first few chars + `…`) and point
   to where the real value lives (a password manager / vault). Never paste full plaintext
   secrets or private keys into the notes file.
4. **Summarize:** when asked "what have we found", read the file and give a short
   rollup: host count, notable services, creds gathered, and the top open to-dos.

## Rules

- One `engagement.md` per engagement; keep it tidy and sorted.
- This skill only reads/writes the notes file. It never runs scans or logs into hosts.
- Treat everything in the file as sensitive: it's local working notes, not for sharing.
- If scope is unclear, ask which hosts/CIDRs are in scope before recording them.
