#!/bin/bash
set -euo pipefail

# === CONFIGURATION ===
BACKUP_DIR="/backup/proxmoxconf/weekly"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="proxmoxconf_${TIMESTAMP}.tar.gz"
MAX_BACKUPS=3

# Files to back up
FILES=(
  "/etc/network/interfaces"
  "/etc/hosts"
  "/etc/passwd"
  "/etc/resolv.conf"
  "/usr/local/homelab/scripts/bk-proxmoxconf.sh"
  "/usr/local/homelab/scripts/check_temp.sh"
  "/usr/local/homelab/scripts/check_nvme.sh"
  "/usr/local/homelab/scripts/mv-backup-lxc.sh"
  "/root/.bashrc"
  "/etc/pve/nodes/orion/qemu-server/*"
  "/etc/pve/nodes/orion/lxc"
)

# === SCRIPT START ===
echo "=== BACKUP PROXMOX CONFIGURATION ==="

mkdir -p "$BACKUP_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Backing up configuration files..."
for file in "${FILES[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$TMP_DIR/"
        echo "  ✓ $file"
    else
        echo "  ⚠ Skipped missing file: $file"
    fi
done

echo "Creating archive..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$TMP_DIR" .

echo "Keeping only the latest $MAX_BACKUPS backups..."
# List backups sorted by time, skip the newest $MAX_BACKUPS, delete the rest
ls -tp "$BACKUP_DIR"/proxmoxconf_*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS+1)) | xargs -r rm -v

echo "Backup complete: $BACKUP_DIR/$BACKUP_NAME"

