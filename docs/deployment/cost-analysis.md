# Cost Analysis & ROI

**Audience**: For CFOs, budget holders, and decision-makers evaluating BEACON's financial viability

## Cost Breakdown Methodology

**Employee Rate**: $50/hour (blended IT rate)
**Annual Work Hours**: 2,080 hours (40 hrs/week × 52 weeks)
**Intent**: Minimal ongoing labor burden (<5% of one FTE)

## Pilot Program Costs (10 Stores)

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

---

## Production Rollout Costs (100 Stores)

### Year 1 Costs

#### Hardware (including pilot devices)
```
Component                          Quantity    Unit Cost    Total
─────────────────────────────────────────────────────────────────
Production devices                 90          $50          $4,500
Spares (20% of fleet)              20          $50          $1,000
Pilot devices (reused)             10          $0           $0
─────────────────────────────────────────────────────────────────
Hardware Total:                                             $5,500
```

#### Initial Setup Labor (one-time)
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

#### Ongoing Annual Labor (Year 1)
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

#### Annual Software/Services
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

#### Year 1 Summary
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

### Years 2-5 (Annual Recurring)

#### Ongoing Labor (steady state)
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

#### Annual Recurring Costs
```
Software/services                                       $10,680
Ongoing labor (77 hours, 3.7% FTE)                      $3,850
Hardware replacements (5% failure)                      $300
─────────────────────────────────────────────────────────────
Annual Ongoing:                                         $14,830
Cost per store per year:                                $148
```

### 5-Year Total Cost of Ownership (Baseline)

```
Year 1 (includes setup)                                 $26,653
Years 2-5 (4 × $14,830)                                 $59,320
─────────────────────────────────────────────────────────────
5-Year TCO:                                             $85,973
Average annual cost:                                    $17,195
Cost per store over 5 years:                            $860
```

---

## Hardware Tier Comparison

### Entry Tier: Pi Zero 2 W (Baseline)

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

### Performance Tier: Pi 4 Model B

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

**TCO Savings (100 devices, 5 years)**:
```
├─ Hardware: +$4,200 upfront
├─ Labor savings: -$6,750 (reduced support)
├─ Replacement savings: -$1,500 (lower failure rate)
└─ Net savings: -$4,050 (5.4% reduction)
```

---

### Premium Tier: Pi 5 (Future Option)

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

**TCO Savings (100 devices, 5 years)**:
```
├─ Hardware: +$6,400 upfront
├─ Labor savings: -$13,500 (minimal support)
├─ Replacement savings: -$2,400 (lowest failure)
├─ Longevity value: +$5,000 (reusable beyond 5yr)
└─ Net savings: -$14,500 (16.9% reduction)

Recommendation: Use for mission-critical displays where downtime is costly
```

---

## Scaling Economics

The power of BEACON is in **leveraging existing displays** + **self-managing software** + **flexible hardware tiers**:

### 100 Displays at Different Tiers
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

### Mixed-Tier Deployment Strategy

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

## Value Proposition: Transform Existing Displays

BEACON's primary value is **repurposing existing display infrastructure** rather than purchasing new hardware. Most organizations already have:

- Unused monitors in storage
- TVs in break rooms showing cable news
- Conference room displays sitting idle outside meetings
- Retired desktop monitors from hardware refreshes

**The BEACON Advantage**: Turn these into self-managing, dedicated dashboard displays for $50-150 per screen.

### Comparison: Traditional Approaches

**Alternative Solutions (100 displays, 5 years)**:
```
Commercial digital signage        $150,000+     $1,500/screen (hardware + license)
Enterprise dashboard appliances   $200,000+     $2,000/device (NUC + commercial OS)
Desktop PCs (repurposed)          $120,000      $200/PC + higher power costs
────────────────────────────────────────────────────────────────────────

Savings (vs commercial):          $64,027+      74% cost reduction
Savings (vs desktop PCs):          $34,027+      40% cost reduction
```

### Additional Benefits Beyond Cost

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

The baseline cost model includes commercial management platforms and standard approaches. However, **significant savings are possible** through strategic optimization.

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

## Optimized Cost Model (100 Stores, 5 Years)

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

## ROI Comparison: All Scenarios

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

### Scaling Economics (200 locations, fully optimized)

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

## Implementation Recommendation Matrix

**Choose your optimization level based on organizational capability:**

| Strategy | Easy | Med | Hard | Savings | Complexity |
|----------|------|-----|------|---------|------------|
| 1: Custom management platform | | | ✓ | $42,400 | Requires dev skills |
| 2: Optimized hosting | ✓ | | | $3,900-5,400 | IT infrastructure decision |
| 3: Automation | | ✓ | | $5,000-6,600 | Scripting/Ansible skills |
| 4: Bulk hardware pricing | ✓ | | | $1,200 | Negotiation only |
| 5: Reduce failures | ✓ | | | $500 | Process improvement |

### Recommended Approach for Maximum ROI

1. **Pilot**: Use commercial platform ($800 × 2 months = $160) for quick validation
2. **Production (Waves 1-2)**: Continue commercial platform while building custom tools
3. **Wave 3 onward**: Transition to custom platform (saves $9,400/year ongoing)
4. **Result**: Recoups custom development cost in 4.5 months, then pure savings

### Quick Win Path (minimal technical investment)

- Implement Strategy 2 (hosting optimization) + Strategy 4 (bulk pricing)
- Total effort: 0 hours (just procurement decisions)
- 5-Year savings: $5,100-6,600
- New TCO: $79,373-80,873 (saves $5,100-6,600 vs baseline)

### Maximum ROI Path (technical investment required)

- Implement all strategies except #5 (not cost-effective)
- Total effort: 72 hours setup + 4 hours/year maintenance
- 5-Year savings: $40,700+ (47% reduction)
- Break-even: Month 5 of operation
- Requires: Dev resources, Ansible expertise, company infrastructure

---

## Key Insight: The Management Platform Bottleneck

**Critical Finding**: The commercial management platform represents **56% of ongoing costs** ($9,600 of $17,195 annual average). Eliminating it through custom tooling has an **8-month payback period** and is the single highest-impact optimization.

### DIY Management Platform Components

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

---

## Bulk Purchasing Guide

### Hardware Tier Comparison Table

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

### Recommended Suppliers

**Authorized Distributors**:
- Newark/Element14 (bulk pricing, business accounts)
- Digi-Key (volume discounts, international shipping)
- Mouser Electronics (technical support, rapid delivery)

**Raspberry Pi Resellers**:
- Adafruit (US-based, excellent support)
- CanaKit (kit bundling, competitive pricing)
- The Pi Hut (UK/EU, bulk orders)

**Negotiation Tips**:
- Request quote for 100+ units (expect 15-25% discount)
- Bundle components (Pi + power + case + SD card)
- Negotiate payment terms (Net 30/60 for large orders)
- Request price protection (lock in pricing for 12 months)
- Consider leasing/rental for pilot phase

---

## Related Documentation

- [Deployment Overview](README.md) - Phase progression and decision gates
- [Planning Guide](planning.md) - Prerequisites and infrastructure requirements
- [Pilot Program](pilot.md) - 10-50 device pilot procedures
- [Production Rollout](production.md) - 100+ device deployment strategy
- [Operations Guide](operations.md) - Support structure and maintenance
- [PROJECT-DEFINITION.md](../../PROJECT-DEFINITION.md) - Business case and stakeholders
