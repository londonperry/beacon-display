# Pilot Program Guide

**Audience**: For IT teams and project leads executing the 10-50 device pilot deployment

## Objectives

1. Validate solution in production environment
2. Identify infrastructure integration issues
3. Test support procedures
4. Gather user feedback
5. Refine deployment process

## Scope

**Stores**: 10 locations (geographic, network, and volume diversity)
**Duration**: 6-8 weeks
**Timeline**:
- Week 1-2: Deploy to 10 stores
- Week 3-4: Monitor, gather feedback, fix issues
- Week 5-6: Refine processes, update docs
- Week 7-8: Final evaluation, rollout decision

## Success Criteria

- [ ] 98% uptime across all pilot devices
- [ ] Zero security incidents
- [ ] <2 support tickets per device
- [ ] Positive feedback from 8/10 store managers
- [ ] Boot time <2 minutes
- [ ] Cost per device <$150 (including deployment)

## Pilot Store Selection

### Selection Criteria

Choose 10 stores that represent:
- **Geographic diversity**: Different regions/time zones
- **Network diversity**: Mix of network configurations
- **Volume diversity**: High, medium, and low traffic locations
- **Leadership buy-in**: Managers enthusiastic about data visibility
- **IT accessibility**: Easier for remote support if needed

### Recommended Mix

```
Store Type                 Count    Rationale
───────────────────────────────────────────────────────────────
High-volume flagship       2        Stress test, high visibility
Mid-volume standard        5        Typical use case
Low-volume rural           2        Network edge cases
New store (<1 year)        1        Modern infrastructure test
```

## Pilot Program Costs

### Hardware Costs
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

### Labor Costs (Initial Setup)
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

### Software/Services (2-month pilot)
```
Management platform (optional)     2 months  $80/mo    $160
Azure infrastructure (dev tier)    2 months  $50/mo    $100
─────────────────────────────────────────────────────────
Services Subtotal:                                     $260
```

**Pilot Total**: $3,040 ($304 per store)

## Deployment Process

### Pre-Deployment (Week 1)

**Activities**:
- IT infrastructure ready (network, token service, monitoring)
- Master device image created
- 10 devices + 2 spares provisioned
- Store managers notified with installation guides

**Deliverables**:
- [ ] 12 configured devices ready to ship
- [ ] Installation guide (with photos)
- [ ] Store manager quick reference card
- [ ] Troubleshooting checklist

**Labor**: 16 hours ($800)

### Deployment Week (Week 2)

**Timeline**:
- **Day 1**: Ship devices (expedited)
- **Day 2**: IT on standby
- **Day 3**: Stores install (15-30 min each)
- **Day 4-5**: Monitor and address issues

**Support model**:
- Dedicated Slack channel for pilot stores
- IT support on-call during business hours
- Daily health checks

**Labor**: 16 hours ($800)

### Monitoring Period (Weeks 3-6)

**Daily Activities**:
- Device health checks
- Error log review
- Support ticket tracking

**Weekly Activities**:
- Manager feedback collection
- Stakeholder updates
- Process refinement

**Monthly Activities**:
- Formal pilot review
- Metrics compilation

**Metrics Tracked**:
- Uptime percentage (target: >98%)
- Boot time (target: <2 min)
- Support tickets per device (target: <2)
- User satisfaction score (target: 8/10)
- Security incidents (target: 0)

**Labor**: 10 hours/week × 4 weeks = 40 hours ($2,000)

### Pilot Evaluation (Weeks 7-8)

**Activities**:
- Compile pilot metrics and feedback
- Document lessons learned
- Update deployment procedures
- Refine cost estimates based on actuals
- Present pilot results to steering committee
- Get go/no-go decision for production rollout
- Plan production wave logistics

**Deliverables**:
- [ ] Pilot evaluation report
- [ ] Updated deployment playbook
- [ ] Production rollout plan
- [ ] Go-live approval

**Labor**: 16 hours ($800)

## Installation Procedure

### Store Staff Instructions (15-30 minutes)

1. **Unbox and identify components**
   - Raspberry Pi in case
   - Power supply
   - HDMI cable
   - Quick reference card

2. **Physical installation**
   - Connect HDMI cable to existing monitor/TV
   - Connect HDMI cable to Raspberry Pi
   - Connect power supply to Raspberry Pi
   - Connect power supply to wall outlet (surge protector recommended)

3. **Wait for boot (2 minutes)**
   - Green LED blinks during boot
   - Display will show Power BI dashboard when ready

4. **Verify operation**
   - Dashboard displays full-screen
   - Data refreshes every 60 seconds
   - No error messages

5. **Secure device**
   - Mount Pi case behind monitor/TV or nearby shelf
   - Route cables neatly
   - Label device with DeviceID sticker

### Troubleshooting Checklist

**Issue**: Display shows "No Signal"
- Check HDMI cable connections
- Verify monitor is on correct input
- Try different HDMI cable (provided spare)

**Issue**: Dashboard doesn't load
- Wait 2 full minutes for boot
- Check network connectivity (LED blinks indicate activity)
- Contact IT support via Slack channel

**Issue**: Blank screen with cursor
- Device booted but display-client service failed
- Contact IT support (remote troubleshooting)

**Issue**: Error message displayed
- Take photo of error message
- Contact IT support with photo

**Escalation**: If issue not resolved in 15 minutes, contact IT support

## Support Structure

### Tier 1: Store Staff
- **Responsibility**: Power cycle device if not working
- **Training**: 5-minute quick reference guide
- **Escalation**: IT help desk (Slack or help desk system)

### Tier 2: IT Help Desk
- **Responsibility**: Remote diagnostics, config updates, device replacement
- **Tools**: Device dashboard, SSH access, management scripts, runbook
- **Availability**: Business hours during pilot
- **Escalation**: BEACON development team

### Tier 3: BEACON Team
- **Responsibility**: Token service issues, complex troubleshooting, infrastructure problems
- **Availability**: Business hours (displays self-heal overnight)
- **Tools**: Full access to all systems

## Feedback Collection

### Weekly Store Manager Survey

**Questions** (5-minute survey):
1. Is the dashboard displaying correctly? (Yes/No/Sometimes)
2. Has the display improved your team's data visibility? (1-10 scale)
3. Have you experienced any issues this week? (Open text)
4. How many times did you need IT support? (Count)
5. What improvements would you suggest? (Open text)

### Mid-Pilot Interview (Week 4)

**30-minute call with each manager**:
- Deep dive on usage patterns
- Feedback on report content (for Power BI team)
- Suggestions for different dashboard metrics
- Installation process feedback
- Support quality feedback

### End-of-Pilot Survey

**Comprehensive feedback** (10-minute survey):
- Overall satisfaction (1-10 scale)
- Likelihood to recommend to other stores (NPS)
- Impact on team performance (qualitative)
- Technical reliability rating (1-10 scale)
- Installation difficulty (1-10 scale)
- Support responsiveness (1-10 scale)

## Go/No-Go Decision

### Gate 2: Pilot Success Evaluation

**Required Criteria for "Go"**:
- [ ] ≥98% uptime across all pilot devices
- [ ] Zero security incidents
- [ ] ≤2 support tickets per device average
- [ ] ≥8/10 average store manager satisfaction
- [ ] <2 minutes average boot time
- [ ] ≤$150 cost per device (including deployment)

**Optional "Proceed with Caution" Criteria**:
- 95-97% uptime (acceptable with mitigation plan)
- 3-4 support tickets per device (if trending down)
- 7/10 satisfaction (if specific issues identified and fixable)

**"No-Go" Triggers**:
- <95% uptime (reliability issue)
- Any security incidents (requires review and remediation)
- >5 support tickets per device (excessive support burden)
- <7/10 satisfaction (poor user experience)
- >$200 cost per device (budget concerns)

### Decision Meeting Agenda

**Attendees**: Steering committee, IT leads, pilot store managers

**Agenda**:
1. Pilot metrics review (30 min)
2. Store manager feedback summary (20 min)
3. Lessons learned and improvements (20 min)
4. Cost analysis actual vs. projected (10 min)
5. Production readiness assessment (20 min)
6. Go/no-go vote (10 min)
7. Next steps planning (20 min)

## Lessons Learned Documentation

### Categories to Document

**What Went Well**:
- Installation process smooth
- User adoption high
- Technical reliability strong
- Cost within budget

**What Needs Improvement**:
- Network configuration issues
- Support response times
- Documentation gaps
- Hardware compatibility

**Unexpected Issues**:
- Environmental factors (temperature, humidity)
- User behavior (unplugging devices, changing inputs)
- Network edge cases
- Power outages

**Process Refinements**:
- Updated installation guide
- Enhanced troubleshooting procedures
- Improved device configuration
- Better pre-deployment testing

### Apply Learnings to Production

**Update for Production Rollout**:
- [ ] Deployment playbook refined
- [ ] Support runbook enhanced
- [ ] Training materials improved
- [ ] Infrastructure changes documented
- [ ] Cost model adjusted to actuals

## Related Documentation

- [Deployment Overview](README.md) - Phase progression and gates
- [Planning Guide](planning.md) - Prerequisites and infrastructure setup
- [Production Rollout](production.md) - 100+ device deployment after pilot
- [Cost Analysis](cost-analysis.md) - TCO models and ROI
- [Operations Guide](operations.md) - Ongoing support and maintenance
