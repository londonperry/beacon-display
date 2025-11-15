#!/bin/bash
# BEACON Display - Deploy to Raspberry Pi Script
# Copies BEACON files to Raspberry Pi via SSH
# Usage: ./deploy-to-pi.sh <pi-ip-address> [username]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required commands
REQUIRED_COMMANDS="ping ssh rsync"
MISSING_COMMANDS=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v $cmd > /dev/null 2>&1; then
        MISSING_COMMANDS="$MISSING_COMMANDS $cmd"
    fi
done

if [ -n "$MISSING_COMMANDS" ]; then
    echo -e "${RED}Error: Missing required commands:$MISSING_COMMANDS${NC}"
    echo "Please install the missing commands and try again:"
    echo "  macOS: brew install rsync"
    echo "  Ubuntu/Debian: sudo apt-get install rsync openssh-client"
    exit 1
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing Raspberry Pi IP address${NC}"
    echo "Usage: $0 <pi-ip-address> [username]"
    echo "Example: $0 192.168.1.150 pi"
    exit 1
fi

PI_IP="$1"
PI_USER="${2:-pi}"  # Default to 'pi' if not specified

echo "========================================"
echo "BEACON Display - Deploy to Raspberry Pi"
echo "========================================"
echo "Target: $PI_USER@$PI_IP"
echo ""

# Get the project root directory (parent of scripts/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Project directory: $PROJECT_DIR"

# Verify we're in the right place
if [ ! -f "$PROJECT_DIR/README.md" ]; then
    echo -e "${RED}Error: Not in BEACON project directory${NC}"
    exit 1
fi

# Check if Pi is reachable
echo -e "${YELLOW}Checking connectivity to Pi...${NC}"
if ! ping -c 1 -W 3 "$PI_IP" > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot reach Raspberry Pi at $PI_IP${NC}"
    echo "Please verify:"
    echo "  - Pi is powered on"
    echo "  - Pi is connected to network"
    echo "  - IP address is correct"
    exit 1
fi
echo -e "${GREEN}✓ Pi is reachable${NC}"

# Check SSH connectivity
echo -e "${YELLOW}Checking SSH access...${NC}"
if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$PI_USER@$PI_IP" "echo SSH OK" > /dev/null 2>&1; then
    echo -e "${RED}Error: Cannot SSH to $PI_USER@$PI_IP${NC}"
    echo "Please verify:"
    echo "  - SSH is enabled on Pi"
    echo "  - Username is correct (default: pi)"
    echo "  - You can SSH manually: ssh $PI_USER@$PI_IP"
    exit 1
fi
echo -e "${GREEN}✓ SSH access confirmed${NC}"
echo ""

# Create remote directory
echo -e "${YELLOW}Creating remote directory...${NC}"
ssh "$PI_USER@$PI_IP" "mkdir -p ~/beacon-display"
echo -e "${GREEN}✓ Directory created${NC}"

# Copy display-client files
echo -e "${YELLOW}Copying display client...${NC}"
rsync -avz --progress \
    --exclude 'node_modules' \
    --exclude '.DS_Store' \
    "$PROJECT_DIR/display-client/" \
    "$PI_USER@$PI_IP:~/beacon-display/display-client/"
echo -e "${GREEN}✓ Display client copied${NC}"

# Copy raspberry-pi scripts
echo -e "${YELLOW}Copying Raspberry Pi scripts...${NC}"
rsync -avz --progress \
    --exclude '.DS_Store' \
    "$PROJECT_DIR/raspberry-pi/" \
    "$PI_USER@$PI_IP:~/beacon-display/raspberry-pi/"
echo -e "${GREEN}✓ Scripts copied${NC}"

# Make scripts executable
echo -e "${YELLOW}Setting permissions...${NC}"
ssh "$PI_USER@$PI_IP" "chmod +x ~/beacon-display/raspberry-pi/*.sh"
echo -e "${GREEN}✓ Scripts made executable${NC}"

echo ""
echo "========================================"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. SSH to Pi: ssh $PI_USER@$PI_IP"
echo "2. Edit config: nano ~/beacon-display/display-client/config.json"
echo "3. Run install script: cd ~/beacon-display && sudo raspberry-pi/install.sh"
echo "4. Reboot Pi: sudo reboot"
echo ""
