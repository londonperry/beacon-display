# Getting Started with BEACON

Complete setup guide for deploying your proof of concept.

## Timeline

- **Phase 1**: Browser Testing (30 min)
- **Phase 2**: Azure Setup (2 hours)
- **Phase 3**: Token Service (1 hour)
- **Phase 4**: Raspberry Pi (2 hours)
- **Total**: ~6 hours

---

## Phase 1: Browser Testing

Test the display client without any Azure or Pi setup.

```bash
cd display-client
cp config-public-sample.json config.json
open index.html  # Opens public Power BI sample
```

**Expected**: Public Power BI dashboard displays in browser.

---

## Phase 2: Azure & Power BI Setup

### Create Azure Service Principal

1. Go to [portal.azure.com](https://portal.azure.com) → Azure Active Directory → App registrations
2. Click **+ New registration**
   - Name: `BEACON-Display-POC`
   - Account type: Single tenant
   - Click **Register**
3. Record these values (needed later):
   - **Application (client) ID**: `____________________`
   - **Directory (tenant) ID**: `____________________`
4. Go to **Certificates & secrets** → **+ New client secret**
   - Description: `BEACON POC Secret`
   - Expires: 12 months
   - **Copy the secret value immediately** (can't view again)
   - **Client Secret**: `____________________`

### Configure Power BI

1. Get Power BI Pro (60-day trial at powerbi.com) or workspace access
2. Enable service principals:
   - Go to [app.powerbi.com](https://app.powerbi.com) → Gear icon → Admin portal
   - Tenant settings → Developer settings
   - Enable **"Service principals can use Power BI APIs"**
   - Apply to entire organization → **Apply**
3. Create/access a workspace:
   - Workspaces → **+ New workspace** → Name: `BEACON Test`
4. Add service principal to workspace:
   - Open workspace → **...** → Workspace access
   - **+ Add** → Search for `BEACON-Display-POC`
   - Role: **Member** → **Add**
5. Record IDs from URLs:
   - Workspace URL: `app.powerbi.com/groups/{GROUP-ID}/...`
   - **Group ID**: `____________________`
   - Report URL: `.../reports/{REPORT-ID}/...`
   - **Report ID**: `____________________`

---

## Phase 3: Token Service Setup

### Install Node.js

```bash
# Check if installed
node --version  # Should show v18.x or v20.x

# If not installed, download from nodejs.org (LTS version)
```

### Configure & Start Service

```bash
# Navigate to token service
cd token-service/laptop-version

# Install dependencies
npm install

# Create .env file from template
cp .env.example .env

# Edit .env with your Azure credentials
# For getting these values, see SECURITY.md > Secret Management
nano .env

# Start service
npm start
```

⚠️ **Important**: Never commit `.env` file. It's added to `.gitignore` for safety.

For detailed secret management practices, see [SECURITY.md](SECURITY.md).

### Test Token Service

```bash
# Test health endpoint
curl http://localhost:3000/health
# Expected: {"status":"healthy",...}

# Test embed token generation
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{"groupId":"YOUR-GROUP-ID","reportId":"YOUR-REPORT-ID"}'
# Expected: JSON with embedToken, embedUrl, expiration
```

---

## Phase 4: Display Client with Personal Power BI

### Configure Display Client

```bash
# Find your laptop's IP address
# Mac/Linux:
ifconfig | grep "inet " | grep -v 127.0.0.1
# Windows:
ipconfig | findstr IPv4

# Navigate to display client
cd display-client

# Create config from template
cp config.json.example config.json

# Edit config.json with:
# - deviceId: "my-test-display"
# - tokenServiceUrl: "http://YOUR-LAPTOP-IP:3000/api/embed-token"
# - groupId: "YOUR-GROUP-ID"
# - reportId: "YOUR-REPORT-ID"
# - refreshIntervalSeconds: 60
# - tokenRefreshMinutes: 50

# Open in browser
open index.html
```

**Expected**: Your Power BI report displays and refreshes every 60 seconds.

---

## Phase 5: Raspberry Pi Deployment

### Flash SD Card

1. Download [Raspberry Pi Imager](https://raspberrypi.com/software)
2. Insert microSD card
3. Select OS: **Raspberry Pi OS (other)** → **Raspberry Pi OS Lite (64-bit)**
4. Click gear icon (⚙️) for advanced options:
   - Hostname: `beacon-display`
   - Enable SSH: ✓
   - Username: `pi`
   - Password: (choose password)
   - Configure WiFi: (your WiFi credentials)
   - WiFi country: (your country)
   - Timezone: (your timezone)
5. Click **Write** (takes 5-10 minutes)

### First Boot

1. Insert SD card into Pi
2. Connect HDMI and power
3. Wait 2-3 minutes for boot
4. Find Pi's IP address:
   - Check router DHCP client list, OR
   - Connect keyboard and run: `hostname -I`
   - **Pi IP**: `____________________`

### Deploy BEACON Software

```bash
# From your laptop, deploy files to Pi
cd ~/beacon-display
./scripts/deploy-to-pi.sh YOUR-PI-IP-ADDRESS

# SSH to Pi
ssh pi@YOUR-PI-IP-ADDRESS

# Run install script
cd beacon-display
chmod +x raspberry-pi/install.sh
sudo raspberry-pi/install.sh

# Configure display client
cd display-client
cp config.json.example config.json
nano config.json
# Update tokenServiceUrl with your laptop IP
# Ctrl+X, Y, Enter to save

# Reboot
sudo reboot
```

**Expected**: Pi reboots and displays Power BI report in ~2 minutes.

---

## Phase 6: Validation

### Functional Tests

- **Auto-refresh**: Report data updates every 60 seconds
- **Token renewal**: No authentication prompts after 1 hour
- **Boot recovery**: Unplug power → wait 10 sec → plug back in → auto-starts
- **72-hour test**: Leave running for 3 days without intervention

### Performance Check

```bash
# SSH to Pi
ssh pi@YOUR-PI-IP

# Check memory usage (should be <400MB / 80%)
free -h

# Check temperature (should be <60°C)
vcgencmd measure_temp

# View logs
sudo journalctl -u beacon-display -n 50

# Check service status
sudo systemctl status beacon-display
```

---

## Common Commands

```bash
# Token service
curl http://localhost:3000/health                    # Check if running
cd token-service/laptop-version && npm start        # Start service

# Raspberry Pi
ssh pi@YOUR-PI-IP                                    # Connect to Pi
sudo systemctl restart beacon-display                # Restart display
sudo journalctl -u beacon-display -n 50             # View logs
free -h                                              # Memory usage
vcgencmd measure_temp                                # Temperature
```

---

## Next Steps

- ✓ POC working → Prepare stakeholder demo (see PROJECT-DEFINITION.md)
- ✓ Approved for pilot → Enterprise deployment (see DEPLOYMENT.md)
- ✗ Issues → Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**Total Time**: 6-8 hours
**Hardware Cost**: $43-50
**Difficulty**: Intermediate
