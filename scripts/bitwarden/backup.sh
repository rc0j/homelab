#  ____  _ _                         _
# | __ )(_) |___      ____ _ _ __ __| | ___ _ __
# |  _ \| | __\ \ /\ / / _` | '__/ _` |/ _ \ '_ \
# | |_) | | |_ \ V  V / (_| | | | (_| |  __/ | | |
# |____/|_|\__| \_/\_/ \__,_|_|  \__,_|\___|_| |_|
#  ____             _
# | __ )  __ _  ___| | ___   _ _ __
# |  _ \ / _` |/ __| |/ / | | | '_ \
# | |_) | (_| | (__|   <| |_| | |_) |
# |____/ \__,_|\___|_|\_\\__,_| .__/
#                             |_|
# This script requires zstd to work properly.
#!/bin/bash
set -e
source /home/vaultwarden/vaultwarden-docker/backup.env
backup_dir="/home/vaultwarden/vw-backups"
datestamp=$(date +%Y%m%d_%H%M)
VERSION="1.0"

echo "Exporting vault..." 
/usr/local/bin/bw config server "$BW_SERVER"
export BW_SESSION=$(/usr/local/bin/bw login "$BW_USERNAME" "$BW_PASSWORD" --raw)
/usr/local/bin/bw export --format encrypted_json --password "$BW_EXPORT_PASS" --output "${backup_dir}/${datestamp}.json"
/usr/local/bin/bw logout

zstd -19 --rm "${backup_dir}/${datestamp}.json" -o "${backup_dir}/${datestamp}.json.zst"

echo "Transfering to syncthing node..."
rsync -rsvPp "${backup_dir}/${datestamp}.json.zst" root@192.168.100.21:/home/syncthing/bitwarden_backup