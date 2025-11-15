# CLAUDE.md

AI assistant guidance for working with the BEACON codebase.

---

## 🤖 PRELIMINARY INSTRUCTIONS (READ FIRST, EVERY TIME)

**Purpose**: These instructions guide AI assistants to work intelligently with the BEACON project by understanding context, asking clarifying questions, and making optimal decisions based on project constraints.

### Core Operating Principles

1. **Context-First Approach**
   - ALWAYS review relevant documentation before taking action
   - Understand whether the user is working on POC or Production deployment
   - Consider hardware, budget, security, and scale constraints in all decisions
   - Reference the correct documentation (README, GETTING-STARTED, ARCHITECTURE, etc.)

2. **Question Before Assuming**
   - When user intent is ambiguous, ask clarifying questions BEFORE writing code or making changes
   - When multiple valid approaches exist, present options with trade-offs
   - When security implications exist, confirm the approach aligns with POC vs Production requirements
   - When file paths or configuration details are unclear, ask rather than guess

3. **Optimal Path Selection**
   - Consider the MOST EFFICIENT solution given project constraints
   - Balance cost ($50/device target), performance (512MB RAM limit), and complexity
   - Recommend simpler solutions for POC, scalable solutions for Production
   - Always mention if a "quick fix" exists vs. a "production-ready" approach

---

### When to Ask Questions

**ALWAYS ask when**:
- **Scope ambiguity**: User says "fix the token service" but doesn't specify laptop-version vs cloud-version
- **Security context**: User requests changes that could expose secrets or violate security model
- **Environment unclear**: Unknown whether user is working on laptop, Pi, or cloud infrastructure
- **Multiple valid approaches**: E.g., "Should I optimize for cost, performance, or simplicity?"
- **File paths unclear**: User references "config.json" but doesn't specify display-client vs example file
- **Scale assumptions**: Unknown whether solution is for 1 device (POC) or 100+ devices (Production)

**ASK SMART QUESTIONS like**:
- "Are you working on the POC (laptop-version) or preparing for production deployment (cloud-version)?"
- "This change affects security. Should I follow POC guidelines (HTTP, local network) or Production guidelines (HTTPS, Key Vault)?"
- "I can implement this as a quick fix for testing or a scalable solution. Which do you prefer?"
- "Should I optimize for lowest cost (~$50/device with Pi Zero 2 W) or better performance (Pi 4 for $75)?"

---

### Context-Aware Decision Framework

Before proposing solutions, consider these constraints:

#### Hardware Constraints (Raspberry Pi Zero 2 W)
```
RAM:           512MB total (target <400MB / 80% usage)
CPU:           4× ARM Cortex-A53 @ 1GHz
WiFi:          2.4GHz only (no 5GHz)
Boot time:     Target <2 minutes
Temperature:   Normal 45-55°C, throttles >70°C
```

**Implications**:
- Memory-intensive solutions won't work (e.g., heavy Node.js apps on Pi)
- Complex Power BI reports may need Pi 4 upgrade recommendation
- WiFi range limitations matter for deployment planning

#### Budget Constraints
```
POC Target:        <$60 per device
Production Target: <$150 per device (including deployment labor)
100-device TCO:    $31K-86K over 5 years (depends on optimization level)
```

**Implications**:
- Recommend Pi Zero 2 W over Pi 4 unless performance requires it
- Favor open-source/free solutions over commercial platforms
- Bulk pricing and cost optimizations matter at scale

#### Security Context

**POC (Acceptable)**:
- HTTP for local token service
- Secrets in `.env` file (never committed)
- Password-based SSH
- Home WiFi WPA2

**Production (Required)**:
- HTTPS with valid certificates
- Secrets in Azure Key Vault
- Key-based SSH only
- Network segmentation (IoT VLAN)

**Action**: Ask which context applies if unclear, then apply appropriate security model.

#### Network Requirements
```
POC:        Home network, laptop must be on, Pi accesses laptop:3000
Production: Corporate VLAN, centralized token service, firewall rules

Required Outbound Access:
- login.microsoftonline.com:443 (Azure AD)
- api.powerbi.com:443 (Power BI API)
- app.powerbi.com:443 (Power BI content)
- cdn.jsdelivr.net:443 (Power BI JS library)
```

**Implications**:
- Corporate networks may need firewall rules (ask if user needs firewall documentation)
- Token service URL differs between POC and Production

#### Scale Considerations
```
POC:        1 device, manual management
Pilot:      10 devices, basic monitoring
Production: 100+ devices, centralized management, automated alerts
```

**Recommendations by scale**:
- 1-10 devices: Manual SSH, simple scripts
- 10-50 devices: Basic Ansible automation, Google Sheets inventory
- 50-100+ devices: Custom management dashboard OR commercial platform

---

### Smart Recommendations

When providing solutions, structure answers like this:

```markdown
## Quick Answer
[Concise solution for immediate need]

## Context & Trade-offs
- **POC approach**: [Simpler, faster solution]
- **Production approach**: [Scalable, secure solution]
- **Cost**: [Impact on budget]
- **Performance**: [Impact on Pi constraints]

## Recommended Approach
[Your recommendation with rationale based on project constraints]

## Need More Info?
[Questions to ask if context is still unclear]
```

**Example**:
```markdown
## Quick Answer
To rotate the Azure client secret, create a new secret in Azure Portal and update the `.env` file.

## Context & Trade-offs
- **POC**: Update `.env` on laptop, restart `npm start` (5 min)
- **Production**: Update Azure Key Vault, redeploy token service, validate (30 min)
- **Security**: POC stores secrets in `.env` (acceptable), Production requires Key Vault

## Recommended Approach
Since you're in POC phase (laptop-version), update `.env` directly. When moving to production, plan to migrate secrets to Key Vault as documented in DEPLOYMENT.md:228-233.

## Need More Info?
Are you preparing to move to production soon? If yes, I can help set up Key Vault now.
```

---

### File & Path Intelligence

**Common ambiguities**:
- "config.json" → Could be `display-client/config.json` (actual) or `display-client/config.json.example` (template)
- "token service" → Could be `token-service/laptop-version/` (POC) or `token-service/cloud-version/` (Production)
- "install script" → Could be `raspberry-pi/install.sh` (on Pi) or `scripts/deploy-to-pi.sh` (from laptop)

**Always clarify**:
- Which version of the file (actual vs example)?
- Which environment (laptop, Pi, cloud)?
- Which deployment phase (POC, Pilot, Production)?

---

### Error Handling & Troubleshooting

When user reports an issue:

1. **Gather context first**:
   - "Where are you seeing this error: laptop browser, Pi display, or token service logs?"
   - "Are you in POC setup (laptop token service) or production (cloud token service)?"

2. **Reference TROUBLESHOOTING.md**:
   - Check if issue is documented in TROUBLESHOOTING.md
   - Provide diagnostic commands from that doc
   - Link to specific line numbers (e.g., TROUBLESHOOTING.md:83-86)

3. **Provide layered solutions**:
   - Quick fix (restart service, clear cache)
   - Root cause investigation (check logs, verify config)
   - Prevention (monitoring, better error handling)

---

### Code Generation Guidelines

When writing or modifying code:

1. **Respect constraints**:
   - JavaScript: ES6+ (no transpilation needed, Chromium supports it)
   - Shell scripts: Bash-compatible, test on Pi OS
   - Memory: Keep Pi memory usage <400MB
   - Dependencies: Minimize npm packages (download size matters on Pi)

2. **Security-first**:
   - NEVER generate code that commits `.env` or `config.json` files
   - NEVER hardcode secrets in code
   - Validate security model (POC vs Production) before generating sensitive code

3. **Commenting**:
   - Explain "why" not "what"
   - Note resource constraints (e.g., `// Keep array small, Pi has 512MB RAM`)
   - Include troubleshooting hints (e.g., `// If this fails, check firewall rules`)

4. **Error messages**:
   - Display-client errors must be user-friendly (users can't access browser console on Pi)
   - Include actionable guidance (e.g., "Check network connection" not "Error 500")

---

### Documentation References

| Document | Use When |
|----------|----------|
| **README.md** | Quick start, project overview, first-time users |
| **GETTING-STARTED.md** | Step-by-step setup, phase-by-phase deployment |
| **ARCHITECTURE.md** | Technical details, system design, component interaction |
| **TROUBLESHOOTING.md** | Diagnosing issues, error resolution, performance problems |
| **PROJECT-DEFINITION.md** | Business context, goals, budget, stakeholder info |
| **DEPLOYMENT.md** | Production deployment, enterprise scale, cost models |

**When to reference**:
- Setup questions → GETTING-STARTED.md
- "How does X work?" → ARCHITECTURE.md
- "Why isn't X working?" → TROUBLESHOOTING.md
- "How do I deploy to 100 stores?" → DEPLOYMENT.md
- "What's the business case?" → PROJECT-DEFINITION.md

---

### Anti-Patterns (What NOT to Do)

❌ **Don't assume**:
- "I'll assume you're using the cloud-version" (Ask which version!)
- "I'll assume this is for production" (Clarify POC vs Production!)
- "I'll assume you have Azure set up" (Check if they need setup guidance!)

❌ **Don't over-engineer**:
- Suggesting Kubernetes for 10 devices (overkill, see DEPLOYMENT.md cost models)
- Recommending Pi 4 when Pi Zero 2 W suffices (unnecessary cost)
- Complex monitoring for POC (save for Production)

❌ **Don't ignore constraints**:
- Suggesting 5GHz WiFi (Pi Zero 2 W doesn't support it)
- Recommending memory-heavy solutions (512MB limit)
- Proposing expensive commercial platforms without mentioning cost impact

❌ **Don't skip security checks**:
- Suggesting HTTP in production (must be HTTPS)
- Recommending secrets in config files for production (must use Key Vault)
- Ignoring network segmentation for corporate deployments

---

### Quality Checklist

Before providing an answer, verify:

- [ ] I understand whether this is POC or Production context
- [ ] I've asked clarifying questions if anything is ambiguous
- [ ] My solution respects hardware constraints (512MB RAM, 2.4GHz WiFi)
- [ ] My solution aligns with budget targets ($50-150/device)
- [ ] My solution follows appropriate security model (POC vs Production)
- [ ] I've referenced relevant documentation (with line numbers when helpful)
- [ ] I've provided trade-offs if multiple approaches exist
- [ ] I've explained "why" not just "what"
- [ ] I've considered scale implications (1 device vs 100 devices)

---

## Project Overview

BEACON (**B**usiness **E**mbedded **A**nalytics **C**ontent **O**n **N**etwork) is a dedicated, always-on Power BI dashboard display system using Raspberry Pi to transform existing monitors and TVs into self-managing dashboard displays for $50-150 per screen.

**Status**: Proof of Concept phase
**Primary Goal**: Democratize real-time data visibility by repurposing existing display infrastructure with dedicated, zero-touch displays
**Key Value**: 70-90% cost savings vs commercial solutions + improved operational visibility + leverage existing displays + touchless operation

---

## Quick Reference Commands

### Token Service (Node.js)
```bash
cd token-service/laptop-version
cp .env.example .env
# Edit .env with Azure credentials
npm install && npm start

# Test
curl http://localhost:3000/health
```

### Display Client (Browser)
```bash
cd display-client
cp config-public-sample.json config.json  # Public sample, no Azure
# OR
cp config.json.example config.json         # Personal Azure/Power BI
# Open index.html in browser
```

### Raspberry Pi
```bash
./scripts/deploy-to-pi.sh <pi-ip>          # Deploy files
ssh pi@<pi-ip>                             # Connect
sudo systemctl status beacon-display       # Check service
sudo journalctl -u beacon-display -n 50    # View logs
free -h                                     # Memory
vcgencmd measure_temp                       # Temperature
```

---

## Architecture

### Two-Component System

**Token Service** (Node.js):
- Authenticates with Azure AD using service principal
- Generates Power BI embed tokens (1-hour validity)
- Two versions: laptop (POC) and cloud (production)

**Display Client** (HTML/JavaScript):
- Runs in Chromium browser on Raspberry Pi
- Embeds Power BI reports using tokens
- Auto-refreshes data (60 sec) and tokens (50 min)

### Authentication Flow
```
Display → Token Service → Azure AD → Power BI API
                             ↓
                  Access Token (service principal)
                             ↓
                  Embed Token (1-hour validity)
                             ↓
            Display ← Embedded Report
```

---

## File Structure

```
beacon-display/
├── token-service/
│   ├── laptop-version/         # POC (runs on local machine)
│   │   ├── server.js           # Token generation service
│   │   ├── package.json        # Dependencies
│   │   └── .env.example        # Azure credentials template
│   └── cloud-version/          # Production (Azure/AWS)
│       ├── server.js           # Same + health endpoints
│       ├── Dockerfile          # Container deployment
│       └── .env.example        # Cloud config template
│
├── display-client/
│   ├── index.html              # Main display page
│   ├── config.json.example     # Personal setup template
│   ├── config-public-sample.json  # Public demo config
│   └── js/
│       ├── powerbi-embed.js    # Power BI integration
│       ├── config-loader.js    # Config management
│       └── error-handler.js    # Error display
│
├── raspberry-pi/
│   ├── install.sh              # One-time setup
│   ├── start-display.sh        # Boot script (Chromium kiosk)
│   ├── watchdog.sh             # Auto-recovery monitor
│   └── systemd/
│       └── beacon-display.service  # Auto-start service
│
└── scripts/
    ├── deploy-to-pi.sh         # Copy files to Pi
    └── test-token-service.sh   # Local testing
```

---

## Documentation Structure

| File | Purpose |
|------|---------|
| **README.md** | Entry point and quick start |
| **GETTING-STARTED.md** | Step-by-step setup guide (6 hours total) |
| **ARCHITECTURE.md** | Technical architecture and stack details |
| **TROUBLESHOOTING.md** | Common issues and diagnostic procedures |
| **PROJECT-DEFINITION.md** | Business case, goals, stakeholder info |
| **DEPLOYMENT.md** | Enterprise deployment (pilot → production) |

---

## Configuration

### Token Service (.env)
```bash
TENANT_ID=azure-tenant-id          # Azure AD tenant
CLIENT_ID=app-client-id            # App registration client ID
CLIENT_SECRET=secret-value         # Expires every 12 months
PORT=3000
NODE_ENV=development
```

**Security**: Never commit `.env` files. Always use `.env.example` as template.

### Display Client (config.json)
```json
{
  "deviceId": "bakery-001-production",
  "tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token",
  "groupId": "workspace-guid",
  "reportId": "report-guid",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {"storeId": "001"}
}
```

**Security**: Never commit `config.json` with real IDs. Use `config.json.example` as template.

---

## Key Constraints

### Hardware (Raspberry Pi Zero 2 W)
- **RAM**: 512MB total (keep usage <400MB or 80%)
- **CPU**: 4× ARM Cortex-A53 @ 1GHz
- **WiFi**: 2.4GHz only (no 5GHz support)
- **Boot time**: Target <2 minutes
- **Temperature**: Normal 45-55°C, throttles >70°C
- **Watchdog**: Auto-restarts if memory >85%

### Network
- Token service must be reachable from Pi
- Required access: Azure AD, Power BI API, CDN
- Bandwidth: ~50-100MB daily
- Corporate networks may need firewall rules/IoT VLAN

### Power BI
- Requires Pro or Premium workspace
- Service principal must be workspace Member
- Cannot use "My Workspace"
- Embed tokens expire after 1 hour (auto-refresh at 50 min)

### Security

**POC** (Acceptable):
- Token service on local network (HTTP)
- Client secret in .env file (not committed)
- Home WiFi WPA2
- Password-based SSH

**Production** (Required):
- Token service on company infrastructure (HTTPS)
- Secrets in Key Vault or secure environment
- Network segmentation (IoT VLAN)
- Key-based SSH only
- Firewall rules and audit logging

---

## Common Development Tasks

### Adding a New Display
1. Copy display-client to Pi
2. Edit config.json (deviceId, filters)
3. Ensure Pi can reach token service
4. Run install script

### Adding Displays to Different Departments
1. Copy display-client to Pi
2. Edit config.json (deviceId, reportId for department-specific dashboard)
3. Configure filters for department/location data
4. Ensure Pi can reach token service
5. Run install script

### Rotating Azure Secrets
1. Create new client secret in Azure Portal
2. Update .env with new secret (or Key Vault for production)
3. Restart token service
4. Old secret valid until expiration

### Troubleshooting
1. Token service running: `curl http://localhost:3000/health`
2. Pi connectivity: `ping <laptop-ip>` from Pi
3. Service logs: `sudo journalctl -u beacon-display -n 50`
4. Verify config.json values
5. Browser console (F12) for JS errors

### Performance Optimization
- Simplify Power BI reports (fewer visuals)
- Increase refresh intervals if slow
- Monitor memory: `free -h`
- Consider Pi 4 upgrade for complex reports (adds $25/device)

---

## Code Style Guidelines

### JavaScript
- ES6+ features (async/await, arrow functions)
- No transpilation needed (modern Chromium)
- Minimal dependencies (Power BI Client from CDN)
- Clear error messages for display (users can't access console)

### Shell Scripts
- Bash-compatible for Raspberry Pi OS
- Error handling and logging
- Absolute paths preferred
- Test on actual Pi before committing

### Comments
- Explain "why" not "what"
- Document security considerations
- Note resource constraints (memory, bandwidth)
- Include troubleshooting hints

---

## External Dependencies

```json
{
  "token-service": {
    "express": "4.18.2",
    "@azure/msal-node": "2.6.0",
    "dotenv": "16.3.1",
    "cors": "2.8.5"
  },
  "display-client": {
    "powerbi-client": "2.22.3 (CDN)"
  },
  "raspberry-pi": {
    "os": "Raspberry Pi OS Lite (Debian 12)",
    "browser": "Chromium (latest from repos)"
  }
}
```

---

## Development Workflow

### Phase 1: Local Testing
Test display-client with public Power BI sample (no Azure/Pi needed)

### Phase 2: Token Service
Set up Azure AD, configure Power BI workspace, implement token service

### Phase 3: Display Integration
Create HTML/JS, integrate Power BI library, test auto-refresh

### Phase 4: Pi Deployment
Flash OS, deploy files, run install script, configure auto-start

### Phase 5: Validation
72-hour test, performance monitoring, recovery testing

---

## Production Deployment

When adapting for corporate deployment (see DEPLOYMENT.md):
- Deploy token service to company infrastructure (HTTPS)
- Use Azure App Service, company VM, or Docker
- Implement network segmentation (IoT VLAN)
- Add centralized monitoring and alerting
- Create device management tools (or use commercial platform)
- Store-specific data filtering (row-level security)
- Security review by IT team

**Cost Optimization** (DEPLOYMENT.md):
- Baseline 100-device TCO: $86K over 5 years (entry tier, commercial platform)
- Optimized TCO (custom management): $31K over 5 years (64% reduction)
- Mixed-tier approach: $78K over 5 years (optimized for use case)
- Key savings: Eliminate commercial platform ($9,600/year), bulk hardware pricing, automation, repurpose existing displays ($0 display cost)

---

## For Detailed Information

- **Setup**: [GETTING-STARTED.md](GETTING-STARTED.md) - Step-by-step POC deployment
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md) - Technical deep dive
- **Issues**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Diagnostic procedures
- **Enterprise**: [DEPLOYMENT.md](DEPLOYMENT.md) - Pilot and production rollout
- **Business Case**: [PROJECT-DEFINITION.md](PROJECT-DEFINITION.md) - Goals and stakeholders

---

**Last Updated**: 2025-11-14 17:32:18
**Maintainer**: This file is maintained as project context for AI assistants
