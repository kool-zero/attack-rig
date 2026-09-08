# attack-rig

Forked from [0xjams/attack-rig](https://github.com/0xjams/attack-rig) with
pentest-specific additions. Creates user `zero`, provisions everything.

## Fresh Kali setup — two scripts, that's it

### From the Proxmox console (as kali/kali):

```bash
# Change default password
passwd

# Download and run bootstrap (do NOT pipe through curl | bash)
wget https://raw.githubusercontent.com/kool-zero/attack-rig/main/bootstrap.sh
bash bootstrap.sh
```

Bootstrap will:
- Create user `zero` with passwordless sudo (prompts you to set password)
- Generate an SSH key (prompts you to add it to GitHub)
- Install all prerequisites (ansible, go, node, npm, chezmoi, etc.)
- Grow the disk to fill available space
- Install qemu-guest-agent
- Download `setup.sh` into zero's home directory
- Reboot automatically

### After reboot, SSH in as zero:

```bash
ssh zero@<kali-ip>
bash ~/setup.sh
```

Setup will:
- Apply chezmoi (all dotfiles, tool binaries, shell config, tmux, starship, navi, atuin)
- Run ansible system bootstrap (xrdp, syncthing, docker, Certipy, ProjectDiscovery tools)
- Clone your tools repo (ligolo, chisel, newtarget wrappers)
- Run `just tools` to verify everything

### One manual step after setup:

```bash
claude    # log into your Anthropic account (one-time browser auth)
```

## Day-to-day

```bash
resync                              # chezmoi apply + refresh tool versions
just tools                          # audit what's installed
just new-project forest 10.10.11.35 # scaffold engagement directory
toolkit-help                        # show pentest alias reference
just --list                         # all available just recipes
```

## IMPORTANT: pushing changes to this repo

**Never use GitHub web file upload** — it silently drops dotfiles.
Always use git CLI:
```bash
git add -A
git commit -m "description"
git push
```
