# Deployment Planning Guide

**Audience**: For IT infrastructure teams and project managers preparing for enterprise deployment

## Prerequisites

### Infrastructure Requirements

#### Network Requirements

For detailed network security requirements, firewall rules, and configuration templates, see **[SECURITY.md](../../SECURITY.md) > Network Security**.

Summary:
- Dedicated IoT VLAN with network segmentation
- 802.1X authentication or WPA2-Enterprise
- DHCP with MAC reservations
- Explicit firewall rules (required outbound/inbound access documented in SECURITY.md)
- SSH access from Management VLAN only

#### Required Outbound Access

All BEACON devices require outbound HTTPS access to:
- `login.microsoftonline.com:443` (Azure AD authentication)
- `api.powerbi.com:443` (Power BI API)
- `app.powerbi.com:443` (Power BI content)
- `cdn.jsdelivr.net:443` (Power BI JavaScript library)

#### Azure AD Configuration

For detailed Azure AD security configuration, see **[SECURITY.md](../../SECURITY.md) > Authentication & Authorization**.

Key requirements:
- Service principal with read-only permissions
- Report.Read.All (Application permission)
- Workspace-scoped access (not tenant-wide)
- Client secret with 12-month rotation
- Azure Key Vault for production secret storage

#### Power BI Configuration

Key requirements:
- Service principal as workspace Member (minimum required)
- Read-only access to required reports
- Row-level security filters (if multi-tenant)
- Hourly token expiry with automatic renewal

### Team Roles & Responsibilities

| Role | Responsibilities | Time Commitment |
|------|------------------|-----------------|
| **Project Lead** | Overall coordination, stakeholder management | 0.15 FTE (rollout), 0.04 FTE (steady state) |
| **IT Infrastructure Engineer** | Network VLAN, firewall rules, token service deployment | 0.1 FTE (setup), minimal ongoing |
| **Azure AD Admin** | Service principal creation, permissions | 4 hours (setup), 4 hours/year (rotation) |
| **Power BI Admin** | Workspace access, report permissions | 2 hours (setup), minimal ongoing |
| **Security Analyst** | Security review, compliance validation | 12 hours (initial review), annual audits |
| **Support Team (Tier 2)** | Device troubleshooting, config updates | 0.05 FTE (rollout), 0.04 FTE (steady state) |

### Budget Approval

**POC**: <$100 (personal/prototype)
**Pilot** (10 stores): $3,000-4,000
**Production** (100 stores): See [Cost Analysis](cost-analysis.md)

Secure executive approval for:
- Initial hardware investment ($5,000-11,000)
- Year 1 setup labor ($3,700-8,200)
- Ongoing annual costs ($3,200-16,600/year)

## Timeline & Critical Path

### Overall Timeline
**Total Duration**: 28 weeks (~7 months) from approval to full deployment

### Critical Path Items

```
Critical Path:
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

## Infrastructure Deployment Options

### Token Service Deployment

#### Option A: Company VM/Server

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

**Pros**: Free infrastructure, company PKI certificates
**Cons**: Requires VM allocation, internal IT coordination

#### Option B: Azure App Service

```bash
# Deploy to Azure
az webapp up \
  --name beacon-token-service \
  --resource-group beacon-rg \
  --runtime "NODE|18-lts"

# Configure environment variables in Azure Portal
# Add: TENANT_ID, CLIENT_ID, CLIENT_SECRET (from Key Vault)
```

**Pros**: Managed service, auto-scaling, built-in HTTPS
**Cons**: $660/year cost (Basic tier)

#### Option C: Docker Container

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

**Pros**: Portable, can run on-prem or cloud
**Cons**: Requires container orchestration

### Deployment Checklist

- [ ] Choose platform (VM, App Service, Container)
- [ ] Request infrastructure from IT
- [ ] Deploy cloud-version code (includes health endpoints)
- [ ] Configure environment variables in Key Vault
- [ ] Set up HTTPS with company certificate
- [ ] Configure internal DNS (e.g., beacon-token.company.com)
- [ ] Test from corporate network
- [ ] Document in company wiki/runbook

## Device Management Strategy

### Management Options

**Option A: Commercial Platform**
- Tools: Yodeck, PiSignage ($8/device/month)
- Pros: Web dashboard, remote config, health monitoring
- Cons: $9,600/year for 100 devices

**Option B: Custom Scripts**
- Tools: Ansible/Salt, SSH automation
- Pros: No recurring cost, full control
- Cons: $3,600 development time

**Option C: Hybrid** (Recommended)
- Core management: Custom scripts
- Monitoring: Commercial platform or custom dashboard
- Decision: Start with commercial for pilot, build custom for production

See [Cost Analysis](cost-analysis.md) > Strategy 1 for detailed ROI comparison.

### Device Inventory Tracking

```csv
DeviceID,StoreID,Location,MACAddress,IPAddress,InstallDate,LastSeen,Status
beacon-001,001,Backroom,b8:27:eb:xx:xx:xx,10.50.1.10,2025-01-15,2025-01-20,Online
beacon-002,002,Backroom,b8:27:eb:xx:xx:xx,10.50.1.11,2025-01-15,2025-01-20,Online
```

**Tools**: Google Sheets (free), Airtable (free tier), or custom database

### Health Monitoring Alerts

```
Alert Conditions:
├─ Device offline >30 min → Email IT support
├─ Memory usage >85% → Warning (watchdog restarts)
├─ Temperature >60°C → Warning
├─ Service crashed → Auto-restart + alert
└─ Token service unreachable → Alert
```

**Implementation**: Grafana + InfluxDB (free, self-hosted) or commercial platform

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
- [ ] Food safety requirements validated (if applicable)
- [ ] Audit logging enabled
- [ ] Data classification appropriate
- [ ] Privacy impact assessment (if needed)

## Risk Management

### High-Risk Items

1. **Network delays**: VLAN provisioning can take 4-6 weeks in large organizations
   - *Mitigation*: Engage network team in Week 1, allow 5 weeks buffer

2. **Security review delays**: InfoSec reviews can extend timeline
   - *Mitigation*: Start security engagement Week 2, parallel track

3. **Azure AD approval**: Service principal requests may have approval workflows
   - *Mitigation*: Submit request with executive sponsor, escalation path

4. **Pilot failures**: Technical issues could delay production rollout
   - *Mitigation*: 2-week buffer between pilot end and Wave 1 start

### Contingency Planning

- Add 20% time buffer to critical path items
- Maintain spare device inventory (20%)
- Have backup token service deployment option
- Document rollback procedures

## Next Steps

### Week 1: Stakeholder Alignment
- Present POC demonstration to leadership
- Share business case and cost analysis
- Identify pilot store candidates
- Secure budget approval
- Establish steering committee

### Week 2-3: Requirements & Architecture
- Meet with Azure AD team (service principal request)
- Meet with Network team (VLAN requirements)
- Meet with InfoSec team (security review initiation)
- Meet with Power BI admin (workspace access)
- Document technical requirements
- Select token service hosting platform
- Finalize pilot store selection (10 stores)

### Week 4-5: Infrastructure Deployment
- Azure AD service principal created
- Power BI workspace access granted
- Token service deployed (Azure App Service or VM)
- Network VLAN configured
- Firewall rules implemented
- Monitoring dashboard set up
- Test environment validated

## Related Documentation

- [Deployment Overview](README.md) - Phase progression and decision gates
- [Pilot Program](pilot.md) - 10-50 device pilot procedures
- [Production Rollout](production.md) - 100+ device deployment strategy
- [Cost Analysis](cost-analysis.md) - TCO models and optimization strategies
- [Operations Guide](operations.md) - Support structure and maintenance
- [SECURITY.md](../../SECURITY.md) - Detailed security requirements
