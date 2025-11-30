# Operations & Maintenance Guide

**Audience**: For IT support teams managing deployed BEACON devices in production

## Support Model

### Tier 1: Store Staff

**Responsibility**: Power cycle device if not working

**Training**: 5-minute quick reference guide

**Actions**:
- Verify monitor is powered on
- Check HDMI cable connections
- Power cycle Raspberry Pi (unplug/replug power)
- Wait 2 minutes for boot

**Escalation**: IT help desk (Slack or ticketing system)

**Expected Resolution**: 80% of issues resolved by power cycle

---

### Tier 2: IT Help Desk

**Responsibility**: Remote diagnostics, config updates, device replacement, basic troubleshooting

**Tools**:
- Device management dashboard
- SSH access to devices
- Management scripts (update, restart, diagnostics)
- Support runbook

**Common Tasks**:
- Remote service restart
- Configuration updates (new report, filters)
- Log review and diagnostics
- Spare device shipment coordination

**Escalation**: BEACON development team (Tier 3)

**Availability**: Business hours (displays self-heal overnight)

**Expected Resolution**: 90% of escalated issues resolved within 2 hours

---

### Tier 3: BEACON Team

**Responsibility**: Token service issues, complex troubleshooting, infrastructure problems, updates

**Tools**: Full access to all systems (Azure, token service, device fleet)

**Common Tasks**:
- Token service debugging
- Azure AD/Power BI permission issues
- Infrastructure changes
- Security incident response
- Software updates and patches

**Availability**: Business hours (on-call for critical issues)

**Expected Resolution**: 95% of issues resolved within 24 hours

---

## Monitoring & Alerting

### Health Monitoring Alerts

```
Alert Conditions:
├─ Device offline >30 min → Email IT support
├─ Memory usage >85% → Warning (watchdog restarts)
├─ Temperature >60°C → Warning
├─ Service crashed → Auto-restart + alert
└─ Token service unreachable → Alert
```

### Real-Time Dashboard Metrics

**Device Health**:
- Online/offline status
- Last seen timestamp
- Uptime percentage (24h, 7d, 30d)
- Current memory usage
- Current temperature
- Service status

**Fleet-Wide Metrics**:
- Total devices online/offline/degraded
- Fleet uptime percentage
- Support ticket volume (trending)
- Failed deployments (pending attention)
- Token service health

**Trending & Analytics**:
- Uptime trends (improving/degrading)
- Common failure patterns
- Support ticket categorization
- Hardware failure rates by tier
- Network connectivity issues by location

### Daily Health Report

**Automated Email** (8 AM daily):
```
BEACON Fleet Status - [Date]

Fleet Health:
├─ 98/100 devices online (98% uptime)
├─ 2 devices offline (beacon-042, beacon-089)
├─ 0 devices degraded
└─ Token service: Healthy

Support Activity (last 24 hours):
├─ 1 new ticket (beacon-042: network connectivity)
├─ 3 tickets resolved
└─ 0 tickets escalated to Tier 3

Action Required:
├─ beacon-042: Store reports no network, check VLAN
└─ beacon-089: Hardware failure suspected, spare shipped

Trend: ↑ Uptime improved 1.2% vs. last week
```

---

## Device Lifecycle Management

### Device Provisioning

**Process**:
1. Flash master image to microSD card
2. Configure device-specific settings (DeviceID, storeId)
3. Register MAC address for DHCP reservation
4. Label device with DeviceID sticker
5. Pack installation kit
6. Ship to store

**Labor**: 20 minutes per device (can batch 10-20 at once)

**Tools**:
- SD card imaging station (5-10 cards simultaneously)
- Label printer for DeviceID stickers
- Provisioning checklist

---

### Device Updates

**Software Updates** (quarterly):

**Process**:
1. Test update on 3 pilot devices
2. Validate functionality (48 hours)
3. Deploy to Wave 1 stores (30 devices)
4. Monitor for 24 hours
5. Deploy to Waves 2-3 if successful
6. Schedule maintenance window (after-hours recommended)

**Ansible Playbook**:
```bash
# Update all devices to new report
ansible-playbook -i inventory.yml update-display-client.yml

# Update specific wave
ansible-playbook -i inventory.yml update-display-client.yml --limit wave1
```

**Configuration Changes** (as needed):
```bash
# Update single device
./scripts/update-display.sh 192.168.1.100 new-report-id store-001

# Update all devices to new report
./scripts/update-all-displays.sh new-report-id
```

**Rollback Procedure**:
- Keep previous version for 30 days
- Rollback script available: `ansible-playbook rollback.yml`
- Test rollback procedure quarterly

---

### Hardware Replacements

**Failure Modes**:
- Device won't boot (SD card corruption, power supply failure)
- Frequent crashes (overheating, hardware defect)
- Network connectivity issues (WiFi chip failure)
- Display issues (HDMI port failure)

**Replacement Process**:
1. IT confirms hardware failure (remote diagnostics)
2. Ship spare device to store (overnight if critical)
3. Store swaps device (plug-and-play, 5 minutes)
4. Failed device returned to IT for diagnosis/repair
5. Update device inventory (failed device removed, spare activated)

**Spare Device Pool**:
- 20% of fleet (20 devices for 100-device deployment)
- Central IT warehouse (15 spares)
- Regional hubs (5 spares distributed)

**Annual Replacement Rate**:
- Pi Zero 2 W: 5% (5 devices/year per 100)
- Pi 4: 2% (2 devices/year per 100)
- Pi 5: <1% (1 device/year per 100)

---

### Device Decommissioning

**Process**:
1. Remove device from inventory tracking
2. Delete device entry from monitoring dashboard
3. Revoke network access (remove DHCP reservation)
4. Wipe SD card (secure erase)
5. Salvage usable components (case, power supply)
6. Recycle/dispose per company e-waste policy

**Data Security**:
- No sensitive data stored on devices (config only)
- Wipe SD card before disposal: `sudo shred -vfz -n 10 /dev/mmcblk0`
- Document disposal in asset management system

---

## Maintenance Procedures

### Routine Monitoring (15 min/week)

**Weekly Checklist**:
- [ ] Review health dashboard (fleet status)
- [ ] Check alert queue (any unresolved?)
- [ ] Review support tickets (trending issues?)
- [ ] Verify token service health
- [ ] Check spare device inventory (restock if <15)

**Labor**: 13 hours/year (15 min × 52 weeks)

---

### Quarterly Maintenance (3 hours/quarter)

**Quarterly Checklist**:
- [ ] Software updates (test + deploy)
- [ ] Review uptime metrics (trending?)
- [ ] Audit device inventory (discrepancies?)
- [ ] Test spare devices (boot, connectivity)
- [ ] Review support procedures (updates needed?)
- [ ] Security patch review (Azure, OS)
- [ ] Backup configuration files

**Labor**: 12 hours/year (4 quarters)

---

### Annual Maintenance (4 hours/year)

**Annual Checklist**:
- [ ] Rotate Azure client secret (12-month expiry)
- [ ] Security review (InfoSec team)
- [ ] Renew SSL certificates (token service)
- [ ] Review cost model (actuals vs. projected)
- [ ] Update documentation (runbooks, procedures)
- [ ] Backup master image (test restore)
- [ ] Disaster recovery test (token service failover)
- [ ] Vendor contract renewals (if applicable)

**Labor**: 4 hours/year

---

### Azure Client Secret Rotation

**Frequency**: Annual (12-month expiry)

**Process**:
1. Create new client secret in Azure Portal (1 year validity)
2. Update token service environment:
   - POC: Update `.env` file with new secret
   - Production: Update Azure Key Vault secret
3. Restart token service (zero-downtime if load-balanced)
4. Test token generation: `curl https://beacon-token.company.com/api/embed-token`
5. Verify all devices can fetch tokens (check logs)
6. Delete old client secret after 48 hours (grace period)
7. Document rotation in change log

**Labor**: 4 hours (includes testing and validation)

**Automation Opportunity**: Script secret rotation process (reduce to 2 hours)

---

## Service Level Agreements (SLAs)

### Target SLAs

**Device Availability**: 98% uptime (7.3 hours downtime/month allowable)

**Support Response Times**:
- Tier 1 (Store staff): Immediate (power cycle)
- Tier 2 (IT help desk): 2 hours during business hours
- Tier 3 (BEACON team): 4 hours for critical, 24 hours for standard

**Incident Resolution**:
- Critical (token service down, fleet-wide outage): 4 hours
- High (10+ devices offline): 8 hours
- Medium (1-5 devices offline): 24 hours
- Low (single device, cosmetic issue): 48 hours

**Planned Maintenance Windows**:
- Quarterly updates: After-hours (8 PM - 6 AM)
- Annual secret rotation: Saturday 10 AM - 2 PM
- Maximum downtime per maintenance: 30 minutes

---

### SLA Reporting

**Monthly Report** (emailed to stakeholders):
```
BEACON SLA Report - [Month, Year]

Availability:
├─ Fleet uptime: 98.7% (target: 98%)
├─ Token service uptime: 99.9% (target: 99%)
└─ Total device-hours offline: 127 of 73,000 (0.17%)

Support Performance:
├─ Avg response time (Tier 2): 1.4 hours (target: 2 hours)
├─ Avg resolution time: 3.2 hours (target: 4 hours)
├─ Tickets resolved: 12 of 14 (86% closure rate)
└─ Escalations to Tier 3: 2 (14%)

Incidents:
├─ Critical: 0
├─ High: 1 (network VLAN outage, 2 hours)
├─ Medium: 8 (device replacements)
└─ Low: 3 (display configuration tweaks)

Maintenance:
├─ Planned outage: 1 (quarterly update, 22 minutes)
├─ Unplanned outage: 1 (Azure AD issue, 47 minutes)
└─ SLA compliance: 98.7% (above target)

Trends: ↑ Uptime improved 0.5% vs. last month
```

---

## Device Inventory Management

### Tracking System

**Inventory Fields**:
```csv
DeviceID,StoreID,Location,HardwareTier,MACAddress,IPAddress,InstallDate,LastSeen,Status,Notes
beacon-001,001,Backroom,Entry,b8:27:eb:xx:xx:xx,10.50.1.10,2025-01-15,2025-01-20,Online,
beacon-002,002,Backroom,Performance,b8:27:eb:xx:xx:xx,10.50.1.11,2025-01-15,2025-01-20,Online,
beacon-003,003,Backroom,Entry,b8:27:eb:xx:xx:xx,10.50.1.12,2025-01-16,2025-01-20,Offline,Network issue
```

**Status Values**:
- Online: Device healthy, communicating
- Offline: Device unreachable >30 minutes
- Degraded: Device online but experiencing issues (high memory, high temp)
- Maintenance: Planned outage or update in progress
- Decommissioned: Removed from service

**Tools**:
- Google Sheets (free, collaborative)
- Airtable (free tier, better filtering/views)
- Custom database (PostgreSQL + web UI)

---

### Inventory Audits

**Monthly Audit** (automated):
- Compare inventory database to monitoring dashboard
- Identify discrepancies (missing devices, orphaned entries)
- Update status for devices offline >7 days
- Flag devices requiring replacement

**Quarterly Audit** (manual):
- Physical verification (sample 10% of fleet)
- Review spare device inventory
- Update hardware tier distribution
- Validate network configuration (DHCP, VLAN)

---

## Disaster Recovery

### Token Service Failure

**Symptom**: All devices unable to fetch embed tokens

**Impact**: Dashboards stop refreshing after 1 hour (token expiry)

**Recovery Process**:
1. Check token service health endpoint: `curl https://beacon-token.company.com/health`
2. Review token service logs (Azure App Service or VM)
3. Common causes:
   - Azure AD service principal expired credentials
   - Network connectivity to Azure
   - Token service crash/restart
4. Remediation:
   - Restart token service
   - Rotate client secret if expired
   - Validate Azure AD permissions
5. Validate recovery: Test token generation
6. Monitor device logs (should resume refreshing)

**Target Recovery Time**: 30 minutes

---

### Network Outage

**Symptom**: All devices in a location offline

**Impact**: Dashboards display stale data until network restored

**Recovery Process**:
1. Identify scope (single store, region, entire fleet?)
2. Check network VLAN health
3. Verify firewall rules (outbound HTTPS access)
4. Coordinate with network team
5. Devices auto-reconnect when network restored
6. Verify token refresh resumes

**Target Recovery Time**: Depends on network team SLA (typically 2-4 hours)

---

### Azure AD Outage

**Symptom**: Token service cannot authenticate with Azure AD

**Impact**: New tokens cannot be generated (existing tokens valid for 1 hour)

**Recovery Process**:
1. Check Azure AD service health: https://status.azure.com
2. If Azure-wide outage, wait for Microsoft resolution
3. Communicate to stakeholders (known Azure issue)
4. Devices will resume once Azure AD restored
5. No action required (auto-recovery)

**Target Recovery Time**: Depends on Azure SLA (Microsoft responsibility)

---

### Power BI Service Outage

**Symptom**: Devices online but dashboards show errors

**Impact**: Data visualization unavailable

**Recovery Process**:
1. Check Power BI service health: https://status.powerbi.com
2. If Power BI-wide outage, wait for Microsoft resolution
3. Communicate to stakeholders (known Power BI issue)
4. Devices will resume once Power BI restored
5. No action required (auto-recovery)

**Target Recovery Time**: Depends on Power BI SLA (Microsoft responsibility)

---

### Fleet-Wide Device Failure

**Symptom**: Multiple devices offline across different locations

**Impact**: Widespread dashboard outages

**Recovery Process**:
1. Identify common factor (software update, config change, infrastructure)
2. Rollback recent changes if applicable
3. SSH to sample devices for diagnostics
4. Common causes:
   - Bad software update
   - Token service configuration error
   - Network infrastructure change
5. Implement fix:
   - Rollback update via Ansible
   - Fix token service configuration
   - Coordinate with network team
6. Monitor recovery (devices should auto-reconnect)

**Target Recovery Time**: 2-4 hours

---

## Knowledge Base Articles

### Common Issues & Resolutions

**Issue**: Device offline, store reports "No network"
- **Cause**: DHCP reservation expired, network cable unplugged
- **Resolution**:
  1. Verify network cable connected
  2. Power cycle device
  3. Check DHCP reservation in network admin panel
  4. Re-register MAC address if needed

**Issue**: Dashboard shows "Token expired" error
- **Cause**: Token service unreachable, auto-refresh failed
- **Resolution**:
  1. Check token service health
  2. Restart display service: `sudo systemctl restart beacon-display`
  3. If persists, check network connectivity to token service

**Issue**: Device running hot (>70°C)
- **Cause**: Poor ventilation, ambient temperature high
- **Resolution**:
  1. Improve airflow (move device, add passive heatsink)
  2. Consider upgrading to Pi 4/5 with active cooling
  3. Monitor temperature trends

**Issue**: Memory usage high (>85%)
- **Cause**: Complex Power BI report, memory leak
- **Resolution**:
  1. Watchdog auto-restarts at 85% (self-healing)
  2. Simplify Power BI report (fewer visuals)
  3. Consider upgrading to Pi 4 (2GB RAM)

**Issue**: Display shows wrong report
- **Cause**: Configuration error (wrong reportId in config.json)
- **Resolution**:
  1. SSH to device
  2. Update config.json with correct reportId
  3. Restart display service

---

## Continuous Improvement

### Metrics to Track

**Operational Metrics**:
- Fleet uptime percentage (trending)
- Mean time between failures (MTBF)
- Mean time to repair (MTTR)
- Support ticket volume (by category)
- Cost per device (actual vs. projected)

**User Experience Metrics**:
- Store manager satisfaction (quarterly survey)
- Report load time (dashboard performance)
- Data freshness (refresh interval compliance)
- Visibility impact (qualitative feedback)

**Financial Metrics**:
- Actual TCO vs. projected
- Labor hours (actual vs. budgeted)
- Hardware failure rate (replacement costs)
- ROI realization (cost savings vs. alternatives)

---

### Quarterly Review Process

**Agenda** (90-minute meeting):
1. Operational metrics review (30 min)
2. Support trends and learnings (20 min)
3. User feedback summary (15 min)
4. Cost performance (10 min)
5. Improvement opportunities (10 min)
6. Action items and next steps (5 min)

**Attendees**: IT lead, support team, project sponsor, store representatives

**Deliverables**:
- Quarterly performance report
- Improvement backlog (prioritized)
- Budget forecast update

---

## Related Documentation

- [Deployment Overview](README.md) - Phase progression and decision gates
- [Planning Guide](planning.md) - Prerequisites and infrastructure requirements
- [Pilot Program](pilot.md) - 10-50 device pilot procedures
- [Production Rollout](production.md) - 100+ device deployment strategy
- [Cost Analysis](cost-analysis.md) - TCO models and ROI
- [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md) - Diagnostic procedures and common issues
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Technical architecture and system design
