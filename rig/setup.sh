#!/usr/bin/env bash
set -euo pipefail

# setup.sh — run as zero after bootstrap + reboot.
# One command does everything: chezmoi, ansible, tools repo, verification.
#
# Usage:
#   bash ~/setup.sh

REPO_URL="https://github.com/kool-zero/attack-rig.git"
TOOLS_URL="git@github.com:kool-zero/tools.git"

echo "[setup] Starting full setup for $(whoami)"
echo ""

# ── Ensure PATH includes chezmoi and local bins ──────────────────────────────
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"

# ── Step 1: chezmoi ──────────────────────────────────────────────────────────
echo "[setup] Step 1/4 — Applying chezmoi (dotfiles + tool binaries)..."
echo "  This downloads all tool binaries, configures shell, tmux, etc."
echo "  Takes several minutes on first run."
echo ""
chezmoi init --apply "$REPO_URL"
echo ""
echo "[setup] chezmoi complete."
echo ""

# ── Step 2: System bootstrap ─────────────────────────────────────────────────
echo "[setup] Step 2/4 — System bootstrap (xrdp, syncthing, docker, pentest tools)..."
echo "  You may be prompted for your password (sudo)."
echo ""
ansible-playbook ~/.bootstrap/kali-system.yml -K -e "target_user=$(whoami)"
echo ""
echo "[setup] System bootstrap complete."
echo ""

# ── Step 3: Tools repo ───────────────────────────────────────────────────────
echo "[setup] Step 3/4 — Cloning tools repo (ligolo, chisel, newtarget wrappers)..."
if [ -d "$HOME/tools/.git" ]; then
    echo "  ~/tools already exists — pulling latest"
    git -C "$HOME/tools" pull --ff-only 2>/dev/null || true
else
    git clone "$TOOLS_URL" "$HOME/tools" 2>/dev/null || {
        echo "  WARNING: Could not clone tools repo."
        echo "  You may need to add this box's SSH key to GitHub first."
        echo "  Run: cat ~/.ssh/id_ed25519.pub"
        echo "  Add it to GitHub -> Settings -> SSH keys"
        echo "  Then: git clone $TOOLS_URL ~/tools"
    }
fi

# Install wrapper scripts to PATH
if [ -d "$HOME/tools" ]; then
    for f in ~/tools/*.sh; do
        [ -f "$f" ] && sudo install -m 755 "$f" /usr/local/bin/"$(basename "$f" .sh)"
    done
    echo "  Wrapper scripts installed to /usr/local/bin/"
fi
echo ""

# ── Step 4: Verify ───────────────────────────────────────────────────────────
echo "[setup] Step 4/4 — Verification"
echo ""

# Reload shell config
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"

# Run the audit
if command -v just >/dev/null 2>&1; then
    just tools
else
    echo "  WARNING: 'just' not found on PATH. Open a new shell and run: just tools"
fi

echo ""
echo "============================================================"
echo "  Setup complete."
echo ""
echo "  Remaining manual steps:"
echo "    claude              # log into your Anthropic account"
echo "    toolkit-help        # see all pentest aliases"
echo ""
echo "  To connect via Guacamole/RDP:"
echo "    Host: $(hostname -I | awk '{print $1}')"
echo "    Port: 3389"
echo "    User: $(whoami)"
echo ""
echo "  Open a NEW terminal/SSH session for all shell"
echo "  changes to take effect (starship prompt, aliases, etc)."
echo "============================================================"
