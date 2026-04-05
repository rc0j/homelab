#!/bin/bash

# --- CONFIGURATION ---
WEBHOOK_URL="https://discord.com/api/webhooks/1395826641019863132/auk8N644uJYHJc9iaJIWK5CJOndEWIFLzmFUWp8uLEO19s61qoYKBooWYqXzJsy8zJsP"
SENSOR_LABEL="Package id 0"  # Adjust to your system (e.g. "Tctl" or "Core 0")
WARNING_THRESHOLD=70
CRITICAL_THRESHOLD=85

# --- GET TEMPERATURE ---
TEMP_RAW=$(sensors | grep -m 1 "$SENSOR_LABEL" | grep -oE '\+?[0-9]+(\.[0-9]+)?' | head -n 1)
TEMP=${TEMP_RAW%.*}

# --- DETERMINE STATUS ---
if [ -z "$TEMP" ]; then
    STATUS="❓ Unable to read temperature"
    COLOR=8421504
elif [ "$TEMP" -ge "$CRITICAL_THRESHOLD" ]; then
    STATUS="🔥 CRITICAL"
    COLOR=16711680
elif [ "$TEMP" -ge "$WARNING_THRESHOLD" ]; then
    STATUS="⚠️ WARNING"
    COLOR=16753920
else
    # ✅ OK - No need to notify
    exit 0
fi

# --- BUILD MESSAGE ---
HOSTNAME=$(hostname)
TIME_NOW=$(date "+%Y-%m-%d %H:%M:%S")

DESCRIPTION="$STATUS
Hostname: **$HOSTNAME**
Time: **$TIME_NOW**
Temperature: **${TEMP}°C**
Thresholds: Warning ≥ ${WARNING_THRESHOLD}°C, Critical ≥ ${CRITICAL_THRESHOLD}°C"

# --- ESCAPE DESCRIPTION FOR JSON ---
DESCRIPTION_ESCAPED=$(printf '%s' "$DESCRIPTION" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

# --- SEND TO DISCORD ---
curl -H "Content-Type: application/json" \
     -X POST \
     -d "{
           \"embeds\": [{
             \"title\": \"System Temperature Status\",
             \"description\": $DESCRIPTION_ESCAPED,
             \"color\": $COLOR
           }]
         }" \
     "$WEBHOOK_URL"

