#!/bin/bash
# BEACON Display - Raspberry Pi Installation Script
# Run this once on your Raspberry Pi to set up the display system
# Usage: sudo ./install.sh

set -e  # Exit on any error

echo "========================================"
echo "BEACON Display - Raspberry Pi Setup"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: This script must be run as root (use sudo)"
    exit 1
fi

# Check for required commands (vcgencmd is optional, Pi-specific)
REQUIRED_COMMANDS="apt-get systemctl crontab"
MISSING_COMMANDS=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v $cmd > /dev/null 2>&1; then
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

if [ -n "$MISSING_COMMANDS" ]; then
    echo "❌ Error: Missing required commands:$MISSING_COMMANDS"
    echo "This script is designed for Debian/Ubuntu-based systems"
    exit 1
fi

# Source device detection (if available)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/device-detect.sh" ]; then
    source "$SCRIPT_DIR/device-detect.sh"
    echo "Detected hardware: $(detect_hardware)"
    echo "Total memory: $(get_memory_total)MB"
    echo ""
fi

# Get the actual user (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
HOME_DIR=$(eval echo ~$ACTUAL_USER)

echo "Installing for user: $ACTUAL_USER"
echo "Home directory: $HOME_DIR"
echo ""

# Update system packages
echo "📦 Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

# Install required packages
echo "📦 Installing required packages..."
apt-get install -y -qq \
    chromium-browser \
    x11-xserver-utils \
    xserver-xorg \
    xinit \
    unclutter \
    lightdm

echo "✓ Packages installed"
echo ""

# Configure auto-login (no password required on boot)
echo "🔧 Configuring auto-login..."
mkdir -p /etc/lightdm/lightdm.conf.d/
cat > /etc/lightdm/lightdm.conf.d/01-autologin.conf << EOF
[Seat:*]
autologin-user=$ACTUAL_USER
autologin-user-timeout=0
EOF

echo "✓ Auto-login configured"
echo ""

# Copy BEACON files to home directory
echo "📁 Setting up BEACON files..."
BEACON_DIR="$HOME_DIR/beacon-display"

# The files should already be here if deploy-to-pi.sh was used
if [ -d "$BEACON_DIR" ]; then
    echo "✓ BEACON directory found at $BEACON_DIR"
else
    echo "⚠️  BEACON directory not found. Creating it..."
    mkdir -p "$BEACON_DIR"
    echo "Please copy display-client files to $BEACON_DIR/"
fi

# Make scripts executable
if [ -f "$BEACON_DIR/raspberry-pi/start-display.sh" ]; then
    chmod +x "$BEACON_DIR/raspberry-pi/start-display.sh"
    echo "✓ start-display.sh made executable"
fi

if [ -f "$BEACON_DIR/raspberry-pi/watchdog.sh" ]; then
    chmod +x "$BEACON_DIR/raspberry-pi/watchdog.sh"
    echo "✓ watchdog.sh made executable"
fi

# Set ownership to actual user
chown -R $ACTUAL_USER:$ACTUAL_USER "$BEACON_DIR"
echo "✓ File ownership set"
echo ""

# Install systemd service
echo "🔧 Installing systemd service..."
SERVICE_FILE="/etc/systemd/system/beacon-display.service"
SERVICE_TEMPLATE="$BEACON_DIR/raspberry-pi/systemd/beacon-display.service"

# Check if service template exists
if [ -f "$SERVICE_TEMPLATE" ]; then
    # Use template and substitute placeholders
    sed -e "s|%BEACON_USER%|$ACTUAL_USER|g" \
        -e "s|%BEACON_HOME%|$HOME_DIR|g" \
        "$SERVICE_TEMPLATE" > "$SERVICE_FILE"
else
    # Fallback: create service file directly
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=BEACON Power BI Display
After=network-online.target graphical.target
Wants=network-online.target

[Service]
Type=simple
User=$ACTUAL_USER
Group=$ACTUAL_USER
Environment=DISPLAY=:0
Environment=XAUTHORITY=$HOME_DIR/.Xauthority
ExecStartPre=/bin/sleep 10
ExecStart=$BEACON_DIR/raspberry-pi/start-display.sh
Restart=always
RestartSec=10
MemoryMax=$(get_recommended_memory_limit 2>/dev/null || echo "400M")
CPUQuota=90%
StandardOutput=journal
StandardError=journal
SyslogIdentifier=beacon-display

[Install]
WantedBy=graphical.target
EOF
fi

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable beacon-display.service

echo "✓ Systemd service installed and enabled"
echo ""

# Configure sudoers for watchdog (allow restart without password)
echo "🔧 Configuring sudoers for watchdog..."
SUDOERS_FILE="/etc/sudoers.d/beacon-watchdog"

cat > "$SUDOERS_FILE" << EOF
# Allow beacon watchdog to restart display service without password
$ACTUAL_USER ALL=(ALL) NOPASSWD: /bin/systemctl restart beacon-display.service
$ACTUAL_USER ALL=(ALL) NOPASSWD: /bin/systemctl status beacon-display.service
$ACTUAL_USER ALL=(ALL) NOPASSWD: /bin/systemctl is-active beacon-display.service
EOF

# Set proper permissions (sudoers files must be 0440)
chmod 0440 "$SUDOERS_FILE"

echo "✓ Sudoers configured for watchdog"
echo ""

# Install watchdog cron job (checks every hour)
echo "🔧 Installing watchdog cron job..."
CRON_JOB="0 * * * * $BEACON_DIR/raspberry-pi/watchdog.sh >> /var/log/beacon-watchdog.log 2>&1"

# Add cron job if not already present
(crontab -u $ACTUAL_USER -l 2>/dev/null | grep -v "beacon-watchdog"; echo "$CRON_JOB") | crontab -u $ACTUAL_USER -

echo "✓ Watchdog cron job installed"
echo ""

# Configure display settings
echo "🔧 Configuring display settings..."

# Disable screen blanking and power management
mkdir -p "$HOME_DIR/.config/lxsession/LXDE-pi"
cat > "$HOME_DIR/.config/lxsession/LXDE-pi/autostart" << EOF
@xset s off
@xset -dpms
@xset s noblank
EOF

chown -R $ACTUAL_USER:$ACTUAL_USER "$HOME_DIR/.config"

echo "✓ Display settings configured"
echo ""

# Configure memory split (Raspberry Pi specific)
echo "🔧 Optimizing memory allocation..."
if [ -f /boot/config.txt ] || [ -f /boot/firmware/config.txt ]; then
    CONFIG_FILE="/boot/config.txt"
    [ ! -f "$CONFIG_FILE" ] && CONFIG_FILE="/boot/firmware/config.txt"

    if ! grep -q "^gpu_mem=" "$CONFIG_FILE"; then
        echo "gpu_mem=128" >> "$CONFIG_FILE"
        echo "✓ GPU memory set to 128MB"
    else
        echo "✓ GPU memory already configured"
    fi
else
    echo "ℹ️  Skipping GPU memory config (not a Raspberry Pi or config file not found)"
fi

echo ""
echo "========================================"
echo "✅ Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Edit $BEACON_DIR/display-client/config.json with your settings"
echo "2. Ensure token service is running on your laptop"
echo "3. Reboot the Pi: sudo reboot"
echo ""
echo "After reboot, the display should start automatically"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status beacon-display  # Check status"
echo "  sudo systemctl restart beacon-display # Restart display"
echo "  sudo journalctl -u beacon-display -f  # View live logs"
echo ""
