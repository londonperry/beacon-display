# BEACON Business Case

**Audience**: For executives, CFOs, and decision-makers evaluating project investment

---

## Business Drivers

### Primary Driver: Data Visibility Gap

**Problem**: Operational teams lack constant access to real-time performance metrics

**Impact**:
- Delayed decision-making (data discovered hours or days later)
- Missed opportunities (slow response to trends)
- Reactive vs. proactive management
- Manual report distribution burden (email, printing, walking reports around)
- Limited data democratization (executives have dashboards, frontline teams don't)

**Solution**: Always-on, dedicated dashboard displays in every operational area

**Expected Outcome**: Real-time visibility enables faster, data-driven decisions at all levels

---

### Secondary Driver: Cost Optimization

**Problem**: Commercial digital signage solutions prohibitively expensive ($1,500+ per screen)

**Impact**:
- Limited deployment (only high-value areas get displays)
- Budget constraints prevent broad rollout
- Underutilized existing display infrastructure (monitors/TVs gathering dust)

**Solution**: Repurpose existing displays with $50-150 Raspberry Pi devices

**Expected Outcome**: 70-90% cost reduction enables deployment to 10-20× more locations

---

### Tertiary Driver: Technology Modernization

**Problem**: Manual, paper-based, or outdated reporting processes

**Impact**:
- Labor-intensive report generation and distribution
- Stale data (reports updated weekly/monthly vs. real-time)
- Inconsistent metrics across departments
- Limited access to cloud-based analytics (Power BI, Tableau)

**Solution**: Cloud-connected, IoT-enabled display infrastructure

**Expected Outcome**: Modern, scalable, centrally-managed data visualization platform

---

## Value Proposition

### Quantitative Benefits

**Cost Savings** (100 displays, 5 years):
```
vs Commercial Digital Signage:
├─ Commercial cost: $150,000+
├─ BEACON cost (baseline): $85,973
├─ Savings: $64,027+ (74% reduction)
└─ BEACON cost (optimized): $30,961 (79% reduction, $119,027+ savings)

vs Desktop PC Repurposing:
├─ Desktop PC cost: $120,000+ (higher power, maintenance)
├─ BEACON cost (baseline): $85,973
├─ Savings: $34,027+ (40% reduction)
└─ BEACON cost (optimized): $30,961 (74% reduction, $89,039 savings)

vs Tablet Deployment:
├─ Tablet cost: $100,000+ (devices, charging, management, replacement)
├─ BEACON cost (baseline): $85,973
├─ Savings: $14,027+ (14% reduction)
└─ BEACON cost (optimized): $30,961 (69% reduction, $69,039 savings)
```

**Labor Efficiency**:
- Eliminate manual report distribution: 5 hours/week → 0 hours (260 hours/year saved)
- Reduce decision-making latency: Hours/days → Real-time (20% faster response)
- Self-managing displays: Minimal IT support (<4% FTE ongoing)

**Hardware Utilization**:
- Repurpose existing displays: $0 incremental display cost (vs. $100-500/screen)
- Reduce e-waste: Extend life of older monitors by 3-5 years

---

### Qualitative Benefits

**Organizational Culture**:
- Data-driven decision-making becomes norm vs. exception
- Transparency improves (everyone sees same metrics)
- Team alignment on goals and performance
- Increased accountability (metrics visible to all)

**Employee Empowerment**:
- Frontline teams gain same visibility as executives
- Self-service access to operational intelligence
- Faster feedback loops (see impact of actions immediately)

**Operational Excellence**:
- Proactive vs. reactive management (spot trends early)
- Continuous improvement mindset (metrics always visible)
- Standardized reporting across locations
- Reduced "data request" burden on analytics teams

**User Experience**:
- Zero training required (view-only, no interaction)
- Always-on availability (no login, no navigation)
- Consistent experience across all locations
- Reliable (98%+ uptime, self-healing)

**Food Safety** (for applicable environments):
- Touchless operation eliminates cross-contamination risk
- Supports sanitation compliance (no cleaning protocols needed)
- Ideal for food prep, deli, bakery, meat departments

---

## Cost-Benefit Analysis

### 5-Year Total Cost of Ownership (100 Stores)

**BEACON Baseline** (commercial management platform):
```
Year 1: $26,653 (hardware, setup, ongoing)
Years 2-5: $14,830/year × 4 = $59,320
────────────────────────────────────────
5-Year TCO: $85,973
Cost per store: $860
```

**BEACON Optimized** (custom management, automation):
```
Year 1: $18,161 (hardware, custom dev, ongoing)
Years 2-5: $3,200/year × 4 = $12,800
────────────────────────────────────────
5-Year TCO: $30,961
Cost per store: $310
```

**Commercial Digital Signage**:
```
Year 1: $150,000+ (hardware + software licenses)
Years 2-5: $20,000+/year (licensing, support)
────────────────────────────────────────
5-Year TCO: $230,000+
Cost per store: $2,300+
```

---

### Return on Investment (ROI)

**Scenario 1: BEACON Baseline vs. Commercial Signage**

**Investment**: $85,973 (5 years)

**Savings**:
- Avoided commercial signage cost: $150,000+
- Net savings: $64,027+ (74% reduction)

**Additional Value** (not quantified):
- Labor efficiency: 260 hours/year (report distribution eliminated)
- Faster decision-making: 20% response time improvement
- Employee satisfaction: Improved data visibility

**ROI**: 74% cost reduction + operational efficiency gains

**Payback Period**: Immediate (BEACON cheaper from Year 1)

---

**Scenario 2: BEACON Optimized vs. Commercial Signage**

**Investment**: $30,961 (5 years)

**Savings**:
- Avoided commercial signage cost: $150,000+
- Net savings: $119,027+ (79% reduction)

**ROI**: 79% cost reduction + operational efficiency gains

**Payback Period**: Immediate

---

**Scenario 3: BEACON Optimized vs. Desktop PC Repurposing**

**Investment**: $30,961 (5 years)

**Savings**:
- Avoided desktop PC cost: $120,000+ (higher power, maintenance, support)
- Net savings: $89,039 (74% reduction)

**Additional Value**:
- Lower theft risk (less valuable hardware)
- Simpler user experience (view-only vs. full OS)
- Faster boot times (2 min vs. 5+ min)
- Zero configuration drift (dedicated purpose)

**ROI**: 74% cost reduction + operational benefits

**Payback Period**: Immediate

---

## Stakeholders

### Primary Stakeholders

| Role | Responsibility | Success Metric |
|------|---------------|---------------|
| **VP Operations** | Budget approval, strategic alignment | Cost savings achieved, operational KPIs improved |
| **CFO** | Financial oversight, ROI validation | TCO within budget, ROI >50% |
| **CIO/IT Director** | Infrastructure support, security approval | 98%+ uptime, zero security incidents |
| **Department Managers** | Define metrics needs, user adoption | Team satisfaction, data-driven decisions |
| **Power BI Team** | Report access, workspace permissions | Embed tokens working, reports optimized |
| **Information Security** | Security review, compliance validation | Security controls met, audit passed |

---

### Secondary Stakeholders

| Role | Involvement | Deliverable |
|------|------------|-------------|
| **Store Managers** | Pilot feedback, deployment assistance | Positive feedback, <2 support tickets/device |
| **Network Team** | VLAN configuration, firewall rules | Network infrastructure ready |
| **Azure AD Team** | Service principal setup | Authentication working |
| **Procurement** | Hardware purchasing, vendor management | Bulk pricing negotiated |
| **Operational Teams** | Daily users of dashboards | Improved data visibility, faster decisions |

---

## Requirements

### Functional Requirements

**Must Have**:
- Display Power BI reports full-screen
- Auto-refresh data every 60 seconds
- Auto-refresh embed tokens every 50 minutes
- Boot time <2 minutes
- Auto-recovery from crashes and power outages
- Support for multiple hardware tiers (Pi Zero, Pi 4, Pi 5)

**Should Have**:
- Centralized device management dashboard
- Remote configuration updates
- Health monitoring and alerting
- Store-specific data filtering (row-level security)
- Support for multiple reports per device (rotation)

**Nice to Have**:
- Multi-platform support (Tableau, Grafana, custom apps)
- Offline mode (cached data when network unavailable)
- Touchscreen support (for conference rooms)
- Predictive maintenance (ML-based failure detection)

---

### Non-Functional Requirements

**Performance**:
- Boot time: <2 minutes
- Dashboard load time: <10 seconds
- Data refresh latency: <5 seconds
- Memory usage: <80% (400MB for Pi Zero 2 W)
- Temperature: Normal operation <60°C

**Reliability**:
- Device uptime: >98%
- Token service uptime: >99%
- Auto-recovery: <2 minutes after crash
- Hardware failure rate: <5% annually (Pi Zero), <2% (Pi 4), <1% (Pi 5)

**Security**:
- Zero secrets in code (environment variables or Key Vault)
- Service principal with minimum required permissions
- Network segmentation (IoT VLAN)
- SSH key-based authentication only (no passwords)
- HTTPS enforced for token service

**Scalability**:
- Support 100+ devices from single token service
- Centralized management for 500+ devices (future)
- Minimal ongoing labor (<5% FTE for 100 devices)

**Usability**:
- Zero user training required (view-only)
- Self-explanatory display (dashboard shows what it is)
- No user interaction needed (touchless by design)

---

## Competitive Analysis

### Commercial Digital Signage Solutions

**Examples**: Yodeck, PiSignage, ScreenCloud, NoviSign

**Pros**:
- Web-based management dashboard
- Remote configuration and content updates
- Health monitoring and alerting
- Multi-tenant support
- Professional support and SLAs

**Cons**:
- Expensive: $5-10/device/month ($60-120/year)
- Vendor lock-in
- Recurring license costs (never fully own)
- Overkill for simple dashboard displays

**BEACON Advantage**:
- 88% cost reduction (custom management vs. commercial platform)
- No vendor lock-in (open-source components)
- One-time development cost vs. perpetual licensing

---

### Enterprise Dashboard Appliances

**Examples**: Intel NUC + commercial OS, Dell OptiPlex Micro

**Pros**:
- x86 architecture (full browser compatibility)
- Higher performance (8GB+ RAM, SSD storage)
- Familiar IT support (Windows/Linux)
- Longer lifespan (7-10 years)

**Cons**:
- Expensive: $200-500/device
- Higher power consumption (6-15W vs. 3W)
- Larger form factor (harder to hide/mount)
- Overkill for simple dashboards

**BEACON Advantage**:
- 76-85% cost reduction
- Sufficient performance for most dashboards
- Lower power costs (3W = $2/year vs. 10W = $7/year)
- Smaller, easier to deploy

---

### Desktop PC Repurposing

**Approach**: Repurpose old desktop PCs as dedicated displays

**Pros**:
- Leverage existing hardware (sunk cost)
- High performance (4GB+ RAM, x86 CPU)
- IT team already familiar

**Cons**:
- High power consumption (50-100W = $35/year)
- Requires OS updates and patching (Windows/Linux)
- Larger footprint (tower/desktop units)
- Higher failure rate (moving parts, older hardware)
- Security risk (full OS, more attack surface)

**BEACON Advantage**:
- 40-74% lower TCO (includes power, maintenance)
- Minimal OS (Raspberry Pi OS Lite, smaller attack surface)
- Smaller form factor (hidden behind display)
- Lower ongoing support burden

---

### Tablet Deployment

**Approach**: Wall-mount tablets (iPad, Android) for dashboards

**Pros**:
- Touchscreen (if interactivity desired)
- Portable (can move locations)
- Familiar user interface

**Cons**:
- Expensive: $300-500/device
- Battery management (charging, degradation)
- Higher failure rate (drops, screen damage)
- User interaction invites non-work usage
- Requires mobile device management (MDM)
- Theft risk (high-value devices)

**BEACON Advantage**:
- 69-85% cost reduction
- No battery management (plugged in)
- View-only by design (eliminates misuse)
- Lower theft risk (less valuable hardware)
- Dedicated purpose (no configuration drift)

---

## Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Pi performance insufficient | Low | High | Test complex reports, upgrade to Pi 4/5 if needed ($90-132) |
| Network connectivity issues | Medium | Medium | Document requirements, test on corporate network |
| Power BI licensing limits | Low | High | Verify with IT before pilot |
| Token service complexity | Medium | Medium | Robust error handling, fallback procedures |
| Display compatibility | Low | Medium | Test with various monitor types, HDMI/resolution compatibility |

---

### Business Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Stakeholder rejection | Low | High | Strong demo, clear value proposition, pilot program |
| Budget constraints | Low | Low | Low upfront cost, leverage existing displays |
| IT security concerns | Medium | Medium | Proactive security review, address concerns early |
| Scope creep | High | Low | Clear POC vs production boundaries |
| Underutilized displays | Low | Medium | Identify existing display inventory before deployment |

---

### Operational Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Support burden higher than expected | Medium | Medium | Self-healing watchdog, automation, tiered support |
| Hardware failure rate higher than 5% | Low | Medium | Quality components, surge protection, burn-in testing |
| User adoption low | Low | High | Engage store managers early, demonstrate value |
| Power outages cause frequent restarts | Medium | Low | Auto-recovery <2 min, UPS for critical displays |
| Network changes break connectivity | Medium | Medium | Document network requirements, change management |

---

## Budget

### POC Cost

**Hardware**: $50 (one device)
**Development**: 20-30 hours personal time
**Cloud**: $0 (Azure free tier)
**Total**: <$100

---

### Production Pilot (10 Locations)

**Hardware**: $500-900 (10 devices @ $50-90, depending on tier)
**Token Service**: $2,000 (setup, security review)
**Management**: $1,000/year
**Year 1 Total**: $3,500-4,000
**Display Cost**: $0 (repurpose existing monitors/TVs)

---

### Full Rollout (100 Locations)

**Hardware**: $5,000-11,000 (100 devices @ $50-110, mixed tiers)
**Operating**: $3,200-16,600/year (depends on automation level)
**5-Year TCO**: $31,000-86,000 (based on optimization strategies)
**Display Cost**: $0 (repurpose existing infrastructure)

---

### Budget Comparison

| Approach | 5-Year TCO (100) | Hardware per Display | Notes |
|----------|------------------|----------------------|-------|
| BEACON Entry (Pi Zero 2 W) | $86,000 | $48 | Simple dashboards, existing displays |
| BEACON Mixed Tiers | $78,000 | $77 avg | Optimized for use case |
| BEACON Optimized | $31,000 | $48-110 | Custom management, automation |
| Commercial Digital Signage | $150,000+ | $1,500+ | Includes hardware + software licensing |
| Repurposed Desktop PCs | $120,000+ | $200+ | Higher power, maintenance costs |

---

## Success Metrics

### POC Criteria

- [ ] Power BI report displays full-screen
- [ ] Auto-refresh every 60 seconds
- [ ] 72-hour continuous operation without intervention
- [ ] Boot time <2 minutes
- [ ] Hardware cost <$60
- [ ] Stakeholder approval for pilot

---

### Production Criteria (Future)

- 98% uptime across all devices
- <2 support incidents per location annually
- Zero user training required (touchless operation)
- Successful repurposing of existing display infrastructure
- 90-day deployment timeline
- Positive user feedback (improved data visibility)
- 70-90% cost savings vs commercial digital signage solutions

---

### KPIs to Track

**Financial KPIs**:
- Actual TCO vs. projected
- Cost per device (including all labor, software, hardware)
- ROI vs. alternatives (commercial signage, desktop PCs)
- Hardware failure rate (replacement costs)

**Operational KPIs**:
- Fleet uptime percentage
- Mean time between failures (MTBF)
- Mean time to repair (MTTR)
- Support ticket volume (trending)
- Labor hours (actual vs. budgeted)

**User Experience KPIs**:
- Store manager satisfaction (quarterly survey)
- Report load time (dashboard performance)
- Data freshness (refresh interval compliance)
- Adoption rate (devices actively used vs. deployed)

---

## Timeline

### Phase 1: POC Development (2 weeks)
**Week 1**: Hardware setup, Azure config, token service
**Week 2**: Pi deployment, 72-hour test, documentation

### Phase 2: Stakeholder Demo (1 week)
- Prepare presentation and cost analysis
- Live demo with backup video
- Q&A preparation

### Phase 3: Pilot Approval (2-4 weeks)
- IT security review
- Network requirements gathering
- Pilot store selection (10 stores)
- Budget approval

### Phase 4: Production Pilot (6-8 weeks)
- 10-store deployment
- Monitoring and refinement
- Full rollout planning

### Phase 5: Production Rollout (14 weeks)
- Phased deployment (3 waves: 30, 40, 30 stores)
- Centralized management
- Support team training
- Transition to steady-state operations

**Total Timeline**: 28 weeks (~7 months) from approval to full deployment (100 stores)

---

## Recommendations

### For POC Phase

1. **Approve POC budget** ($100) for hardware and development
2. **Allocate 20-30 hours** personal time for setup and testing
3. **Schedule stakeholder demo** for Week 3 (after 72-hour test)
4. **Identify pilot store candidates** (10 locations with varied characteristics)

---

### For Pilot Phase (if POC approved)

1. **Approve pilot budget** ($3,500-4,000) for 10 stores
2. **Engage IT teams early** (Azure AD, Network, InfoSec)
3. **Select diverse pilot stores** (geographic, network, volume diversity)
4. **Plan for 6-8 week pilot** before production decision
5. **Use commercial management platform** for pilot (easy validation)

---

### For Production Phase (if pilot successful)

1. **Approve production budget** ($31,000-86,000 depending on optimization)
2. **Build custom management platform** (saves $42,400 over 5 years)
3. **Deploy in 3 waves** (30, 40, 30 stores) with validation gates
4. **Implement automation** (Ansible, scripted health checks)
5. **Negotiate bulk hardware pricing** (15-25% discount on 100+ units)
6. **Optimize hosting** (on-prem VM or Azure Container Instances)

---

## Related Documentation

- [Project Overview](README.md) - Mission, solution, use cases, roadmap
- [Deployment Overview](../deployment/README.md) - Enterprise deployment phases
- [Cost Analysis](../deployment/cost-analysis.md) - Detailed TCO models and optimization strategies
- [Planning Guide](../deployment/planning.md) - Prerequisites and infrastructure requirements
- [Pilot Program](../deployment/pilot.md) - 10-50 device pilot procedures

---

**Last Updated**: 2025
**Review Date**: After POC completion
**Status**: Active Development
