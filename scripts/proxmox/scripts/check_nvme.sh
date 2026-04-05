#!/bin/bash
# NVMe Health Check Script for Centreon/Nagios
# Usage: ./check_nvme_health.sh <device>
# Example: ./check_nvme_health.sh /dev/nvme0

DEVICE=$1

if [ -z "$DEVICE" ]; then
    echo "UNKNOWN - No device specified"
    exit 3
fi

if [ ! -e "$DEVICE" ]; then
    echo "UNKNOWN - Device $DEVICE not found"
    exit 3
fi

# Get SMART log data
SMART_OUTPUT=$(sudo /usr/sbin/nvme smart-log "$DEVICE" 2>&1)

if [ $? -ne 0 ]; then
    echo "UNKNOWN - Failed to read SMART data from $DEVICE"
    exit 3
fi

# Extract values
SPARE=$(echo "$SMART_OUTPUT" | grep "available_spare" | head -1 | awk '{print $3}' | tr -d '%')
SPARE_THRESHOLD=$(echo "$SMART_OUTPUT" | grep "available_spare_threshold" | awk '{print $3}' | tr -d '%')
PERCENTAGE_USED=$(echo "$SMART_OUTPUT" | grep "percentage_used" | awk '{print $3}' | tr -d '%')

# Validate we got values
if [ -z "$SPARE" ] || [ -z "$SPARE_THRESHOLD" ] || [ -z "$PERCENTAGE_USED" ]; then
    echo "UNKNOWN - Failed to parse SMART data"
    exit 3
fi

# Thresholds
USED_WARNING=80
USED_CRITICAL=90

# Performance data
PERFDATA="spare=${SPARE}%;${SPARE_THRESHOLD};${SPARE_THRESHOLD};;100 used=${PERCENTAGE_USED}%;${USED_WARNING};${USED_CRITICAL};0;100"

# Check status
STATUS="OK"
EXIT_CODE=0
MESSAGE=""

# Check available spare
if [ "$SPARE" -le "$SPARE_THRESHOLD" ]; then
    STATUS="CRITICAL"
    EXIT_CODE=2
    MESSAGE="${MESSAGE}Available spare (${SPARE}%) at or below threshold (${SPARE_THRESHOLD}%). "
fi

# Check percentage used
if [ "$PERCENTAGE_USED" -ge "$USED_CRITICAL" ]; then
    if [ "$STATUS" != "CRITICAL" ]; then
        STATUS="CRITICAL"
        EXIT_CODE=2
    fi
    MESSAGE="${MESSAGE}Drive usage at ${PERCENTAGE_USED}% (critical). "
elif [ "$PERCENTAGE_USED" -ge "$USED_WARNING" ]; then
    if [ "$STATUS" = "OK" ]; then
        STATUS="WARNING"
        EXIT_CODE=1
    fi
    MESSAGE="${MESSAGE}Drive usage at ${PERCENTAGE_USED}% (warning). "
fi

# Build output
if [ "$STATUS" = "OK" ]; then
    MESSAGE="NVMe health OK - Spare: ${SPARE}%, Used: ${PERCENTAGE_USED}%"
else
    MESSAGE="${STATUS} - ${MESSAGE}"
fi

echo "${MESSAGE} | ${PERFDATA}"
exit $EXIT_CODE
