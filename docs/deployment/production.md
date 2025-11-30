# Production Rollout Guide

**Audience**: For IT teams executing the 100+ device enterprise deployment

## Overview

**Approach**: Phased rollout in 3 waves with validation gates
**Duration**: 14 weeks (Weeks 14-27 of overall timeline)
**Scale**: 90 additional stores (10 pilot stores already deployed)
**Risk Mitigation**: Geographic diversity, validate each wave before proceeding

## Wave Strategy

### Wave 1: Initial Production (30 stores)
**Purpose**: Validate production process at moderate scale
**Duration**: 3 weeks (prep + deploy + stabilize)

**Success criteria**:
- [ ] >95% successful installations
- [ ] <5 support tickets per device
- [ ] Deployment time <20 min per store
- [ ] No security incidents

**Store Selection**:
- Mix of 10 regions, varied network complexity
- Include different store sizes and traffic patterns
- Avoid highest-complexity edge cases (save for Wave 3)

---

### Wave 2: Scale Validation (40 stores)
**Purpose**: Test support model under increased load
**Duration**: 4 weeks

**Success criteria**:
- [ ] >97% uptime across Waves 1+2
- [ ] Support response time <2 hours
- [ ] No infrastructure bottlenecks
- [ ] Process improvements documented

**Store Selection**:
- Broader geographic coverage
- Higher volume locations
- Include any special network configurations

---

### Wave 3: Completion (30 stores)
**Purpose**: Complete fleet deployment
**Duration**: 4 weeks

**Success criteria**:
- [ ] 100 stores fully operational
- [ ] Support team fully trained
- [ ] All documentation complete
- [ ] Transition to BAU (Business As Usual) operations

**Store Selection**:
- Remaining locations, including edge cases
- Any stores with unique requirements
- Backup/disaster recovery stores

---

## Pre-Production Preparation

### Master Image Creation

**Activities** (Week 14):
- Update base image with pilot improvements
- Pre-configure network settings (VLAN, DHCP)
- Install all required software packages
- Configure auto-start services
- Embed token service URL
- Test master image on 5 devices

**Validation**:
- [ ] Boot time <2 minutes
- [ ] Auto-connects to corporate network
- [ ] Display service starts automatically
- [ ] Logs properly to central monitoring
- [ ] Remote SSH access works

### Bulk Device Provisioning

**Process**:
1. Flash master image to all SD cards
2. Configure device-specific settings:
   - DeviceID (beacon-001, beacon-002, etc.)
   - Store filters (storeId in config.json)
   - MAC address registration (for DHCP reservations)
3. Label device with DeviceID sticker
4. Pack installation kit:
   - Configured device in case
   - Power supply
   - HDMI cable
   - Quick reference card
   - Troubleshooting guide

**Labor Estimate**:
- Wave 1 (30 devices): 20 hours
- Wave 2 (40 devices): 26 hours
- Wave 3 (30 devices): 20 hours

### Spare Device Strategy

**Inventory**:
- Maintain 20% spare device pool
- 30 spares for 100-device fleet
- Pre-configured and ready to ship

**Location**:
- Central IT warehouse (20 spares)
- Regional hubs (10 spares distributed)

**Replacement Process**:
1. Store reports device failure
2. IT ships spare device (overnight if critical)
3. Store swaps device (plug-and-play)
4. Failed device returned to IT for diagnosis/repair

## Deployment Procedures

### Wave 1 Deployment (Weeks 15-17)

**Week 15: Preparation**
```
Activities:
├─ Provision 30 devices + 6 spares
├─ Update master image with pilot improvements
├─ Create wave-specific config files
├─ Coordinate with store managers
└─ Schedule installations (staggered over 2 weeks)

Labor: 20 hours ($1,000)
```

**Weeks 15-16: Deployment**
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

**Week 17: Stabilization**
```
Activities:
├─ Address any issues from Wave 1
├─ Validate success metrics
├─ Refine process for Wave 2
└─ Prepare Wave 2 devices

Labor: 8 hours ($400)
```

**Gate 3**: Wave 1 validated (>95% uptime, minimal issues)

---

### Wave 2 Deployment (Weeks 18-21)

**Week 18: Preparation**
- Provision 40 devices + 8 spares
- Apply lessons learned from Wave 1
- Enhanced support documentation

**Weeks 19-20: Deployment**
- Deploy 20 stores per week
- Increased support capacity (2-3 staff on-call)

**Week 21: Stabilization and validation**
- Validate Wave 2 success criteria
- Monitor Waves 1+2 combined metrics

**Labor**: 52 hours ($2,600)

**Gate 4**: Wave 2 validated

---

### Wave 3 Deployment (Weeks 22-25)

**Week 22: Preparation**
- Provision 30 devices + 6 spares
- Final process refinements
- Edge case documentation

**Weeks 23-24: Deployment**
- Deploy 15 stores per week
- Handle any special installation requirements

**Week 25: Stabilization and validation**
- Complete fleet health check
- Address final issues

**Labor**: 44 hours ($2,200)

**Gate 5**: Wave 3 validated, all 100 stores online

---

## Quality Assurance

### Pre-Deployment Testing

**Device Testing Checklist**:
- [ ] Boots successfully (<2 minutes)
- [ ] Connects to test network
- [ ] Displays test Power BI report
- [ ] Auto-refreshes data (60 seconds)
- [ ] Logs to central monitoring
- [ ] Remote SSH access works
- [ ] Watchdog service active

**Test 5 devices from each batch** before shipping

### Post-Deployment Validation

**24-Hour Check** (for each store):
- [ ] Device online and reachable
- [ ] Dashboard displaying correctly
- [ ] Data refreshing every 60 seconds
- [ ] No error logs
- [ ] Store manager confirms operational

**7-Day Check**:
- [ ] Uptime >95%
- [ ] No support tickets
- [ ] Memory usage <80%
- [ ] Temperature normal (45-55°C)

### Automated Monitoring

**Real-Time Alerts**:
```
Alert Conditions:
├─ Device offline >30 min → Email IT support
├─ Memory usage >85% → Warning (watchdog restarts)
├─ Temperature >60°C → Warning
├─ Service crashed → Auto-restart + alert
└─ Token service unreachable → Alert
```

**Daily Health Report**:
- Fleet-wide uptime percentage
- Devices requiring attention
- Support ticket summary
- Trend analysis (improving/degrading)

## Rollback Procedures

### Device-Level Rollback

**Scenario**: Single device experiencing issues

**Procedure**:
1. Identify root cause (network, hardware, config)
2. Attempt remote fix (SSH, config update)
3. If unresolved, ship spare device to store
4. Store swaps device (5 minutes)
5. Return failed device for analysis

**Timeline**: <24 hours for critical issues

---

### Wave-Level Rollback

**Scenario**: Systemic issue affecting >20% of wave

**Procedure**:
1. Pause further deployments in current wave
2. Root cause analysis (IT team + vendors if needed)
3. Develop and test fix
4. Deploy fix to affected devices
5. Resume wave deployment after validation

**Decision Point**: If fix requires >2 weeks, consider full wave rollback

---

### Fleet-Wide Rollback

**Scenario**: Critical security issue or infrastructure failure

**Procedure**:
1. Emergency change advisory board (CAB) meeting
2. Communicate with all stores
3. Option A: Disable display service remotely (maintain SSH access)
4. Option B: Instruct stores to power off devices
5. Fix infrastructure issue
6. Phased re-enablement (pilot stores first)

**Authorization**: Requires VP Operations approval

---

## Runbooks

### Deployment Runbook

**Pre-Deployment** (1 day before):
- [ ] Verify token service health
- [ ] Verify network VLAN availability
- [ ] Verify monitoring dashboard operational
- [ ] Notify stores of expected arrival
- [ ] Support team on-call scheduled

**Deployment Day**:
- [ ] Devices shipped (tracking numbers recorded)
- [ ] IT support available (business hours)
- [ ] Monitor installations in real-time
- [ ] Track completion rate

**Post-Deployment** (1 day after):
- [ ] Verify all devices online
- [ ] Review error logs
- [ ] Follow up with stores (any issues?)
- [ ] Update deployment tracker

---

### Support Runbook

**Device Offline** (Tier 2):
1. Check monitoring dashboard (when last seen?)
2. Ping device IP address (network reachable?)
3. SSH to device (if reachable):
   - Check service status: `sudo systemctl status beacon-display`
   - Check logs: `sudo journalctl -u beacon-display -n 50`
   - Restart if needed: `sudo systemctl restart beacon-display`
4. If not reachable, contact store to verify power/network
5. If hardware failure suspected, ship spare device

**Dashboard Not Displaying** (Tier 2):
1. Verify token service health: `curl https://beacon-token.company.com/health`
2. SSH to device and check browser logs
3. Verify config.json settings (correct reportId, groupId)
4. Check Power BI workspace (report still accessible?)
5. Restart display service: `sudo systemctl restart beacon-display`

**Performance Issues** (Tier 2):
1. Check memory usage: `free -h` (should be <80%)
2. Check temperature: `vcgencmd measure_temp` (should be <60°C)
3. Check CPU load: `top` (should be <80%)
4. If memory high, watchdog will auto-restart
5. If consistently slow, consider hardware upgrade (Pi 4)

**Token Service Issues** (Tier 3):
1. Check Azure AD service principal (credentials expired?)
2. Check Power BI workspace access (permissions changed?)
3. Review token service logs
4. Rotate client secret if needed (see secret rotation runbook)
5. Test token generation: `curl https://beacon-token.company.com/api/embed-token`

---

### Update Runbook

**Software Updates** (quarterly):
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

---

## Final Validation & Handoff (Weeks 26-27)

### Week 26: Fleet-Wide Validation

**Activities**:
- [ ] Health check all 100 devices
- [ ] Validate monitoring and alerting
- [ ] Review support ticket trends
- [ ] Performance optimization (if needed)
- [ ] Documentation review and updates

**Deliverables**:
- [ ] Fleet health report
- [ ] Performance baseline metrics
- [ ] Known issues log

**Labor**: 12 hours ($600)

---

### Week 27: Production Handoff

**Activities**:
- [ ] Complete documentation (runbooks, procedures)
- [ ] Train Tier 2 support team (4-hour session)
- [ ] Transition to steady-state operations
- [ ] Final project report
- [ ] Lessons learned session
- [ ] Knowledge base articles published

**Deliverables**:
- [ ] Production operations runbook
- [ ] Support team training complete
- [ ] Device inventory database
- [ ] Project closeout report
- [ ] Transition to BAU approved

**Labor**: 16 hours ($800)

---

## Production Readiness Checklist

### Infrastructure
- [ ] Token service in production with SLA
- [ ] Network VLAN configured and tested
- [ ] Firewall rules implemented
- [ ] Monitoring and alerting operational
- [ ] Backup and disaster recovery plan

### Security
- [ ] Security review completed and approved
- [ ] All secrets in Key Vault (not in code)
- [ ] SSH key-based authentication only
- [ ] Audit logging enabled
- [ ] Incident response plan documented

### Support
- [ ] Tier 1/2/3 support structure defined
- [ ] Runbooks documented and tested
- [ ] Escalation procedures clear
- [ ] On-call rotation scheduled
- [ ] Support team trained

### Documentation
- [ ] Technical architecture documented
- [ ] Deployment procedures complete
- [ ] Troubleshooting guides available
- [ ] User guides for store staff
- [ ] Knowledge base searchable

### Operations
- [ ] Device inventory tracking system
- [ ] Spare device pool established
- [ ] Update and patch procedures
- [ ] Performance baseline established
- [ ] Steady-state operations plan

## Related Documentation

- [Deployment Overview](README.md) - Phase progression and decision gates
- [Planning Guide](planning.md) - Prerequisites and infrastructure requirements
- [Pilot Program](pilot.md) - Pilot deployment procedures and lessons learned
- [Cost Analysis](cost-analysis.md) - TCO models and optimization strategies
- [Operations Guide](operations.md) - Ongoing support, monitoring, and maintenance
- [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md) - Diagnostic procedures and common issues
