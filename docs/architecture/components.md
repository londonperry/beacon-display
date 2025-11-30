# BEACON Components

**Audience:** For developers implementing or modifying BEACON components

This document describes the technical components, their responsibilities, and file structure.

---

## Component Overview

BEACON consists of three main components:

1. **Display Client** - Browser-based Power BI viewer
2. **Token Service** - Azure AD authentication and token generation
3. **Raspberry Pi Scripts** - System management and auto-start

---

## 1. Display Client

**Location:** Raspberry Pi (Chromium browser)
**Purpose:** Embeds and displays Power BI reports
**Technology:** HTML5, JavaScript ES6+, Power BI Client 2.22.3

### Key Files

```
display-client/
├── index.html              # Main page
├── config.json             # Device configuration
├── config.json.example     # Config template
├── config-public-sample.json  # Public demo config
└── js/
    ├── powerbi-embed.js    # Power BI integration
    ├── config-loader.js    # Config management
    └── error-handler.js    # Error display
```

### File Descriptions

#### index.html
Main HTML page that runs in Chromium kiosk mode. Includes:
- Power BI Client library (from CDN)
- Loading overlay
- Error display container
- Embed container for Power BI report

#### powerbi-embed.js
Core Power BI integration logic:
- Fetches embed token from token service
- Initializes Power BI embed
- Handles auto-refresh (data and tokens)
- Error handling and display

#### config-loader.js
Configuration management:
- Loads config.json
- Validates required fields
- Provides configuration to other modules

#### error-handler.js
User-friendly error display:
- Shows errors on screen (users can't access console)
- Provides actionable guidance
- Logs errors for debugging

### Configuration (config.json)

```json
{
  "deviceId": "store-001-backroom",
  "tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token",
  "groupId": "workspace-guid",
  "reportId": "report-guid",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {
    "storeId": "001"
  }
}
```

**Field Descriptions:**
- `deviceId`: Unique identifier for logging and management
- `tokenServiceUrl`: URL to token generation endpoint
- `groupId`: Power BI workspace ID (from workspace URL)
- `reportId`: Power BI report ID (from report URL)
- `refreshIntervalSeconds`: Data refresh frequency (60 = every minute)
- `tokenRefreshMinutes`: Token renewal interval (50 = refresh at 50 min, before 60 min expiry)
- `filters`: Optional report-level filters (e.g., store-specific data)

**Security Note:** Never commit `config.json` with real IDs. Use `config.json.example` as template.

---

## 2. Token Service

**Location:** Your laptop (POC) or company server (production)
**Purpose:** Generates Power BI embed tokens
**Technology:** Node.js 18+, Express, MSAL

### Two Versions

#### Laptop Version (POC)
**Path:** `token-service/laptop-version/`

For local development and proof-of-concept:
- Runs on your laptop
- HTTP (local network only)
- Simple startup (`npm start`)
- .env file for secrets

#### Cloud Version (Production)
**Path:** `token-service/cloud-version/`

For production deployment:
- Runs on company infrastructure
- HTTPS with valid certificates
- Health check endpoints
- Docker support
- Secrets from environment or Key Vault

### Key Files

```
token-service/
├── laptop-version/         # POC (runs on your laptop)
│   ├── server.js          # Token generation service
│   ├── package.json       # Dependencies
│   └── .env.example       # Config template
│
└── cloud-version/          # Production (Azure/AWS)
    ├── server.js          # Same + health endpoints
    ├── package.json       # Production deps
    ├── Dockerfile         # Container deployment
    └── .env.example       # Cloud config template
```

### Dependencies

```json
{
  "express": "4.18.2",           // Web server
  "@azure/msal-node": "2.6.0",   // Azure auth
  "dotenv": "16.3.1",            // Environment vars
  "cors": "2.8.5"                // Cross-origin requests
}
```

### Configuration (.env)

```bash
TENANT_ID=azure-tenant-id
CLIENT_ID=app-client-id
CLIENT_SECRET=client-secret-value
PORT=3000
NODE_ENV=development
```

**How to Get Values:**
- Azure Portal → Azure AD → App registrations → Your app
- **TENANT_ID:** Directory (tenant) ID
- **CLIENT_ID:** Application (client) ID
- **CLIENT_SECRET:** Certificates & secrets → New client secret

**Security Note:** Never commit `.env` files. Always use `.env.example` as template.

### API Endpoints

#### GET /health
Health check endpoint (returns service status)

**Response:**
```json
{
  "status": "healthy"
}
```

#### POST /api/embed-token
Generate embed token for Power BI report

**Request Body:**
```json
{
  "groupId": "workspace-guid",
  "reportId": "report-guid"
}
```

**Response:**
```json
{
  "token": "embed-token-string",
  "expiration": "2025-11-30T12:34:56Z",
  "reportId": "report-guid"
}
```

---

## 3. Raspberry Pi Scripts

**Location:** Raspberry Pi
**Purpose:** System management, auto-start, monitoring
**Technology:** Bash scripts, systemd

### Key Files

```
raspberry-pi/
├── install.sh             # One-time setup script
├── start-display.sh       # Boot script (starts Chromium)
├── watchdog.sh            # Auto-recovery monitor
└── systemd/
    └── beacon-display.service  # Auto-start service
```

### Script Descriptions

#### install.sh
One-time setup script that:
- Installs required packages (Chromium, X server)
- Configures auto-login and kiosk mode
- Sets up systemd service for auto-start
- Configures watchdog for monitoring
- Optimizes memory and performance settings
- Applies hardware-specific configurations

**Usage:**
```bash
sudo raspberry-pi/install.sh
```

#### start-display.sh
Boot script that:
- Starts X server
- Launches Chromium in kiosk mode
- Loads display-client/index.html
- Runs watchdog in background

**Chromium Flags:**
```bash
--kiosk                      # Full-screen mode
--noerrdialogs              # Suppress error dialogs
--disable-infobars          # Hide info bars
--no-first-run              # Skip first-run wizard
--disable-features=TranslateUI  # No translation prompts
--check-for-update-interval=31536000  # Disable auto-updates
```

#### watchdog.sh
Monitoring script that:
- Checks memory usage every 60 seconds
- Restarts service if memory >85%
- Monitors CPU temperature
- Logs system health metrics

**Thresholds (Pi Zero 2 W):**
- Memory: 435MB (85% of 512MB)
- Temperature: 70°C (throttling threshold)

#### beacon-display.service
Systemd service file that:
- Starts display on boot
- Restarts on failure
- Sets memory limits
- Manages service lifecycle

**Configuration:**
```ini
[Service]
Type=simple
User=pi
ExecStart=/home/pi/beacon-display/raspberry-pi/start-display.sh
Restart=on-failure
MemoryMax=412M  # 80% of 512MB
```

---

## Deployment Scripts

**Location:** `scripts/`
**Purpose:** Deployment automation

### deploy-to-pi.sh
Copies files from laptop to Raspberry Pi via SSH

**Usage:**
```bash
./scripts/deploy-to-pi.sh <pi-ip-address>
```

**What it does:**
- Copies display-client files
- Copies raspberry-pi scripts
- Sets correct permissions
- Preserves directory structure

### test-token-service.sh
Tests token service locally

**Usage:**
```bash
./scripts/test-token-service.sh
```

**What it does:**
- Checks if service is running
- Tests /health endpoint
- Tests /api/embed-token endpoint
- Validates token response

---

## File Structure

Complete project structure:

```
beacon-display/
│
├── token-service/
│   ├── laptop-version/         # POC (runs on your laptop)
│   │   ├── server.js          # Token generation service
│   │   ├── package.json       # Dependencies
│   │   └── .env.example       # Config template
│   │
│   └── cloud-version/          # Production (Azure/AWS)
│       ├── server.js          # Same + health endpoints
│       ├── package.json       # Production deps
│       ├── Dockerfile         # Container deployment
│       └── .env.example       # Cloud config template
│
├── display-client/
│   ├── index.html             # Main display page
│   ├── config.json.example    # Config template
│   ├── config-public-sample.json  # Public demo config
│   └── js/
│       ├── powerbi-embed.js   # Power BI integration
│       ├── config-loader.js   # Config loading
│       └── error-handler.js   # Error display
│
├── raspberry-pi/
│   ├── install.sh             # One-time setup script
│   ├── start-display.sh       # Boot script (starts Chromium)
│   ├── watchdog.sh            # Auto-recovery monitor
│   └── systemd/
│       └── beacon-display.service  # Auto-start service
│
└── scripts/
    ├── deploy-to-pi.sh        # Copy files via SSH
    └── test-token-service.sh  # Local testing
```

---

## Component Interaction

### Startup Sequence

1. **Pi boots** → systemd starts beacon-display.service
2. **Service starts** → start-display.sh runs
3. **X server launches** → Chromium starts in kiosk mode
4. **Chromium loads** → index.html from display-client
5. **JavaScript runs** → config-loader.js loads config.json
6. **Token request** → powerbi-embed.js calls token service
7. **Token service** → Authenticates with Azure AD
8. **Azure AD responds** → Access token returned
9. **Token service** → Requests embed token from Power BI API
10. **Power BI responds** → Embed token returned (1-hour validity)
11. **Display receives token** → Power BI report embeds
12. **Report renders** → Dashboard displays
13. **Auto-refresh** → Data every 60s, token every 50min
14. **Watchdog monitors** → Memory, temperature, health

### Communication Flow

```
Display Client (Pi)
    │
    ├─► Token Service (Laptop/Server)
    │       │
    │       └─► Azure AD (login.microsoftonline.com)
    │               │
    │               └─► Returns access token
    │       │
    │       └─► Power BI API (api.powerbi.com)
    │               │
    │               └─► Returns embed token
    │
    └─► Power BI Content (app.powerbi.com)
            │
            └─► Loads report data
```

---

## Related Documentation

- **[Architecture Overview](README.md)** - High-level system design
- **[Authentication](authentication.md)** - Azure AD integration details
- **[Security Model](security-model.md)** - Security requirements and best practices
- **[Data Flow](data-flow.md)** - Request flow and token lifecycle
- **[Hardware Guide](../hardware/README.md)** - Device specifications
- **[Troubleshooting](../troubleshooting/README.md)** - Common issues

---

**Last Updated:** 2025-11-30
