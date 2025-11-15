#!/bin/bash
# BEACON Display - Watchdog Script
# Monitors system health and restarts display if issues detected
# Runs every hour via cron job

# Get directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source device detection library
source "$SCRIPT_DIR/device-detect.sh"

echo "========================================"
echo "BEACON Watchdog Check"
echo "Time: $(date)"
echo "Device: $(detect_hardware)"
echo "========================================"

# Auto-detect memory threshold based on total system memory
MEMORY_THRESHOLD_MB=$(get_memory_threshold)

# Check if display service is running
SERVICE_STATUS=$(systemctl is-active beacon-display.service)
echo "Service status: $SERVICE_STATUS"

if [ "$SERVICE_STATUS" != "active" ]; then
    echo "⚠️  Display service not active, restarting..."
    sudo systemctl restart beacon-display.service
    echo "✓ Service restarted"
    exit 0
fi

# Check memory usage
MEMORY_USED=$(free -m | awk '/^Mem:/ {print $3}')
MEMORY_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEMORY_PERCENT=$((MEMORY_USED * 100 / MEMORY_TOTAL))

echo "Memory: ${MEMORY_USED}MB / ${MEMORY_TOTAL}MB (${MEMORY_PERCENT}%)"

if [ "$MEMORY_USED" -gt "$MEMORY_THRESHOLD_MB" ]; then
    echo "⚠️  Memory usage above threshold (${MEMORY_THRESHOLD_MB}MB), restarting display..."
    sudo systemctl restart beacon-display.service
    echo "✓ Display restarted to free memory"
    exit 0
fi

# Check CPU temperature (device-agnostic)
CPU_TEMP=$(get_temperature)

if [ "$CPU_TEMP" != "N/A" ]; then
    CPU_TEMP_INT=${CPU_TEMP%.*}
    echo "CPU temperature: ${CPU_TEMP}°C"

    if [ "$CPU_TEMP_INT" -gt 70 ]; then
        echo "⚠️  CPU temperature high (${CPU_TEMP}°C), throttling may occur"
        # Note: Don't restart for temp, just log it
    fi
else
    echo "CPU temperature: N/A (temperature monitoring not available)"
fi

# Check if Chromium is running
CHROMIUM_PID=$(pgrep -f "chromium.*kiosk")

if [ -z "$CHROMIUM_PID" ]; then
    echo "⚠️  Chromium not running, restarting display service..."
    sudo systemctl restart beacon-display.service
    echo "✓ Display service restarted"
    exit 0
fi

echo "Chromium PID: $CHROMIUM_PID"

# Check network connectivity (can we reach token service?)
# Extract token service URL from config.json
CONFIG_FILE="$(dirname "$0")/../display-client/config.json"

if [ -f "$CONFIG_FILE" ]; then
    # Try to extract tokenServiceUrl (basic parsing, works for simple JSON)
    TOKEN_SERVICE_URL=$(grep -o '"tokenServiceUrl"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

    if [ -n "$TOKEN_SERVICE_URL" ]; then
        # Extract hostname/IP from URL
        TOKEN_SERVICE_HOST=$(echo "$TOKEN_SERVICE_URL" | sed -E 's|https?://([^:/]+).*|\1|')

        echo "Checking connectivity to token service: $TOKEN_SERVICE_HOST"

        if ping -c 1 -W 3 "$TOKEN_SERVICE_HOST" > /dev/null 2>&1; then
            echo "✓ Token service reachable"
        else
            echo "⚠️  Token service unreachable: $TOKEN_SERVICE_HOST"
            echo "Display may show errors. Check network and token service."
        fi
    fi
fi

# Check disk space
DISK_USAGE=$(df -h / | awk '/\// {print $5}' | sed 's/%//')
echo "Disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 90 ]; then
    echo "⚠️  Disk space low (${DISK_USAGE}% used)"
    # Clean up some caches
    rm -rf ~/.cache/chromium/Cache/* 2>/dev/null
    echo "✓ Cleared Chromium cache"
fi

echo "✓ All checks passed"
echo "========================================"
