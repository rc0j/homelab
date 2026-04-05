#!/bin/bash

# Technitium DNS Server Backup Script

# Configuration
HOSTNAME="technitium-dns"
IP="192.168.100.5"
TOKEN="c455519cbcfadf3def63a980a05a1734c753f6b05b365c081f0976a2e2f42f19"
SUFFIX="weekly"
BACKUP_DIR="/backup/technitiumconf"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Construct API URL
URL="http://$IP:5380/api/settings/backup?token=$TOKEN&blockLists=true&logs=true&scopes=true&apps=true&stats=true&zones=true&allowedZones=true&blockedZones=true&dnsSettings=true&logSettings=true&authConfig=true"

# Construct output file name
FILE_NAME="$HOSTNAME-$IP-$(date +%Y%m%d)-$SUFFIX.zip"

echo "Backing up $HOSTNAME ($IP)..."

# Call API and save to backup directory
curl $URL -o "$BACKUP_DIR/$FILE_NAME"

echo "Backup complete: $FILE_NAME"
