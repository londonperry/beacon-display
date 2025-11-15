# BEACON Architecture

Technical architecture and implementation details.

## System Overview

```
┌─────────────────────────────────────────┐
│  Personal Network (POC)                 │
│                                         │
│  ┌─────────────┐       ┌──────────────┐ │
│  │ Raspberry Pi│──────▶│ Your Laptop  │ │
│  │  (Display)  │       │(Token Service) │
│  └─────────────┘       └──────┬───────┘ │
└────────────────────────────────┼────────┘
                                 │
                           Internet
                                 │
               ┌─────────────────┼──────────────┐
               │                 │              │
         ┌──────▼─────┐   ┌──────▼──────┐  ┌───▼────┐
         │  Azure AD  │   │  Power BI   │  │  CDN   │
         └────────────┘   └─────────────┘  └────────┘
```

## Components

### 1. Display Client
**Location**: Raspberry Pi (Chromium browser)
**Purpose**: Embeds and displays Power BI reports
**Technology**: HTML5, JavaScript ES6+, Power BI Client 2.22.3

**Key Files**:
```
display-client/
├── index.html              # Main page
├── config.json             # Device configuration
└── js/
    ├── powerbi-embed.js    # Power BI integration
    ├── config-loader.js    # Config management
    └── error-handler.js    # Error display
```

### 2. Token Service
**Location**: Your laptop (POC) or company server (production)
**Purpose**: Generates Power BI embed tokens
**Technology**: Node.js 18+, Express, MSAL

**Dependencies**:
```json
{
  "express": "4.18.2",           // Web server
  "@azure/msal-node": "2.6.0",   // Azure auth
  "dotenv": "16.3.1",            // Environment vars
  "cors": "2.8.5"                // Cross-origin requests
}
```

**Two Versions**:
- **Laptop**: POC development (runs on local machine)
- **Cloud**: Production-ready (Azure/AWS deployment, includes health endpoints)

## Authentication Flow

```
1. Display boots → loads index.html
   │
2. Requests embed token from token service
   │
3. Token service authenticates to Azure AD
   │  (using CLIENT_ID + CLIENT_SECRET)
   │
4. Azure AD returns access token
   │
5. Token service requests embed token from Power BI
   │  (for specific workspace + report)
   │
6. Power BI returns embed token (valid 1 hour)
   │
7. Display receives embed token
   │
8. Power BI report renders
   │
9. Auto-refresh:
   ├─ Every 50 min: Request new embed token
   └─ Every 60 sec: Refresh report data
```

**Security Model**:
- Service Principal (app identity, not user)
- Read-only permissions (Report.Read.All)
- Workspace-scoped access (not tenant-wide)
- 1-hour token expiry with auto-renewal
- No user interaction required

## Hardware Specifications

### Entry Tier: Raspberry Pi Zero 2 W

```
CPU:          4× ARM Cortex-A53 @ 1GHz
RAM:          512MB LPDDR2
Storage:      32GB microSD (Class 10)
WiFi:         2.4GHz 802.11 b/g/n only
Video:        Mini-HDMI 1080p60
Power:        5V @ 2.5A (2-3W typical)
Size:         65mm × 30mm × 5mm
Cost:         ~$15
Lifespan:     5+ years
Use Case:     Simple dashboards, budget deployments
```

**Other supported devices**: See [HARDWARE-COMPATIBILITY.md](HARDWARE-COMPATIBILITY.md) for Pi 4, Pi 5, Intel NUC, and Orange Pi specifications

**Performance**:
- Boot time: 90-120 seconds
- Memory usage: 300-400MB (60-80% of total)
- CPU load: 30-50% during display
- Temperature: 45-55°C normal, throttles at 70°C
- Power consumption: ~$2/year electricity

**Why This Hardware**:
- Lowest cost option meeting requirements ($50 total)
- Sufficient for browser-based dashboard display
- Small form factor (hidden behind TV/monitor)
- No battery = truly always-on, no charging infrastructure
- Fanless/silent operation ideal for office environments
- Large community support and extensive documentation

### Required Accessories

- 32GB microSD Card (Class 10): $10
- Mini-HDMI to HDMI Cable: $8
- Power Supply (5V 2.5A): $10
- Optional case with heatsink: $7
- **Total**: $43-50

## Software Stack

### Operating System
**Raspberry Pi OS Lite (64-bit)**
- Based on Debian 12 "Bookworm"
- ARM64 architecture
- No desktop environment (headless)
- ~1GB installed size

### Display Stack
- **Chromium**: Kiosk mode (full-screen, no UI)
- **Power BI Client**: v2.22.3 from CDN
- **JavaScript**: ES6+ (no transpilation)
- **Auto-start**: systemd service

### Token Service Stack
- **Node.js**: 18 LTS or 20 LTS
- **Express**: Web server framework
- **MSAL**: Microsoft Authentication Library
- **HTTPS**: Production only (POC uses HTTP locally)

## Configuration

### Display Client (config.json)

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

**Field Descriptions**:
- `deviceId`: Unique identifier for logging
- `tokenServiceUrl`: URL to token generation endpoint
- `groupId`: Power BI workspace ID (from URL)
- `reportId`: Power BI report ID (from URL)
- `refreshIntervalSeconds`: Data refresh frequency (60 = every minute)
- `tokenRefreshMinutes`: Token renewal (50 = refresh at 50 min, before 60 min expiry)
- `filters`: Optional report-level filters (e.g., store-specific data)

### Token Service (.env)

```bash
TENANT_ID=azure-tenant-id
CLIENT_ID=app-client-id
CLIENT_SECRET=client-secret-value
PORT=3000
NODE_ENV=development
```

**How to Get Values**:
- Azure Portal → Azure AD → App registrations → Your app
- **TENANT_ID**: Directory (tenant) ID
- **CLIENT_ID**: Application (client) ID
- **CLIENT_SECRET**: Certificates & secrets → New client secret

## Network Requirements

### POC Network

```
Home Router (192.168.1.1)
├─ Laptop (192.168.1.100) - Token Service
└─ Raspberry Pi (192.168.1.150) - Display
```

**Pi Needs Access To**:
- Laptop:3000 (token service)
- login.microsoftonline.com:443 (Azure AD)
- api.powerbi.com:443 (Power BI API)
- app.powerbi.com:443 (Power BI content)
- cdn.jsdelivr.net:443 (Power BI JS library)

**Bandwidth**:
- Initial load: 2-5 MB
- Hourly: 3-30 MB
- Daily: 50-100 MB
- Monthly: 1.5-3 GB

### Production Network

See [DEPLOYMENT.md](DEPLOYMENT.md) for corporate network requirements including:
- Dedicated IoT VLAN
- Firewall segmentation
- 802.1X authentication
- Internal token service

## File Structure

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

## Performance Characteristics

### Boot Sequence

```
Power On               T+0s
├─ Bootloader         T+5s
├─ Linux Kernel       T+15s
├─ System Services    T+30s
├─ Network Ready      T+45s
├─ X Server           T+60s
├─ Chromium Launch    T+75s
├─ Fetch Token        T+85s
├─ Load Report        T+90s
└─ Fully Rendered     T+105s

Total: ~2 minutes
```

### Resource Usage

**Idle (after boot)**:
- Memory: 200MB (40%)
- CPU: 5-10%
- Temp: 40-45°C

**Active Display**:
- Memory: 350MB (70%)
- CPU: 30-50%
- Temp: 50-55°C

**Peak Load**:
- Memory: 450MB (90% - watchdog restarts if >85%)
- CPU: 80-100%
- Temp: 60°C

## Security Model

BEACON uses a **service principal-based authentication model** with distinct security requirements for POC and production environments.

**POC Security**: Local network, HTTP, secrets in `.env` file (acceptable for development)

**Production Security**: Company infrastructure, HTTPS, Azure Key Vault, network segmentation, key-based SSH (required for enterprise)

**Azure AD Permissions**:
- Service Principal (application identity)
- Application permission: Report.Read.All (read-only)
- Workspace-scoped (not tenant-wide)
- Annual secret rotation

For comprehensive security details, threat models, network configuration, and vulnerability reporting, see **[SECURITY.md](SECURITY.md)**.

## Constraints & Limitations

**Hardware**:
- 512MB RAM total (must stay <400MB)
- 2.4GHz WiFi only (no 5GHz)
- Single-core performance for complex reports
- No battery backup

**Network**:
- Requires internet access for Azure AD and Power BI
- Token service must be reachable
- ~100MB daily bandwidth

**Power BI**:
- Requires Pro or Premium workspace
- Service principal must be workspace Member
- Cannot use "My Workspace"
- Row-level security for multi-tenancy

**Development**:
- Token service availability (laptop must be on for POC)
- Client secret expires every 12 months
- Limited debugging on Pi (remote logs via SSH)

---

See [GETTING-STARTED.md](GETTING-STARTED.md) for setup or [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for diagnostics.
