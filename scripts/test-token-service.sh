#!/bin/bash
# BEACON Display - Token Service Test Script
# Tests the token service to verify it's working correctly
# Usage: ./test-token-service.sh [service-url]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required commands
if ! command -v curl > /dev/null 2>&1; then
    echo -e "${RED}Error: curl is required but not installed${NC}"
    echo "Please install curl:"
    echo "  macOS: brew install curl"
    echo "  Ubuntu/Debian: sudo apt-get install curl"
    exit 1
fi

if ! command -v grep > /dev/null 2>&1; then
    echo -e "${RED}Error: grep is required but not installed${NC}"
    exit 1
fi

# Default to localhost if not specified
SERVICE_URL="${1:-http://localhost:3000}"

echo "========================================"
echo "BEACON Token Service Test"
echo "========================================"
echo "Service URL: $SERVICE_URL"
echo ""

# Test 1: Health check
echo -e "${YELLOW}Test 1: Health Check${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$SERVICE_URL/health")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n 1)
BODY=$(echo "$HEALTH_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "Response: $BODY"
else
    echo -e "${RED}✗ Health check failed (HTTP $HTTP_CODE)${NC}"
    echo "Response: $BODY"
    echo ""
    echo "Please ensure token service is running:"
    echo "  cd token-service/laptop-version"
    echo "  npm start"
    exit 1
fi
echo ""

# Test 2: Embed token generation (requires config)
echo -e "${YELLOW}Test 2: Embed Token Generation${NC}"

# Try to read groupId and reportId from display-client config
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_DIR/display-client/config.json"

if [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration from: $CONFIG_FILE"

    # Extract groupId and reportId (basic parsing)
    GROUP_ID=$(grep -o '"groupId"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    REPORT_ID=$(grep -o '"reportId"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)

    if [ -n "$GROUP_ID" ] && [ -n "$REPORT_ID" ] && [ "$GROUP_ID" != "YOUR-WORKSPACE-ID" ]; then
        echo "  Group ID: $GROUP_ID"
        echo "  Report ID: $REPORT_ID"
        echo ""

        TOKEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$SERVICE_URL/api/embed-token" \
            -H "Content-Type: application/json" \
            -d "{\"groupId\":\"$GROUP_ID\",\"reportId\":\"$REPORT_ID\"}")

        HTTP_CODE=$(echo "$TOKEN_RESPONSE" | tail -n 1)
        BODY=$(echo "$TOKEN_RESPONSE" | sed '$d')

        if [ "$HTTP_CODE" = "200" ]; then
            # Check if response contains success:true and embedToken
            if echo "$BODY" | grep -q '"success"[[:space:]]*:[[:space:]]*true' && \
               echo "$BODY" | grep -q '"embedToken"'; then
                echo -e "${GREEN}✓ Embed token generated successfully${NC}"

                # Extract and display expiration
                EXPIRATION=$(echo "$BODY" | grep -o '"expiration"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
                if [ -n "$EXPIRATION" ]; then
                    echo "Token expires: $EXPIRATION"
                fi
            else
                echo -e "${RED}✗ Token generation failed${NC}"
                echo "Response: $BODY"
                exit 1
            fi
        else
            echo -e "${RED}✗ Token generation failed (HTTP $HTTP_CODE)${NC}"
            echo "Response: $BODY"
            echo ""
            echo "Common issues:"
            echo "  - Azure credentials incorrect (.env file)"
            echo "  - Service principal not added to workspace"
            echo "  - Client secret expired"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ Skipping token generation test${NC}"
        echo "config.json not configured with real Power BI IDs"
        echo "To test token generation:"
        echo "  1. Configure display-client/config.json"
        echo "  2. Run this script again"
    fi
else
    echo -e "${YELLOW}⚠ Skipping token generation test${NC}"
    echo "config.json not found at: $CONFIG_FILE"
    echo ""
    echo "To test token generation manually:"
    echo "  curl -X POST $SERVICE_URL/api/embed-token \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"groupId\":\"YOUR-GROUP-ID\",\"reportId\":\"YOUR-REPORT-ID\"}'"
fi

echo ""
echo "========================================"
echo -e "${GREEN}✅ Token Service Tests Complete${NC}"
echo "========================================"
echo ""
