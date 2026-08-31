# attack-rig

Your attack box as code — forked from [0xjams/attack-rig](https://github.com/0xjams/attack-rig)
with pentest-specific additions layered on top.

One command to converge the personal layer. One playbook for the system layer.

---

## First-time setup on a fresh Kali box

### 1. Apply the dotfiles layer (chezmoi)

```bash
chezmoi init --apply git@github.com:kool-zero/attack-rig.git
```

This runs on the first apply and handles everything chezmoi manages:
- oh-my-zsh + fast-syntax-highlighting + Catppuccin Mocha theme
- zshrc, zshenv, tmux config, starship prompt
- All tool binaries via `.chezmoiexternal.toml`:
  chisel, ligolo-proxy, agent.exe, agent-linux, goshs, penelope,
  navi, atuin, yazi, glow — always latest, arch-correct
- Claude Code + Codex via npm into `~/.local`
- just, starship via upstream installers
- TPM + tmux plugins
- Your pentest aliases, VPN alias mechanism, navi cheats, recon-notes Claude skill
- `~/payloads` symlink → `~/.local/share/payloads/` (where payload binaries land)

> You'll be prompted for your GitHub username — this populates `~/.ssh/authorized_keys`
> from your GitHub public keys automatically.

### 2. System-level provisioning (run once as a sudoer)

```bash
ansible-playbook ~/.bootstrap/kali-system.yml -K
```

This handles what chezmoi can't (needs root, modifies services):
- xrdp + xorgxrdp + XFCE desktop (for Guacamole/RDP access)
- xrdp TLS key permissions fix (prevents Guacamole login failures)
- Syncthing service + `~/data/` directory
- Docker group membership
- rockyou.txt decompression
- Certipy via pipx
- ProjectDiscovery Go tools (nuclei, subfinder, httpx, naabu, katana, dnsx)
- nuclei template update

### 3. Clone your tools repo (wrapper scripts)

```bash
git clone git@github.com:kool-zero/tools.git ~/tools
```

Your personal wrapper scripts (`ligolo.sh` → `ligolo`, `chisel.sh` → `chisel`,
`newtarget.sh` → `newtarget`) live here. They reference
`~/.local/bin/chisel` and `~/.local/bin/ligolo-proxy` which chezmoi
already placed there. Install them to PATH:

```bash
for f in ~/tools/*.sh; do sudo install -m 755 "$f" /usr/local/bin/"$(basename "$f" .sh)"; done
```

### 4. One-time interactive steps

```bash
claude          # log in with your Anthropic Pro/Max account
touch ~/.enable_sshd && chezmoi apply   # enable SSH (optional — Kali ships it off)
```

### 5. Optional: Ghostty + Code-OSS

```bash
ansible-playbook ~/.bootstrap/ghostty.yml -K
```

---

## Day-to-day

```bash
just update       # pull latest tool versions + re-apply dotfiles
just tools        # audit what's installed vs missing
just new-project forest 10.10.11.35   # scaffold an engagement directory
just --list       # all available recipes
```

**Staying current:** `just update` runs `chezmoi apply --refresh-externals`.
Tool binaries (chisel, ligolo, goshs, etc.) check for newer releases weekly and
update automatically. No manual version chasing.

**VPN connect:** add a line to `~/data/vpns/vpn-aliases.conf`:
```
htbacademy=htb/academy-regular.ovpn
```
Open a new shell → `htbacademy` connects. Syncthing carries this file
across all your boxes automatically.

**Resync alias:** `resync` = `chezmoi apply --refresh-externals` (defined in
`~/.pentest-aliases.sh`).

---

## What we keep from the original attack-rig

Everything — their dotfiles, tool management, and install scripts are
the foundation. We only extend, never replace.

## What we add

| File | What it adds |
|---|---|
| `packages.yaml` | proxychains4, netexec, hashcat, john, seclists, golang-go, pipx, docker.io, lazygit |
| `dot_pentest-aliases.sh` | nxc-spray/hspray/bh, webrecon, vulnscan, crack, resync, toolkit-help, VPN aliases |
| `dot_zshrc.tmpl` | sources pentest aliases + VPN alias mechanism |
| `dot_justfile.tmpl` | extended new-project (notes.md, .env, targets.txt), handler recipe |
| `pentest.cheat.tmpl` | full pentest cheat sheet for navi Ctrl-G |
| `recon-notes/SKILL.md` | Claude Code skill tuned to our directory structure and tool names |
| `dot_bootstrap/kali-system.yml` | xrdp, syncthing, docker group, ProjectDiscovery, Certipy |
