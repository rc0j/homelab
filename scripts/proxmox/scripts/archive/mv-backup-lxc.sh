#!/bin/bash
set -eu
####################################################################
### PROXMOX LXC BACKUP AND MOVE
### This script is used to perform weekly backup of LXC containers on a Proxmox server,
### move them to /backup and maintain a 1-day retention policy.
### Ansible managed ### DO NOT MODIFY
####################################################################

CONTAINER_IDS=("1111")  # docker-node01
BACKUP_DIR="/var/lib/vz/dump"
DEST_DIR="/backup/weekly-backup"
RETENTION_DAYS=1

echo "Emptying backup directory..."
rm -rf "$BACKUP_DIR"/*

echo "Deleting old backups in $DEST_DIR..."
find "$DEST_DIR" -type f -name "*.tar.zst" -mtime +$RETENTION_DAYS -delete

for CONTAINER in "${CONTAINER_IDS[@]}"; do
    echo "Starting backup of container $CONTAINER at $(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "Stopping container $CONTAINER..."
    pct shutdown $CONTAINER
    sleep 15
    
    vzdump "$CONTAINER" --compress zstd --dumpdir "$BACKUP_DIR"
done

echo "Moving backup files from $BACKUP_DIR to $DEST_DIR..."
mv "$BACKUP_DIR"/*.tar.zst "$DEST_DIR"/

echo "Starting containers: ${CONTAINER_IDS[*]}"
for CONTAINER in "${CONTAINER_IDS[@]}"; do
    echo "Starting $CONTAINER"
    pct start $CONTAINER
done

curl -d "[LXC BACKUP] Backup and move completed successfully for container(s): ${CONTAINER_IDS[*]}" ntfy.sh/backup_channel_HXkpCIzrDrcLFTAn

echo "Backup script completed at $(date '+%Y-%m-%d %H:%M:%S')"
