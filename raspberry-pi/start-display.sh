#!/bin/bash
# BEACON Display - Chromium Launcher Script
# Starts Chromium in kiosk mode to display the BEACON Power BI report
# This script is called by the systemd service on boot

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BEACON_DIR="$(dirname "$SCRIPT_DIR")"
DISPLAY_CLIENT="$BEACON_DIR/display-client"

# Source device detection library
source "$SCRIPT_DIR/device-detect.sh"

echo "========================================"
echo "BEACON Display Starting"
echo "Time: $(date)"
echo "Device: $(detect_hardware)"
echo "Memory: $(get_memory_total)MB total"
echo "========================================"

# Verify display client exists
if [ ! -f "$DISPLAY_CLIENT/index.html" ]; then
    echo "❌ Error: Display client not found at $DISPLAY_CLIENT/index.html"
    exit 1
fi

# Verify config.json exists
if [ ! -f "$DISPLAY_CLIENT/config.json" ]; then
    echo "❌ Error: config.json not found at $DISPLAY_CLIENT/config.json"
    echo "Please copy config.json.example to config.json and configure it"
    exit 1
fi

echo "✓ Display client found"
echo "✓ Configuration found"

# Wait for X server to be ready
echo "Waiting for X server..."
for i in {1..30}; do
    if xset q &>/dev/null; then
        echo "✓ X server ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Error: X server not available after 30 seconds"
        exit 1
    fi
    sleep 1
done

# Disable screen blanking and power management
echo "Disabling screen blanking..."
xset s off
xset -dpms
xset s noblank

# Hide mouse cursor
echo "Starting cursor hider..."
unclutter -idle 0.1 -root &

# Clear any existing Chromium session
echo "Cleaning Chromium cache..."
rm -rf ~/.cache/chromium
rm -rf ~/.config/chromium/Singleton*

# Build Chromium command with kiosk mode flags (device-agnostic)
CHROMIUM_CMD=$(get_chromium_command)
echo "Using browser: $CHROMIUM_CMD"

CHROMIUM_FLAGS=(
    --kiosk
    --noerrdialogs
    --disable-infobars
    --no-first-run
    --disable-suggestions-service
    --disable-translate
    --disable-save-password-bubble
    --disable-session-crashed-bubble
    --disable-component-update
    --start-fullscreen
    --start-maximized
    --disable-features=TranslateUI
    --disable-features=Translate
    --check-for-update-interval=31536000
    --overscroll-history-navigation=0
    --password-store=basic
    --disable-pinch
    --no-default-browser-check
    --disable-sync
    --disk-cache-size=1
)

# Launch Chromium in kiosk mode
echo "Launching Chromium..."
echo "URL: file://$DISPLAY_CLIENT/index.html"

$CHROMIUM_CMD "${CHROMIUM_FLAGS[@]}" "file://$DISPLAY_CLIENT/index.html" 2>&1 | while IFS= read -r line; do
    echo "[Chromium] $line"
done

# If Chromium exits, log it
echo "========================================"
echo "BEACON Display Stopped"
echo "Time: $(date)"
echo "Exit code: $?"
echo "========================================"
