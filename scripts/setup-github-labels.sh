#!/bin/bash

# GitHub Labels Setup for BEACON Display
# This script creates recommended labels in your GitHub repository
# Usage: ./scripts/setup-github-labels.sh <owner> <repo>
# Example: ./scripts/setup-github-labels.sh londonperry beacon-display

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
  echo -e "${RED}Error: Missing arguments${NC}"
  echo "Usage: $0 <owner> <repo>"
  echo "Example: $0 londonperry beacon-display"
  exit 1
fi

OWNER=$1
REPO=$2

echo -e "${BLUE}Setting up GitHub labels for ${OWNER}/${REPO}...${NC}"

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
  echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
  echo "Install from: https://cli.github.com"
  exit 1
fi

# Check authentication
if ! gh auth status > /dev/null 2>&1; then
  echo -e "${RED}Error: Not authenticated with GitHub${NC}"
  echo "Run: gh auth login"
  exit 1
fi

# Define labels with name, description, and color
declare -a LABELS=(
  # Type labels
  "bug|Something isn't working|d73a4a"
  "enhancement|New feature or request|a2eeef"
  "documentation|Improvements or additions to documentation|0075ca"
  "question|Further information is requested|d876e3"
  "chore|Maintenance tasks, dependency updates|cccccc"
  "refactoring|Code refactoring without changing functionality|6f42c1"

  # Component labels
  "component: token-service|Related to token service (authentication)|1f6feb"
  "component: display-client|Related to display client (browser/dashboard)|f0883e"
  "component: raspberry-pi|Related to Raspberry Pi deployment|2cbe4e"
  "component: azure-ad|Related to Azure AD integration|0969da"
  "component: power-bi|Related to Power BI integration|7057ff"

  # Deployment phase labels
  "phase: poc|Proof of Concept (laptop-version)|fff8c5"
  "phase: pilot|Pilot deployment (10-50 devices)|ffe8a0"
  "phase: production|Production deployment (enterprise scale)|ffb300"

  # Priority labels
  "priority: critical|Blocking deployment or security issue|b91c1c"
  "priority: high|Important, should be addressed soon|ea580c"
  "priority: medium|Normal priority|e5e7eb"
  "priority: low|Nice to have, can wait|9ca3af"

  # Status labels
  "status: blocked|Waiting for external dependency|ff0000"
  "status: in-progress|Currently being worked on|0969da"
  "status: review-needed|Waiting for code review|ffd700"
  "status: help-needed|Need community help|ff6b6b"

  # Difficulty labels (for onboarding)
  "good-first-issue|Good for newcomers|7057ff"
  "help-wanted|Extra attention is needed|008672"
  "beginner-friendly|Recommended for beginners|91ddcf"
  "documentation-only|Documentation improvements|0075ca"

  # Hardware/Environment labels
  "hardware: pi-zero-2w|Tested on Raspberry Pi Zero 2 W|c2e0c6"
  "hardware: pi-4|Tested on Raspberry Pi 4|90ee90"
  "hardware: laptop|Tested on laptop/desktop|87ceeb"
  "environment: wifi-limited|May be affected by 2.4GHz WiFi limitation|ffa500"
  "environment: memory-constrained|Memory optimization needed for 512MB RAM|ff8c00"

  # Security labels
  "security|Security-related issue|d4af37"
  "security-review-needed|Needs security review before merge|ff0000"

  # Testing labels
  "test-coverage|Needs test coverage|cccccc"
  "tested: manual|Tested manually|90ee90"
  "tested: automated|Has automated tests|00ff00"

  # Community labels
  "bug-confirmed|Bug verified and confirmed|d73a4a"
  "upstream|Issue or PR from upstream dependency|cccccc"
  "wontfix|This will not be worked on|ffffff"
)

# Create labels
CREATED=0
UPDATED=0
FAILED=0

for label_def in "${LABELS[@]}"; do
  IFS='|' read -r LABEL_NAME DESCRIPTION COLOR <<< "$label_def"

  # Validate color (6 hex characters)
  if ! [[ $COLOR =~ ^[0-9a-f]{6}$ ]]; then
    echo -e "${RED}✗${NC} Invalid color format for label '${LABEL_NAME}': ${COLOR}"
    ((FAILED++))
    continue
  fi

  # Try to create label, update if exists
  if gh label create "$LABEL_NAME" \
    --repo="${OWNER}/${REPO}" \
    --description="$DESCRIPTION" \
    --color="$COLOR" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Created label: ${LABEL_NAME}"
    ((CREATED++))
  elif gh label edit "$LABEL_NAME" \
    --repo="${OWNER}/${REPO}" \
    --description="$DESCRIPTION" \
    --color="$COLOR" 2>/dev/null; then
    echo -e "${YELLOW}↻${NC} Updated label: ${LABEL_NAME}"
    ((UPDATED++))
  else
    echo -e "${RED}✗${NC} Failed to create/update label: ${LABEL_NAME}"
    ((FAILED++))
  fi
done

echo ""
echo -e "${BLUE}Summary:${NC}"
echo -e "  ${GREEN}Created:${NC} ${CREATED}"
echo -e "  ${YELLOW}Updated:${NC} ${UPDATED}"
if [ $FAILED -gt 0 ]; then
  echo -e "  ${RED}Failed:${NC} ${FAILED}"
fi

echo ""
echo -e "${GREEN}Label setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Visit: https://github.com/${OWNER}/${REPO}/labels"
echo "2. Review and organize labels as needed"
echo "3. Use labels when creating/triaging issues"
echo "4. See GITHUB_SETUP_CHECKLIST.md for other settings"
