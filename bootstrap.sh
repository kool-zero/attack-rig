#!/usr/bin/env bash
set -euo pipefail

# bootstrap.sh — run on a fresh Kali box.
#
# DO NOT pipe this through curl | bash — download it first, then run:
#   wget https://raw.githubusercontent.com/kool-zero/attack-rig/main/bootstrap.sh
#   bash bootstrap.sh
#
# Creates user 'zero', installs all prerequisites, reboots.
# After reboot, SSH in as zero and run setup.sh (also downloaded for you).

TARGET_USER="zero"
REPO="https://raw.githubusercontent.com/kool-zero/attack-rig/main"

echo "[bootstrap] Setting up $TARGET_USER on $(hostname)"
echo ""

# ── Create user ───────────────────────────────────────────────────────────────
if ! id "$TARGET_USER" &>/dev/null; then
    sudo useradd -m -s /usr/bin/zsh -G sudo "$TARGET_USER"
    echo "[bootstrap] Created user $TARGET_USER"
else
    echo "[bootstrap] User $TARGET_USER already exists — skipping creation"
fi

# ── Set password (reads from terminal, not pipe) ─────────────────────────────
echo "[bootstrap] Set a password for $TARGET_USER:"
sudo passwd "$TARGET_USER" < /dev/tty

# ── Passwordless sudo ─────────────────────────────────────────────────────────
echo "$TARGET_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$TARGET_USER > /dev/null
sudo chmod 0440 /etc/sudoers.d/$TARGET_USER
sudo visudo -c > /dev/null
echo "[bootstrap] Passwordless sudo configured"

# ── SSH key ───────────────────────────────────────────────────────────────────
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "[bootstrap] No SSH key found. Generate one now? (needed for GitHub)"
    ssh-keygen -t ed25519 -C "kali-box" < /dev/tty
    echo ""
    echo "[bootstrap] Add this public key to GitHub -> Settings -> SSH keys:"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    echo "[bootstrap] Press Enter after adding it to GitHub..." 
    read -r < /dev/tty
    ssh -T git@github.com 2>&1 || true
fi

# ── Copy SSH key to zero ─────────────────────────────────────────────────────
sudo mkdir -p /home/$TARGET_USER/.ssh
sudo cp "$HOME/.ssh/id_ed25519" /home/$TARGET_USER/.ssh/ 2>/dev/null || true
sudo cp "$HOME/.ssh/id_ed25519.pub" /home/$TARGET_USER/.ssh/ 2>/dev/null || true
sudo chmod 700 /home/$TARGET_USER/.ssh
sudo chmod 600 /home/$TARGET_USER/.ssh/id_ed25519 2>/dev/null || true
sudo chmod 644 /home/$TARGET_USER/.ssh/id_ed25519.pub 2>/dev/null || true
sudo chown -R $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.ssh
echo "[bootstrap] SSH key copied to $TARGET_USER"

# ── Accept GitHub host key ────────────────────────────────────────────────────
ssh-keyscan github.com 2>/dev/null | sudo tee /home/$TARGET_USER/.ssh/known_hosts > /dev/null
sudo chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.ssh/known_hosts
sudo chmod 600 /home/$TARGET_USER/.ssh/known_hosts
sudo chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/.ssh/known_hosts
echo "[bootstrap] GitHub host key accepted"

# ── Install prerequisites ─────────────────────────────────────────────────────
echo "[bootstrap] Installing packages (this takes a minute)..."
sudo apt update -qq
sudo apt install -y -qq ansible git golang-go nodejs npm pipx lazygit zsh \
    cloud-guest-utils qemu-guest-agent > /dev/null 2>&1
echo "[bootstrap] Packages installed"

# ── Grow disk ─────────────────────────────────────────────────────────────────
ROOT_DEV=$(findmnt -no SOURCE /)
ROOT_DISK=$(lsblk -no PKNAME "$ROOT_DEV")
ROOT_PART=$(echo "$ROOT_DEV" | grep -oP '\d+$')
sudo growpart "/dev/$ROOT_DISK" "$ROOT_PART" 2>/dev/null || true
sudo resize2fs "$ROOT_DEV" 2>/dev/null || true
echo "[bootstrap] Disk grown"

# ── qemu-guest-agent ──────────────────────────────────────────────────────────
sudo systemctl enable --now qemu-guest-agent 2>/dev/null || true
echo "[bootstrap] qemu-guest-agent enabled"

# ── Install chezmoi for zero ──────────────────────────────────────────────────
sudo -u $TARGET_USER bash -c 'sh -c "$(curl -fsLS get.chezmoi.io)"'
echo "[bootstrap] chezmoi installed for $TARGET_USER"

# ── Download setup.sh for zero to run after reboot ────────────────────────────
sudo -u $TARGET_USER wget -q "$REPO/setup.sh" -O /home/$TARGET_USER/setup.sh
sudo chmod +x /home/$TARGET_USER/setup.sh
sudo chown $TARGET_USER:$TARGET_USER /home/$TARGET_USER/setup.sh
echo "[bootstrap] setup.sh downloaded to /home/$TARGET_USER/"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Bootstrap complete."
echo ""
echo "  After reboot, SSH in as $TARGET_USER:"
echo "    ssh $TARGET_USER@$(hostname -I | awk '{print $1}')"
echo ""
echo "  Then run ONE command:"
echo "    bash ~/setup.sh"
echo ""
echo "  That handles everything else automatically."
echo "============================================================"
echo ""
echo "Rebooting in 5 seconds (Ctrl+C to cancel)..."
sleep 5
sudo reboot
