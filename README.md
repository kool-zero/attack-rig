# attack-rig

Forked from [0xjams/attack-rig](https://github.com/0xjams/attack-rig) with
pentest-specific additions.

## Fresh Kali setup — three steps

### Step 1: Install chezmoi and apply

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
export PATH="$HOME/bin:$PATH"
chezmoi init --apply https://github.com/kool-zero/attack-rig.git
```

Uses HTTPS for the initial clone (works without SSH keys set up yet).
Takes several minutes — downloads all tool binaries, installs shell
config, starship, navi, atuin, tmux plugins, etc.

### Step 2: System bootstrap (needs sudo)

```bash
ansible-playbook ~/.bootstrap/kali-system.yml -K -e "target_user=$(whoami)"
```

Handles xrdp, syncthing, docker, Certipy, ProjectDiscovery Go tools,
rockyou.txt decompression. Run once.

### Step 3: Clone tools repo + one-time setup

```bash
# SSH key for GitHub (if not already done)
ssh-keygen -t ed25519 -C "kali-box"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub -> Settings -> SSH keys

# Clone your wrapper scripts
git clone git@github.com:kool-zero/tools.git ~/tools
for f in ~/tools/*.sh; do sudo install -m 755 "$f" /usr/local/bin/"$(basename "$f" .sh)"; done

# Log into Claude Code
claude

# Verify everything
just tools
```

## Day-to-day

```bash
resync                              # chezmoi apply + refresh tool versions
just tools                          # audit what's installed
just new-project forest 10.10.11.35 # scaffold engagement directory
toolkit-help                        # show pentest alias reference
```

## IMPORTANT: pushing changes to this repo

**Never use GitHub's web file upload** — it silently drops files starting
with `.` (dotfiles). Always use git CLI:

```bash
git add -A
git commit -m "description"
git push
```
