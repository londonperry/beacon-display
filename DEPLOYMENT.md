# Enterprise Deployment Guide

Adapting BEACON from personal POC to corporate production deployment.

## POC vs Production Comparison

| Aspect | POC | Production |
|--------|-----|------------|
| **Network** | Home WiFi (WPA2) | Corporate VLAN (802.1X) |
| **Token Service** | Laptop (HTTP) | Company server (HTTPS) |
| **Azure** | Personal account | Company Azure tenant |
| **Management** | Manual SSH | Centralized dashboard |
| **Security** | Password SSH, basic | Key-based SSH, hardened |
| **Monitoring** | Visual inspection | Automated alerts |
| **Support** | Self | Tiered IT support model |
| **Scale** | 1 device | 100+ devices |

## Network Requirements

### IoT VLAN Configuration

For detailed network security requirements, firewall rules, and configuration templates, see **[SECURITY.md](SECURITY.md) > Network Security**.

Summary:
- Dedicated IoT VLAN with network segmentation
- 802.1X authentication or WPA2-Enterprise
- DHCP with MAC reservations
- Explicit firewall rules (required outbound/inbound access documented in SECURITY.md)
- SSH access from Management VLAN only

## Azure AD Configuration

### Service Principal Setup

For detailed Azure AD security configuration, see **[SECURITY.md](SECURITY.md) > Authentication & Authorization**.

Key requirements:
- Service principal with read-only permissions
- Report.Read.All (Application permission)
- Workspace-scoped access (not tenant-wide)
- Client secret with 12-month rotation
- Azure Key Vault for production secret storage

## Power BI Configuration

### Workspace Access

Key requirements:
- Service principal as workspace Member (minimum required)
- Read-only access to required reports
- Row-level security filters (if multi-tenant)
- Hourly token expiry with automatic renewal

## Token Service Deployment

### Option A: Company VM/Server

```javascript
// token-service/cloud-version/server.js
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0';

// Add HTTPS
const https = require('https');
const fs = require('fs');
const options = {
  key: fs.readFileSync('/path/to/company-key.pem'),
  cert: fs.readFileSync('/path/to/company-cert.pem')
};

https.createServer(options, app).listen(PORT, HOST);
```

### Option B: Azure App Service

```bash
# Deploy to Azure
az webapp up \
  --name beacon-token-service \
  --resource-group beacon-rg \
  --runtime "NODE|18-lts"

# Configure environment variables in Azure Portal
# Add: TENANT_ID, CLIENT_ID, CLIENT_SECRET (from Key Vault)
```

### Option C: Docker Container

```bash
# Use provided Dockerfile in cloud-version/
docker build -t beacon-token-service .
docker run -d \
  -p 3000:3000 \
  -e TENANT_ID=$TENANT_ID \
  -e CLIENT_ID=$CLIENT_ID \
  -e CLIENT_SECRET=$CLIENT_SECRET \
  beacon-token-service
```

### Deployment Checklist

- [ ] Choose platform (VM, App Service, Container)
- [ ] Request infrastructure from IT
- [ ] Deploy cloud-version code (includes health endpoints)
- [ ] Configure environment variables in Key Vault
- [ ] Set up HTTPS with company certificate
- [ ] Configure internal DNS (e.g., beacon-token.company.com)
- [ ] Test from corporate network
- [ ] Document in company wiki/runbook

## Device Management at Scale

### Management Options

**Option A: Commercial Platform**
- Tools: Yodeck, PiSignage ($8/device/month)
- Pros: Web dashboard, remote config, health monitoring
- Cons: Monthly cost

**Option B: Custom Scripts**
- Tools: Ansible/Salt, SSH automation
- Pros: No recurring cost, full control
- Cons: Development time

**Option C: Hybrid** (Recommended)
- Core management: Custom scripts
- Monitoring: Commercial platform or custom dashboard

### Device Inventory Tracking

```csv
DeviceID,StoreID,Location,MACAddress,IPAddress,InstallDate,LastSeen,Status
beacon-001,001,Backroom,b8:27:eb:xx:xx:xx,10.50.1.10,2025-01-15,2025-01-20,Online
beacon-002,002,Backroom,b8:27:eb:xx:xx:xx,10.50.1.11,2025-01-15,2025-01-20,Online
```

### Health Monitoring Alerts

```
Alert Conditions:
├─ Device offline >30 min → Email IT support
├─ Memory usage >85% → Warning (watchdog restarts)
├─ Temperature >60°C → Warning
├─ Service crashed → Auto-restart + alert
└─ Token service unreachable → Alert
```

### Remote Management

```bash
# Update all devices to new report
./scripts/update-all-displays.sh new-report-id

# Update specific device
./scripts/update-display.sh 192.168.1.100 new-report-id store-001

# Health check all devices
./scripts/health-check-all.sh
```

## Security Hardening

### Security Checklist

**Information Security Review**:
- [ ] Threat model assessment
- [ ] Risk analysis completed
- [ ] Mitigations documented
- [ ] InfoSec team sign-off

**Network Security**:
- [ ] Devices on isolated VLAN
- [ ] Firewall rules configured
- [ ] No direct internet access
- [ ] SSH restricted to management subnet

**Application Security**:
- [ ] Service principal minimum permissions
- [ ] Secrets in Key Vault (never in code)
- [ ] HTTPS enforced
- [ ] Rate limiting on token service

**Operational Security**:
- [ ] SSH key-based only (no passwords)
- [ ] Centralized key management
- [ ] Annual client secret rotation scheduled
- [ ] Device decommissioning procedure
- [ ] Incident response plan

**Compliance**:
- [ ] Food safety requirements validated
- [ ] Audit logging enabled
- [ ] Data classification appropriate
- [ ] Privacy impact assessment (if needed)

## Pilot Program

### Objectives
1. Validate solution in production environment
2. Identify infrastructure integration issues
3. Test support procedures
4. Gather user feedback
5. Refine deployment process

### Scope

**Stores**: 10 locations (geographic, network, and volume diversity)
**Duration**: 6-8 weeks
**Timeline**:
- Week 1-2: Deploy to 10 stores
- Week 3-4: Monitor, gather feedback, fix issues
- Week 5-6: Refine processes, update docs
- Week 7-8: Final evaluation, rollout decision

**Success Criteria**:
- [ ] 98% uptime across all pilot devices
- [ ] Zero security incidents
- [ ] <2 support tickets per device
- [ ] Positive feedback from 8/10 store managers
- [ ] Boot time <2 minutes
- [ ] Cost per device <$150 (including deployment)

### Deployment Process

**Pre-Deployment** (1 week):
- IT infrastructure ready (network, token service, monitoring)
- Master device image created
- 10 devices + 2 spares provisioned
- Store managers notified with installation guides

**Deployment Week**:
- Day 1: Ship devices (expedited)
- Day 2: IT on standby
- Day 3: Stores install (15-30 min each)
- Day 4-5: Monitor and address issues

**Monitoring** (Weeks 2-6):
- Daily: Device health checks, error logs, support tickets
- Weekly: Manager feedback, stakeholder updates, process refinement
- Monthly: Formal pilot review

## Cost Model

### Cost Breakdown Methodology

**Employee Rate**: $50/hour (blended IT rate)
**Annual Work Hours**: 2,080 hours (40 hrs/week × 52 weeks)
**Intent**: Minimal ongoing labor burden (<5% of one FTE)

### Pilot Program (10 Stores)

#### Hardware Costs
```
Component                          Quantity    Unit Cost    Total
─────────────────────────────────────────────────────────────────
Raspberry Pi Zero 2 W              10          $15          $150
Power supply (5V 2.5A)             10          $8           $80
microSD card (32GB)                10          $7           $70
Case + mounting hardware           10          $10          $100
HDMI cable                         10          $8           $80
Backup devices                     2           $50          $100
─────────────────────────────────────────────────────────────────
Hardware Subtotal:                                          $580
```

#### Labor Costs (Initial Setup)
```
Task                               Hours    Rate      Total
─────────────────────────────────────────────────────────
Infrastructure planning            8        $50/hr    $400
Azure/network configuration        12       $50/hr    $600
Device provisioning                10       $50/hr    $500
Deployment support                 8        $50/hr    $400
Documentation                      6        $50/hr    $300
─────────────────────────────────────────────────────────
Labor Subtotal (44 hours):                            $2,200
```

#### Software/Services (2-month pilot)
```
Management platform (optional)     2 months  $80/mo    $160
Azure infrastructure (dev tier)    2 months  $50/mo    $100
─────────────────────────────────────────────────────────
Services Subtotal:                                     $260
```

**Pilot Total**: $3,040 ($304 per store)

---

### Production Rollout (100 Stores)

#### Year 1 Costs

**Hardware** (including pilot devices)
```
Component                          Quantity    Unit Cost    Total
─────────────────────────────────────────────────────────────────
Production devices                 90          $50          $4,500
Spares (20% of fleet)              20          $50          $1,000
Pilot devices (reused)             10          $0           $0
─────────────────────────────────────────────────────────────────
Hardware Total:                                             $5,500
```

**Initial Setup Labor** (one-time)
```
Task                               Hours    Rate      Total
─────────────────────────────────────────────────────────
Production infrastructure          16       $50/hr    $800
Security review & hardening        12       $50/hr    $600
Master image creation              8        $50/hr    $400
Deployment automation              20       $50/hr    $1,000
Training materials                 8        $50/hr    $400
Pilot evaluation & refinement      10       $50/hr    $500
─────────────────────────────────────────────────────────
Setup Labor Total (74 hours):                          $3,700
```

**Ongoing Annual Labor** (Year 1)
```
Task                               Hours/Yr  Rate      Total
─────────────────────────────────────────────────────────
Routine monitoring (15 min/week)   13       $50/hr    $650
Incident response (avg 2/month)    48       $50/hr    $2,400
Quarterly updates (4×3 hrs)        12       $50/hr    $600
Annual secret rotation             4        $50/hr    $200
Device replacements (5 devices)    10       $50/hr    $500
─────────────────────────────────────────────────────────
Annual Labor Total (87 hours):                         $4,350

% of Full-Time Employee: 4.2% (87 of 2,080 hours)
Note: Designed for minimal ongoing burden
```

**Annual Software/Services**
```
Service                            Cost/Month  Months   Total
─────────────────────────────────────────────────────────
Management platform (optional)     $800        12       $9,600
Azure App Service (Basic tier)     $55         12       $660
Azure Key Vault                    $10         12       $120
Monitoring/alerting                $25         12       $300
─────────────────────────────────────────────────────────
Services Total:                                         $10,680
```

**Year 1 Summary**
```
Hardware                                                $5,500
Initial setup labor (74 hours)                          $3,700
Ongoing labor (87 hours, 4.2% FTE)                      $4,350
Software/services                                       $10,680
Contingency (10%)                                       $2,423
─────────────────────────────────────────────────────────────
Year 1 Total:                                           $26,653
Cost per store:                                         $267
```

#### Years 2-5 (Annual Recurring)

**Ongoing Labor** (steady state)
```
Task                               Hours/Yr  Rate      Total
─────────────────────────────────────────────────────────
Routine monitoring                 13       $50/hr    $650
Incident response                  40       $50/hr    $2,000
Quarterly updates                  12       $50/hr    $600
Annual secret rotation             4        $50/hr    $200
Device replacements                8        $50/hr    $400
─────────────────────────────────────────────────────────
Annual Labor (77 hours):                               $3,850

% of Full-Time Employee: 3.7% (77 of 2,080 hours)
```

**Annual Recurring Costs**
```
Software/services                                       $10,680
Ongoing labor (77 hours, 3.7% FTE)                      $3,850
Hardware replacements (5% failure)                      $300
─────────────────────────────────────────────────────────────
Annual Ongoing:                                         $14,830
Cost per store per year:                                $148
```

#### 5-Year Total Cost of Ownership

```
Year 1 (includes setup)                                 $26,653
Years 2-5 (4 × $14,830)                                 $59,320
─────────────────────────────────────────────────────────────
5-Year TCO:                                             $85,973
Average annual cost:                                    $17,195
Cost per store over 5 years:                            $860
```

---

### Value Proposition: Transform Existing Displays

BEACON's primary value is **repurposing existing display infrastructure** rather than purchasing new hardware. Most organizations already have:

- Unused monitors in storage
- TVs in break rooms showing cable news
- Conference room displays sitting idle outside meetings
- Retired desktop monitors from hardware refreshes

**The BEACON Advantage**: Turn these into self-managing, dedicated dashboard displays for $50-150 per screen.

---

### Cost Analysis: Display Infrastructure Approaches

#### Approach 1: BEACON Entry Tier (Pi Zero 2 W - Baseline)

**Best for**: Simple dashboards, tight budgets, basic visualization needs

```
Hardware Cost (per display):
├─ Raspberry Pi Zero 2 W           $15
├─ Power supply (5V 2.5A)          $8
├─ MicroSD card (32GB)             $7
├─ Case + mounting                 $10
├─ HDMI cable                      $8
├─ Existing monitor/TV             $0 (repurposed)
──────────────────────────────────────
Total per display:                 $48

100 displays (5-year TCO):         $85,973
Cost per display (5 years):        $860
```

**Capabilities**:
- Single Power BI report displays
- 60-second refresh rate
- 512MB RAM (suitable for simple dashboards)
- 2-minute boot time
- Excellent cost-performance ratio

---

#### Approach 2: BEACON Performance Tier (Pi 4 Model B)

**Best for**: Complex dashboards, multi-visual reports, higher reliability needs

```
Hardware Cost (per display):
├─ Raspberry Pi 4 (2GB)            $45
├─ Power supply (5V 3A)            $10
├─ MicroSD card (64GB, A2)         $12
├─ Case with heatsink              $15
├─ HDMI cable                      $8
├─ Existing monitor/TV             $0 (repurposed)
──────────────────────────────────────
Total per display:                 $90

100 displays (5-year TCO):         $74,000 (estimated)
Cost per display (5 years):        $740
```

**Capabilities**:
- Complex multi-visual dashboards
- 2GB RAM (4× more than Pi Zero 2 W)
- Faster rendering and refresh
- Better reliability (2% vs 5% failure rate)
- Dual-display support (2× HDMI ports)
- Lower support burden

---

#### Approach 3: BEACON Premium Tier (Pi 5 - Future Option)

**Best for**: Mission-critical displays, intensive dashboards, maximum performance

```
Hardware Cost (per display):
├─ Raspberry Pi 5 (4GB)            $60
├─ Power supply (5V 5A)            $12
├─ MicroSD card (64GB, A2)         $12
├─ Active cooling case             $20
├─ HDMI cable                      $8
├─ Existing monitor/TV             $0 (repurposed)
──────────────────────────────────────
Total per display:                 $112

100 displays (5-year TCO):         $65,000 (estimated)
Cost per display (5 years):        $650
```

**Capabilities**:
- 4GB RAM for complex workloads
- 2-3× CPU performance vs Pi 4
- PCIe support for storage upgrades
- Better graphics performance
- 10+ year device lifespan
- Lowest failure rate (<1% annually)

---

### Scaling Economics

The power of BEACON is in **leveraging existing displays** + **self-managing software** + **flexible hardware tiers**:

**100 Displays at Different Tiers**:
```
Configuration                      5-Year TCO    Per Display    Use Case
──────────────────────────────────────────────────────────────────────────
Entry (Pi Zero 2 W)               $85,973       $860           Simple dashboards
Mixed (60% Zero, 40% Pi 4)        $78,000       $780           Varied complexity
Performance (100% Pi 4)           $74,000       $740           Complex dashboards
Premium (100% Pi 5)               $65,000       $650           Mission-critical
```

**Key Insight**: Higher-tier hardware reduces long-term costs through:
- Lower failure rates (less replacement cost)
- Reduced support burden (fewer incidents)
- Longer device lifespan (7-10 years vs 5 years)
- Better user experience (faster, more reliable)

---

### Comparison: Traditional Approaches

**Alternative: Dedicated Display Solutions**:
```
Commercial digital signage        $150,000+     $1,500/screen (hardware + license)
Enterprise dashboard appliances   $200,000+     $2,000/device (NUC + commercial OS)
Desktop PCs (repurposed)          $120,000      $200/PC + higher power costs
────────────────────────────────────────────────────────────────────────

Savings (vs commercial):          $64,027+      74% cost reduction
Savings (vs desktop PCs):          $34,027+      40% cost reduction
```

#### Additional Benefits Beyond Cost

**Operational Benefits**:
- Lower device theft risk (less valuable hardware)
- No charging management needed (always-on)
- Simpler user experience (view-only, no navigation/training)
- Faster boot times in power outages (~2 min vs 5+ min tablets)
- Zero user interaction = no configuration drift
- Dedicated purpose prevents non-work usage

**Data Visibility Value**:
- Constant metrics visibility improves team awareness
- Real-time data enables faster decision-making
- Democratizes access to operational intelligence
- Reduces need for manual report distribution
- Encourages data-driven culture

**Food Safety Applicability** (for applicable environments):
- Touchless operation eliminates cross-contamination risk
- No cleaning protocols needed for interactive screens
- View-only design supports sanitation compliance

**Total Value Proposition**: Cost-neutral to significant savings + improved operational visibility + optional food safety benefits

---

## Cost Optimization Strategies

The baseline cost model above includes commercial management platforms and standard approaches. However, **significant savings are possible** through strategic optimization. Below are proven strategies to improve ROI.

### Optimization Opportunity Summary

```
Baseline 5-Year TCO (100 locations):                       $85,973
Optimized 5-Year TCO (same scale):                          $30,961
────────────────────────────────────────────────────────────────────
Total Savings:                                              $55,012 (64%)

vs Commercial Digital Signage ($150,000+):                  $119,027+ savings (79%)
vs Desktop PC Repurposing ($120,000):                       $89,039 savings (74%)
```

---

### Strategy 1: Eliminate Commercial Management Platform

**Current Cost**: $9,600/year × 5 years = $48,000

**Problem**: Commercial platforms (Yodeck, PiSignage) charge $5-10/device/month for features we can build ourselves.

**Alternative Approach**: Custom management dashboard
```
Components:
├─ Device inventory: Google Sheets or Airtable (free tier)
├─ Health monitoring: Grafana + InfluxDB (self-hosted, free)
├─ Remote updates: Ansible playbooks (free, open-source)
├─ Alerting: Email/Slack webhooks (free tier)
└─ Device logs: Centralized syslog (free)

One-time Implementation:
├─ Dashboard development: 40 hours × $50/hr = $2,000
├─ Ansible automation: 24 hours × $50/hr = $1,200
├─ Documentation: 8 hours × $50/hr = $400
────────────────────────────────────────────────────────────
Total investment: $3,600 (pays back in 4.5 months)

Ongoing hosting (self-hosted):
├─ VM or container (company infrastructure): $0-200/year
└─ Maintenance: 4 hours/year × $50/hr = $200/year
────────────────────────────────────────────────────────────
Annual cost: $200-400/year (vs $9,600)
```

**5-Year Savings**: $48,000 - $5,600 = **$42,400** (88% reduction)

**Recommendation**: Start with commercial platform for pilot (easy validation), transition to custom solution for production rollout.

---

### Strategy 2: Optimize Hosting Infrastructure

**Current Cost**: Azure App Service Basic ($660/year) + Key Vault ($120/year) + Monitoring ($300/year) = $1,080/year

**Alternative A: On-Premises VM** (if company has infrastructure)
```
Token service on existing company VM/server:
├─ VM allocation: Free (existing infrastructure)
├─ SSL certificate: Company PKI (free)
├─ Monitoring: Built into Strategy 1 ($0)
────────────────────────────────────────────────────────────
Annual cost: $0 (vs $1,080/year)
5-Year savings: $5,400
```

**Alternative B: Azure Container Instances** (if cloud required)
```
Container Instances (running 24/7):
├─ Small instance (0.5 vCPU, 1GB RAM): ~$15/month = $180/year
├─ Key Vault: $120/year
├─ Application Insights (free tier): $0
────────────────────────────────────────────────────────────
Annual cost: $300/year (vs $1,080/year)
5-Year savings: $3,900
```

**5-Year Savings**: **$3,900-5,400** depending on approach

---

### Strategy 3: Increase Automation to Reduce Labor

**Current Labor**: 87 hours/year (Year 1), 77 hours/year (Years 2-5)

**Automation Opportunities**:

```
Task                          Current    Automated    Savings
──────────────────────────────────────────────────────────────
Routine monitoring            13 hrs     2 hrs        11 hrs
  └─ Scripted health checks, automated alerts

Incident response             40-48 hrs  30-40 hrs    8-10 hrs
  └─ Self-healing watchdog, automated diagnostics

Quarterly updates             12 hrs     4 hrs        8 hrs
  └─ Ansible playbooks for mass updates

Device replacements           8-10 hrs   6-8 hrs      2 hrs
  └─ Automated config backup/restore

Annual secret rotation        4 hrs      2 hrs        2 hrs
  └─ Scripted rotation process
──────────────────────────────────────────────────────────────
Total annual hours:           77 hrs     44-52 hrs    25-33 hrs
Annual savings:                          $1,250-1,650
```

**Implementation Cost**: Included in Strategy 1 (Ansible automation: $1,200)

**5-Year Savings**: $5,000-6,600 in labor costs

---

### Strategy 4: Negotiate Bulk Hardware Pricing

**Current Cost**: 120 devices × $50 = $6,000

**Bulk Pricing Strategy**:
```
Component                     Retail    Bulk (100+)   Savings
──────────────────────────────────────────────────────────────
Raspberry Pi Zero 2 W         $15       $13           $2 ea
Power supply                  $8        $6            $2 ea
MicroSD card (32GB)           $7        $5            $2 ea
Case + mount                  $10       $8            $2 ea
HDMI cable                    $8        $6            $2 ea
──────────────────────────────────────────────────────────────
Total per device:             $48       $38           $10 ea

120 devices:                  $5,760    $4,560        $1,200
```

**Suppliers**: Negotiate with Adafruit, CanaKit, or direct from distributors like Newark/Digi-Key

**5-Year Savings**: **$1,200** (one-time, Year 1)

---

### Strategy 5: Reduce Hardware Failure Rate

**Current Cost**: 5% annual failure rate = 5 devices/year × $50 = $250/year

**Improvement Actions**:
```
Prevention Measures:
├─ Pre-deployment burn-in testing (72 hours per batch)
├─ Surge-protected power supplies (+$2/device, saves replacements)
├─ Better cooling in hot environments (passive heatsinks, $3/device)
├─ Quarterly preventive maintenance (remote health checks)
└─ Better quality SD cards (industrial-grade, +$3/device)

Additional cost: $5/device × 120 = $600 (one-time)
Failure rate reduction: 5% → 3% (2 fewer failures/year)
Annual savings: 2 devices × $50 = $100/year
ROI: Pays back in 6 years (marginal benefit)
```

**5-Year Savings**: $500 - $600 investment = **-$100** (not recommended for ROI, but improves reliability)

---

### Strategy 6: Hardware Tier Optimization

**Overview**: Choose the right hardware tier based on dashboard complexity and reliability requirements. Higher-tier hardware has higher upfront cost but lower TCO.

#### Hardware Tier Comparison

```
Tier          Device              Cost    RAM    Use Case                    TCO Impact
──────────────────────────────────────────────────────────────────────────────────────
Entry         Pi Zero 2 W         $48     512MB  Simple dashboards          Baseline
Performance   Pi 4 (2GB)          $90     2GB    Complex dashboards         -13% TCO
Performance   Pi 4 (4GB)          $110    4GB    Multi-visual reports       -18% TCO
Premium       Pi 5 (4GB)          $112    4GB    Mission-critical           -24% TCO
Premium       Pi 5 (8GB)          $132    8GB    Intensive workloads        -26% TCO
Alternative   Intel N100 NUC      $180    8GB    Maximum compatibility      -20% TCO*
Alternative   Orange Pi 5 Plus    $100    8GB    Budget premium option      -22% TCO
```

*NUC provides x86 compatibility but higher power consumption

#### Detailed Tier Analysis

**Entry Tier: Pi Zero 2 W ($48)**
```
Strengths:
├─ Lowest initial cost
├─ Minimal power consumption (3W)
├─ Smallest form factor (hidden easily)
└─ Sufficient for 70% of dashboard use cases

Limitations:
├─ 512MB RAM (simple dashboards only)
├─ Single-core performance
├─ 5% annual failure rate
└─ Higher support burden for complex reports

Best for:
├─ Single-metric displays
├─ Text-heavy reports
├─ Budget-constrained deployments
└─ Proof of concept validation
```

**Performance Tier: Pi 4 (2GB/4GB) ($90-110)**
```
Strengths:
├─ 4× RAM (2GB) or 8× RAM (4GB) vs Zero
├─ Quad-core Cortex-A72 (3× faster)
├─ Dual HDMI (can drive 2 displays)
├─ USB 3.0 for faster boot from SSD
├─ 2% annual failure rate
└─ Lower support burden

Capabilities:
├─ Multi-visual dashboards (10-15 visuals)
├─ Real-time data with complex DAX
├─ Map visualizations
├─ Custom visuals
└─ Faster refresh rates (30-second intervals)

TCO Savings (100 devices, 5 years):
├─ Hardware: +$4,200 upfront
├─ Labor savings: -$6,750 (reduced support)
├─ Replacement savings: -$1,500 (lower failure rate)
└─ Net savings: -$4,050 (5.4% reduction)
```

**Premium Tier: Pi 5 (4GB/8GB) ($112-132)**
```
Strengths:
├─ 2-3× CPU performance vs Pi 4
├─ PCIe 2.0 for NVMe SSD (10× faster storage)
├─ VideoCore VII GPU (better rendering)
├─ Active cooling (better thermal management)
├─ <1% annual failure rate
├─ 10+ year lifespan
└─ Minimal support burden

Capabilities:
├─ Complex dashboards (20+ visuals)
├─ 4K display support
├─ Sub-second refresh rates
├─ Multiple simultaneous reports
├─ Video content in dashboards
└─ Future-proof for evolving Power BI features

TCO Savings (100 devices, 5 years):
├─ Hardware: +$6,400 upfront
├─ Labor savings: -$13,500 (minimal support)
├─ Replacement savings: -$2,400 (lowest failure)
├─ Longevity value: +$5,000 (reusable beyond 5yr)
└─ Net savings: -$14,500 (16.9% reduction)

Recommendation: Use for mission-critical displays where downtime is costly
```

#### Alternative Hardware Options

**Intel N100 NUC ($180)**
```
Pros:
├─ x86 architecture (full browser compatibility)
├─ 8GB RAM standard
├─ NVMe SSD (fast, reliable storage)
├─ Intel UHD Graphics
├─ Fanless models available
└─ Can run Linux or Windows

Cons:
├─ Higher upfront cost
├─ Higher power consumption (6-15W)
├─ Larger form factor
└─ Overkill for most dashboards

Best for:
└─ Organizations with strict x86-only IT policies
```

**Orange Pi 5 Plus ($100)**
```
Pros:
├─ 8GB RAM (same as Pi 5 8GB)
├─ Rockchip RK3588 (8-core CPU)
├─ PCIe 3.0 support
├─ Lower cost than Pi 5 8GB
└─ Similar performance to Pi 5

Cons:
├─ Smaller community support
├─ Less mature software ecosystem
├─ Limited availability in some regions
└─ Fewer tested accessories

Best for:
└─ Experienced users comfortable with less mainstream hardware
```

#### Mixed-Tier Deployment Strategy

**Optimal Approach**: Deploy different tiers based on use case

```
Example 100-Device Deployment:
├─ 40% Entry (Pi Zero 2 W):        Simple KPI dashboards      $1,920
├─ 40% Performance (Pi 4 2GB):     Multi-visual reports       $3,600
├─ 15% Performance (Pi 4 4GB):     Complex dashboards         $1,650
└─ 5% Premium (Pi 5 4GB):          Mission-critical C-suite   $560
──────────────────────────────────────────────────────────────────────
Total hardware (100 devices):                                 $7,730
vs 100% Entry tier:                                          $4,800
Additional investment:                                        $2,930

5-Year TCO Savings (mixed vs all-entry):
├─ Reduced support costs:          -$4,500
├─ Lower replacement costs:        -$1,200
├─ Better user satisfaction:       Priceless
└─ Net benefit:                    -$2,770 (3.2% TCO reduction)
```

**Deployment Decision Matrix**:
```
Dashboard Complexity          Visual Count    RAM Need    Tier
─────────────────────────────────────────────────────────────────
Single metric/KPI             1-3 visuals     <500MB      Entry
Standard operational          4-8 visuals     500MB-1GB   Performance (2GB)
Multi-department dashboard    9-15 visuals    1-1.5GB     Performance (4GB)
Executive/analytical          16-25 visuals   1.5-2.5GB   Premium (4GB)
Real-time complex/video       25+ visuals     2.5GB+      Premium (8GB)
```

---

### Strategy 7: Software Enhancement Options

Beyond hardware, BEACON can be enhanced with software improvements for specific use cases:

#### Enhancement 1: Advanced Display Features

**Multi-Report Rotation** (Development: 8 hours)
```
Feature:
├─ Automatic rotation between multiple Power BI reports
├─ Configurable dwell time per report (30-300 seconds)
├─ Smooth transitions between reports
└─ Centrally managed rotation schedules

Implementation:
├─ Update display-client/js/powerbi-embed.js
├─ Add report rotation config to config.json
├─ Implement transition animations (optional)
└─ Add time-of-day conditional display (show different reports by shift)

Cost: $400 (8 hrs × $50/hr) one-time development
Value: Single display shows 3-5 reports, reducing hardware needs
ROI: Saves $150-200 per avoided display deployment
```

**Dashboard Interactivity** (Development: 16 hours)
```
Feature:
├─ Optional touchscreen support for drill-through
├─ Bookmark navigation (pre-configured views)
├─ Filter controls via wireless keyboard/remote
└─ QR code generation for mobile access

Use case: Conference rooms, executive areas
Note: Removes "touchless" benefit for food safety environments

Cost: $800 (16 hrs × $50/hr)
Value: Enhanced user engagement in appropriate settings
```

#### Enhancement 2: Extended Data Sources

**Multi-Platform Support** (Development: 24 hours)
```
Current: Power BI only
Extended support for:
├─ Tableau dashboards (via Tableau Server API)
├─ Grafana dashboards (open-source monitoring)
├─ Google Data Studio / Looker Studio
├─ Custom web applications
└─ RTSP video streams (IP cameras, production lines)

Implementation:
├─ Create source-agnostic display client
├─ Plugin architecture for different data sources
├─ Unified configuration schema
└─ Authentication abstraction layer

Cost: $1,200 (24 hrs × $50/hr)
Value: Broader use cases beyond Power BI
Example: Display security camera + KPI dashboard side-by-side
```

#### Enhancement 3: Advanced Monitoring & Management

**Predictive Maintenance** (Development: 20 hours)
```
Feature:
├─ Machine learning model to predict device failures
├─ Proactive replacement notifications
├─ Historical performance trending
└─ Capacity planning recommendations

Data collected:
├─ Memory usage patterns over time
├─ Temperature fluctuations
├─ Network latency and packet loss
├─ Power cycle frequency
└─ Software error rates

Cost: $1,000 (20 hrs × $50/hr) + $200/yr (cloud ML service)
Value: Reduce unplanned outages by 60-80%
ROI: Fewer emergency support calls, better user experience
```

**Centralized Content Management** (Development: 40 hours)
```
Feature:
├─ Web-based dashboard for all BEACON devices
├─ Drag-and-drop report assignment
├─ Bulk configuration updates
├─ Remote screenshot capture (what's on screen right now)
├─ Device grouping (by department, location, hardware tier)
└─ Scheduled content changes (rotate dashboards seasonally)

Technology:
├─ React/Next.js frontend
├─ Node.js backend API
├─ PostgreSQL database
└─ WebSocket for real-time updates

Cost: $2,000 (40 hrs × $50/hr) + $300/yr hosting
Value: Manage 500+ devices from single interface
Alternative: Use commercial platform ($9,600/yr) vs build ($2,000 + $300/yr)
ROI: Pays back in 2.5 months vs commercial solution
```

#### Enhancement 4: Security Hardening

**Zero Trust Network Access** (Development: 12 hours)
```
Feature:
├─ Mutual TLS authentication for all connections
├─ Certificate-based device identity
├─ Network traffic encryption (WireGuard VPN)
├─ Automatic certificate rotation
└─ Fail-secure mode (display error, not unauthorized content)

Use case: Highly regulated industries, classified environments

Cost: $600 (12 hrs × $50/hr) + PKI infrastructure (may already exist)
Value: Meets enterprise security compliance requirements
```

**Audit Logging & Compliance** (Development: 8 hours)
```
Feature:
├─ Detailed access logs (who viewed what, when)
├─ Content change audit trail
├─ Compliance reports (HIPAA, SOC2, ISO 27001)
├─ Integration with SIEM tools (Splunk, ELK)
└─ Tamper-evident log storage

Cost: $400 (8 hrs × $50/hr) + log storage ($100/yr for 100 devices)
Value: Required for healthcare, finance, government deployments
```

#### Enhancement 5: Specialized Use Cases

**Offline Mode** (Development: 16 hours)
```
Feature:
├─ Cache last successful dashboard state
├─ Display cached content when network unavailable
├─ "Stale data" indicator with age timestamp
├─ Auto-reconnect and update when network restored
└─ Local SQLite database for time-series caching

Use case: Remote locations with intermittent connectivity

Cost: $800 (16 hrs × $50/hr)
Value: Maintains value even during outages
Example: Remote warehouse, rural store locations
```

**High-Availability Mode** (Development: 20 hours)
```
Feature:
├─ Dual Pi deployment (primary + standby)
├─ Automatic failover (60-second detection)
├─ Shared configuration via network storage
├─ Health check coordination (heartbeat protocol)
└─ Auto-recovery when primary restored

Use case: Mission-critical displays (production lines, NOC)

Cost: $1,000 (20 hrs × $50/hr) + double hardware cost
Value: 99.9%+ uptime even with hardware failures
ROI: Worth it when 1 hour of downtime costs >$1,000
```

#### Software Enhancement ROI Summary

```
Enhancement                        Cost        Value                          Payback
──────────────────────────────────────────────────────────────────────────────────────
Multi-report rotation              $400        Reduce displays by 30%         1 display
Multi-platform support             $1,200      Expand to non-Power BI teams   5 displays
Centralized management (vs buy)    $2,000      Save $9,600/yr licensing       2.5 months
Predictive maintenance             $1,000      60% fewer outages              Year 2
Offline mode                       $800        Enable 20+ remote locations    Immediate
High-availability mode             $1,000      Prevent costly downtime        Case-by-case
──────────────────────────────────────────────────────────────────────────────────────

Total software investment (all):   $6,400
Potential value (100+ devices):    $20,000+ over 5 years
```

**Recommendation**: Start with baseline BEACON, add enhancements based on specific needs that emerge during pilot phase.

---

### Optimized Cost Model (100 Stores, 5 Years)

**Implementing Strategies 1-4** (eliminating commercial platform, optimizing hosting, automation, bulk pricing):

```
Year 1 Costs:
────────────────────────────────────────────────────────────
Hardware (bulk pricing)                                 $4,560
Initial setup labor (74 hours)                          $3,700
Custom management development (72 hours)                $3,600
Ongoing labor (87 hours, 4.2% FTE)                      $4,350
Azure/hosting (optimized)                               $300
Contingency (10%)                                       $1,651
────────────────────────────────────────────────────────────
Year 1 Total:                                           $18,161

Years 2-5 (Annual):
────────────────────────────────────────────────────────────
Ongoing labor (reduced to 50 hours, 2.4% FTE)           $2,500
Hosting (self-hosted or cheap cloud)                    $200
Hardware replacements (5%)                              $300
Custom platform maintenance (4 hrs)                     $200
────────────────────────────────────────────────────────────
Annual Ongoing:                                         $3,200

5-Year Optimized TCO:
────────────────────────────────────────────────────────────
Year 1:                                                 $18,161
Years 2-5 (4 × $3,200):                                 $12,800
────────────────────────────────────────────────────────────
Total:                                                  $30,961

Cost per store over 5 years:                           $310
```

**Note**: This optimized model requires in-house technical capability and willingness to build/maintain custom tooling.

---

### ROI Comparison: All Scenarios

```
Solution                           5-Year TCO    vs Baseline    Savings %
────────────────────────────────────────────────────────────────────────────
BEACON (baseline, commercial mgmt) $85,973       -              -
BEACON (semi-optimized)*           $56,173       -$29,800       34.7%
BEACON (fully optimized)**         $30,961       -$55,012       64.0%
Commercial Digital Signage         $150,000+     +$64,027+      -74.4%
Desktop PC Repurposing             $120,000+     +$34,027+      -39.6%

* Semi-optimized: Custom platform + automation, but keeps cloud hosting
** Fully optimized: All strategies implemented, on-prem hosting
```

**Scaling Economics** (200 locations, fully optimized):
```
Year 1:
├─ Hardware (bulk): 240 devices × $38 = $9,120
├─ Setup labor: 90 hours = $4,500
├─ Custom management: 80 hours = $4,000 (slightly more complex)
├─ Ongoing labor: 100 hours = $5,000
├─ Hosting: $300
────────────────────────────────────────────────────────────
Year 1: $23,920

Years 2-5 (annual):
├─ Labor: 60 hours = $3,000
├─ Hosting: $200
├─ Replacements: 10 devices = $500
────────────────────────────────────────────────────────────
Annual: $3,700

5-Year TCO: $38,720 ($194 per location)
vs Commercial Signage (200): $300,000+
Savings: $261,280+ (87.1%)
```

---

### Implementation Recommendation Matrix

**Choose your optimization level based on organizational capability:**

| Strategy | Easy | Med | Hard | Savings | Complexity |
|----------|------|-----|------|---------|------------|
| 1: Custom management platform | | | ✓ | $42,400 | Requires dev skills |
| 2: Optimized hosting | ✓ | | | $3,900-5,400 | IT infrastructure decision |
| 3: Automation | | ✓ | | $5,000-6,600 | Scripting/Ansible skills |
| 4: Bulk hardware pricing | ✓ | | | $1,200 | Negotiation only |
| 5: Reduce failures | ✓ | | | $500 | Process improvement |
| 6: Hardware upgrade (Pi 4) | ✓ | | | $4,230 | Buy decision |

**Recommended Approach for Maximum ROI**:
1. **Pilot**: Use commercial platform ($800 × 2 months = $160) for quick validation
2. **Production (Waves 1-2)**: Continue commercial platform while building custom tools
3. **Wave 3 onward**: Transition to custom platform (saves $9,400/year ongoing)
4. **Result**: Recoups custom development cost in 4.5 months, then pure savings

**Quick Win Path** (minimal technical investment):
- Implement Strategy 2 (hosting optimization) + Strategy 4 (bulk pricing)
- Total effort: 0 hours (just procurement decisions)
- 5-Year savings: $5,100-6,600
- New TCO: $79,373-80,873 (saves $5,100-6,600 vs baseline)

**Maximum ROI Path** (technical investment required):
- Implement all strategies except #5 (not cost-effective)
- Total effort: 72 hours setup + 4 hours/year maintenance
- 5-Year savings: $40,700+ (47% reduction)
- Break-even: Month 5 of operation
- Requires: Dev resources, Ansible expertise, company infrastructure

---

### Key Insight: The Management Platform is the Bottleneck

**Critical Finding**: The commercial management platform represents **56% of ongoing costs** ($9,600 of $17,195 annual average). Eliminating it through custom tooling has an **8-month payback period** and is the single highest-impact optimization.

**DIY Management Platform Components**:
```bash
# Example: Simple health monitoring system
# Cost: $0/year vs $9,600/year commercial solution

# 1. Device health check (runs on each Pi)
*/15 * * * * /home/pi/beacon/health-check.sh | \
  curl -X POST https://company.com/beacon/health -d @-

# 2. Central dashboard (Grafana + InfluxDB)
#    Self-hosted on company VM or $5/month DigitalOcean droplet

# 3. Bulk updates via Ansible
ansible-playbook -i inventory.yml update-all-displays.yml

# Total development time: 40-60 hours
# Annual maintenance: 4-8 hours
```

This simple stack provides 80% of commercial platform features at 2% of the cost.

## Rollout Timeline

### Overview
**Total Duration**: 28 weeks (~7 months) from initial approval to full deployment
**Approach**: Phased rollout with validation gates
**Risk Mitigation**: Pilot before scaling, geographic diversity in waves

---

### Phase 1: Foundation & Approval (Weeks 1-5)

**Week 1: Stakeholder Alignment**
```
Activities:
├─ Present POC demonstration to leadership
├─ Share business case and cost analysis
├─ Identify pilot store candidates
├─ Secure budget approval
└─ Establish steering committee

Deliverables:
├─ Approved project charter
├─ Budget allocation ($3,000 pilot + $27,000 production)
└─ Stakeholder RACI matrix

Labor: 12 hours ($600)
```

**Week 2-3: Requirements & Architecture**
```
Activities:
├─ Meet with Azure AD team (service principal request)
├─ Meet with Network team (VLAN requirements)
├─ Meet with InfoSec team (security review initiation)
├─ Meet with Power BI admin (workspace access)
├─ Document technical requirements
├─ Select token service hosting platform
└─ Finalize pilot store selection (10 stores)

Deliverables:
├─ Infrastructure requirements document
├─ Network architecture diagram
├─ Security assessment initiated
└─ Pilot store list with logistics

Labor: 24 hours ($1,200)
```

**Week 4-5: Infrastructure Deployment**
```
Activities:
├─ Azure AD service principal created
├─ Power BI workspace access granted
├─ Token service deployed (Azure App Service or VM)
├─ Network VLAN configured
├─ Firewall rules implemented
├─ Monitoring dashboard set up
└─ Test environment validated

Deliverables:
├─ Production token service (HTTPS endpoint)
├─ Network connectivity validated
├─ Security controls implemented
└─ Runbook documentation

Labor: 32 hours ($1,600)
```

**Gate 1**: Infrastructure validation complete, security review passed

---

### Phase 2: Pilot Program (Weeks 6-13)

**Week 6: Pilot Preparation**
```
Activities:
├─ Provision and configure 12 devices (10 + 2 spares)
├─ Create master device image
├─ Test all devices in lab environment
├─ Prepare installation kits (instructions, cables, mounts)
├─ Train pilot store managers (remote session)
└─ Schedule installation windows

Deliverables:
├─ 12 configured devices ready to ship
├─ Installation guide (with photos)
├─ Store manager quick reference card
└─ Troubleshooting checklist

Labor: 16 hours ($800)
```

**Week 7: Pilot Deployment**
```
Day 1: Ship devices to 10 stores (expedited)
Day 2: Devices arrive, IT support on standby
Day 3-4: Store staff install devices (15-30 min each)
Day 5: All devices online, initial monitoring

Support model:
├─ Dedicated Slack channel for pilot stores
├─ IT support on-call during business hours
└─ Daily health checks

Labor: 16 hours ($800)
```

**Weeks 8-11: Monitoring & Refinement**
```
Weekly Activities:
├─ Monitor device health (uptime, memory, errors)
├─ Track support tickets and resolution times
├─ Gather store manager feedback (survey + interviews)
├─ Address any technical issues
├─ Refine deployment process based on learnings
└─ Update documentation

Metrics Tracked:
├─ Uptime percentage (target: >98%)
├─ Boot time (target: <2 min)
├─ Support tickets per device (target: <2)
├─ User satisfaction score (target: 8/10)
└─ Security incidents (target: 0)

Labor: 10 hours/week × 4 weeks = 40 hours ($2,000)
```

**Week 12-13: Pilot Evaluation**
```
Activities:
├─ Compile pilot metrics and feedback
├─ Document lessons learned
├─ Update deployment procedures
├─ Refine cost estimates based on actuals
├─ Present pilot results to steering committee
├─ Get go/no-go decision for production rollout
└─ Plan production wave logistics

Deliverables:
├─ Pilot evaluation report
├─ Updated deployment playbook
├─ Production rollout plan
└─ Go-live approval

Labor: 16 hours ($800)
```

**Gate 2**: Pilot success criteria met, production rollout approved

---

### Phase 3: Production Rollout (Weeks 14-27)

**Strategy**: Deploy in 3 waves with geographic diversity and network variety
- Mix of high/medium/low volume stores
- Mix of network configurations
- Validate at each wave before proceeding

**Week 14: Wave 1 Preparation (30 stores)**
```
Activities:
├─ Provision 30 devices + 6 spares
├─ Update master image with pilot improvements
├─ Create wave-specific config files
├─ Coordinate with store managers
└─ Schedule installations (staggered over 2 weeks)

Labor: 20 hours ($1,000)
```

**Weeks 15-16: Wave 1 Deployment**
```
Week 15: Deploy to 15 stores
Week 16: Deploy to 15 stores

Daily activities:
├─ Ship devices in batches
├─ Monitor installations
├─ Provide remote support
└─ Track metrics

Labor: 12 hours/week × 2 weeks = 24 hours ($1,200)
```

**Week 17: Wave 1 Stabilization**
```
Activities:
├─ Address any issues from Wave 1
├─ Validate success metrics
├─ Refine process for Wave 2
└─ Prepare Wave 2 devices

Labor: 8 hours ($400)
```

**Gate 3**: Wave 1 validated (>95% uptime, minimal issues)

**Weeks 18-21: Wave 2 Deployment (40 stores)**
```
Week 18: Preparation (provision 40 devices + 8 spares)
Week 19-20: Deploy 20 stores per week
Week 21: Stabilization and validation

Labor: 52 hours ($2,600)
```

**Gate 4**: Wave 2 validated

**Weeks 22-25: Wave 3 Deployment (30 stores)**
```
Week 22: Preparation (provision 30 devices + 6 spares)
Week 23-24: Deploy 15 stores per week
Week 25: Stabilization and validation

Labor: 44 hours ($2,200)
```

**Gate 5**: Wave 3 validated, all 100 stores online

**Weeks 26-27: Final Validation & Handoff**
```
Activities:
├─ Fleet-wide health check (all 100 devices)
├─ Validate monitoring and alerting
├─ Complete documentation
├─ Train Tier 2 support team
├─ Transition to steady-state operations
├─ Final project report
└─ Lessons learned session

Deliverables:
├─ Production operations runbook
├─ Support team training complete
├─ Device inventory database
├─ Project closeout report
└─ Knowledge base articles

Labor: 16 hours ($800)
```

**Week 28+**: Steady-state operations (ongoing support model)

---

### Rollout Wave Details

#### Wave 1: Initial Production (30 stores)
```
Stores: Mix of 10 regions, varied network complexity
Purpose: Validate production process at moderate scale
Duration: 3 weeks (prep + deploy + stabilize)
Success criteria:
├─ >95% successful installations
├─ <5 support tickets per device
├─ Deployment time <20 min per store
└─ No security incidents
```

#### Wave 2: Scale Validation (40 stores)
```
Stores: Broader geographic coverage, higher volume locations
Purpose: Test support model under increased load
Duration: 4 weeks
Success criteria:
├─ >97% uptime across Waves 1+2
├─ Support response time <2 hours
├─ No infrastructure bottlenecks
└─ Process improvements documented
```

#### Wave 3: Completion (30 stores)
```
Stores: Remaining locations, including any edge cases
Purpose: Complete fleet deployment
Duration: 4 weeks
Success criteria:
├─ 100 stores fully operational
├─ Support team fully trained
├─ All documentation complete
└─ Transition to BAU operations
```

---

### Critical Path & Dependencies

```
Critical Path Items:
├─ Azure AD service principal (Week 2-3) → Blocks token service
├─ Network VLAN deployment (Week 4) → Blocks device connectivity
├─ Token service deployment (Week 5) → Blocks pilot
├─ Pilot success (Week 13) → Blocks production rollout
└─ Wave 1 success (Week 17) → Validates production process

Parallel Tracks:
├─ Security review (Weeks 2-5, ongoing monitoring)
├─ Documentation (ongoing, finalized Week 27)
└─ Training materials (created Week 6, updated as needed)
```

---

### Resource Summary

```
Phase                          Duration    Labor Hours    Cost
──────────────────────────────────────────────────────────────
Phase 1: Foundation            5 weeks     68 hours       $3,400
Phase 2: Pilot                 8 weeks     88 hours       $4,400
Phase 3: Production rollout    14 weeks    164 hours      $8,200
──────────────────────────────────────────────────────────────
Total Project:                 27 weeks    320 hours      $16,000

Post-deployment (Year 1):      ongoing     87 hours       $4,350
Steady state (Years 2-5):      annual      77 hours       $3,850
```

**Key Personnel**:
- Project lead: 0.15 FTE during rollout (320 hours over 27 weeks)
- IT infrastructure engineer: 0.1 FTE (network, Azure config)
- Support team: 0.05 FTE during rollout, <0.04 FTE steady state

---

### Risk Management

**High-Risk Items**:
1. **Network delays**: VLAN provisioning can take 4-6 weeks in large organizations
   - *Mitigation*: Engage network team in Week 1, allow 5 weeks buffer

2. **Security review delays**: InfoSec reviews can extend timeline
   - *Mitigation*: Start security engagement Week 2, parallel track

3. **Azure AD approval**: Service principal requests may have approval workflows
   - *Mitigation*: Submit request with executive sponsor, escalation path

4. **Pilot failures**: Technical issues could delay production rollout
   - *Mitigation*: 2-week buffer between pilot end and Wave 1 start

**Contingency Planning**:
- Add 20% time buffer to critical path items
- Maintain spare device inventory (20%)
- Have backup token service deployment option
- Document rollback procedures

## Support Model

### Tier 1: Store Staff
- **Responsibility**: Power cycle device if not working
- **Training**: 5-minute quick reference guide
- **Escalation**: IT help desk

### Tier 2: IT Help Desk
- **Responsibility**: Remote diagnostics, config updates, device replacement, basic troubleshooting
- **Tools**: Device dashboard, SSH access, management scripts, runbook
- **Escalation**: BEACON development team

### Tier 3: BEACON Team
- **Responsibility**: Token service issues, complex troubleshooting, infrastructure problems, updates
- **Availability**: Business hours (displays self-heal overnight)

## Next Steps After POC

1. **Present to Stakeholders** (Week 1)
   - Show working prototype
   - Present cost analysis
   - Request pilot approval

2. **Engage IT Teams** (Week 2-3)
   - Azure AD team (service principal)
   - Network team (VLAN, firewall)
   - Security team (review)
   - Power BI team (workspace access)

3. **Plan Pilot** (Week 4)
   - Select 10 pilot stores
   - Refine deployment process
   - Set success criteria

4. **Execute Pilot** (Week 5-12)
   - Deploy and monitor
   - Gather feedback
   - Refine for production

5. **Production Rollout** (Week 13-24)
   - Phased deployment
   - Ongoing support

---

**Audience**: IT stakeholders and deployment team
**Purpose**: Bridge POC to enterprise deployment
**Status**: Ready for pilot planning

See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details and [PROJECT-DEFINITION.md](PROJECT-DEFINITION.md) for business case.
