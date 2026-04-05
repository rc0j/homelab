#!/bin/bash
set -eu
####################################################################
### PROXMOX UNIFIED BACKUP AND MOVE
### This script performs weekly backup of VMs and LXC containers on a Proxmox server,
### moves them to /backup and maintains a 1-day retention policy.
### Ansible managed ### DO NOT MODIFY
####################################################################

# Configuration
VM_IDS=("19205" "19207" "192100")
CONTAINER_IDS=("1108" "1199")  # docker-node01 only for now
BACKUP_DIR="/var/lib/vz/dump"
DEST_DIR="/backup/weekly-backup"
RETENTION_DAYS=1
NTFY_CHANNEL="ntfy.sh/backup_channel_HXkpCIzrDrcLFTAn"

echo "===== PROXMOX BACKUP SCRIPT STARTED at $(date '+%Y-%m-%d %H:%M:%S') ====="
echo "Emptying backup directory..."
rm -rf "$BACKUP_DIR"/*

echo "Deleting old backups in $DEST_DIR..."
find "$DEST_DIR" -type f -name "*.vma.zst" -mtime +$RETENTION_DAYS -delete
find "$DEST_DIR" -type f -name "*.tar.zst" -mtime +$RETENTION_DAYS -delete

# Backup VMs
if [ ${#VM_IDS[@]} -gt 0 ]; then
    echo ""
    echo "===== BACKING UP VMs ====="
    for VM in "${VM_IDS[@]}"; do
        echo "Starting backup of VM $VM at $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Stopping VM $VM..."
        qm shutdown $VM
        sleep 25
        vzdump "$VM" --compress zstd --dumpdir "$BACKUP_DIR"
    done
    
    echo "Moving VM backup files from $BACKUP_DIR to $DEST_DIR..."
    if ls "$BACKUP_DIR"/*.vma.zst 1> /dev/null 2>&1; then
        mv "$BACKUP_DIR"/*.vma.zst "$DEST_DIR"/
    fi
    
    echo "Starting VMs..."
    for VM in "${VM_IDS[@]}"; do
        echo "Starting VM $VM"
        qm start $VM
    done
fi

# Backup LXC Containers
if [ ${#CONTAINER_IDS[@]} -gt 0 ]; then
    echo ""
    echo "===== BACKING UP LXC CONTAINERS ====="
    for CONTAINER in "${CONTAINER_IDS[@]}"; do
        echo "Starting backup of container $CONTAINER at $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Stopping container $CONTAINER..."
        pct shutdown $CONTAINER
        sleep 15
        vzdump "$CONTAINER" --compress zstd --dumpdir "$BACKUP_DIR"
    done
    
    echo "Moving container backup files from $BACKUP_DIR to $DEST_DIR..."
    if ls "$BACKUP_DIR"/*.tar.zst 1> /dev/null 2>&1; then
        mv "$BACKUP_DIR"/*.tar.zst "$DEST_DIR"/
    fi
    
    echo "Starting containers..."
    for CONTAINER in "${CONTAINER_IDS[@]}"; do
        echo "Starting container $CONTAINER"
        pct start $CONTAINER
    done
fi

# Send notification
echo ""
echo "===== BACKUP COMPLETED ====="
NOTIFICATION_MSG="[PROXMOX BACKUP] Backup completed successfully"
if [ ${#VM_IDS[@]} -gt 0 ]; then
    NOTIFICATION_MSG="$NOTIFICATION_MSG - VMs: ${VM_IDS[*]}"
fi
if [ ${#CONTAINER_IDS[@]} -gt 0 ]; then
    NOTIFICATION_MSG="$NOTIFICATION_MSG - Containers: ${CONTAINER_IDS[*]}"
fi

curl -d "$NOTIFICATION_MSG" "$NTFY_CHANNEL"
echo "Backup script completed at $(date '+%Y-%m-%d %H:%M:%S')"
