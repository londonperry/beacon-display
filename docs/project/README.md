# BEACON Project Overview

**Audience**: For executives, stakeholders, and anyone new to the BEACON project

---

## Executive Summary

BEACON delivers real-time operational intelligence to back-office teams through dedicated, always-on Power BI dashboard displays. Using low-cost Raspberry Pi devices, organizations transform existing monitors and TVs into self-managing dashboard displays at a fraction of traditional digital signage costs.

**Problem**: Limited data visibility for operational teams, expensive digital signage solutions, underutilized display infrastructure

**Solution**: Transform existing displays into self-managing, dedicated dashboards for $50-150 per screen

**Status**: Proof of Concept phase

**Next**: Stakeholder demo → Pilot approval → Multi-location rollout

---

## Project Mission

Democratize real-time data visibility by repurposing existing display infrastructure with dedicated, zero-touch displays that cost 70-90% less than commercial solutions while improving operational visibility.

---

## Problem Statement

### Current State (Traditional Solutions)

- **Limited Visibility**: Operational teams lack constant access to real-time metrics
- **Underutilized Infrastructure**: Existing monitors/TVs in break rooms, offices sit idle or show cable news
- **High Cost**: Commercial digital signage ($1,500+ per screen) and enterprise display appliances prohibit widespread deployment
- **Maintenance Burden**: Multi-purpose devices require constant updates, user management, security patching
- **Configuration Drift**: Interactive devices invite non-work usage and lose their intended purpose over time

### Desired State (BEACON Solution)

- **Dedicated Display**: Single-purpose devices focused solely on data visibility
- **Always-On**: 24/7 operation, no charging needed, instant visibility
- **Low Cost**: 85% reduction in hardware costs enables broader deployment
- **Zero-Touch**: No user interaction required, eliminates training and support burden
- **Reliable**: Auto-recovery from power/network failures, self-healing watchdog

---

## Solution Overview

### Two-Component Architecture

**Token Service** (Node.js):
- Authenticates with Azure AD using service principal
- Generates Power BI embed tokens (1-hour validity)
- Two versions: laptop (POC) and cloud (production)

**Display Client** (HTML/JavaScript):
- Runs in Chromium browser on Raspberry Pi
- Embeds Power BI reports using tokens
- Auto-refreshes data (60 sec) and tokens (50 min)

### Key Features

- **Self-Managing**: Auto-recovery from crashes, network issues, power outages
- **Zero-Touch**: No user interaction required (view-only)
- **Secure**: Service principal authentication, token-based access, network segmentation
- **Cost-Effective**: $50-150 per screen vs. $1,500+ for commercial solutions
- **Scalable**: Manage 100+ devices from centralized dashboard
- **Flexible**: Support for multiple hardware tiers based on dashboard complexity

---

## Use Cases

### Corporate Office Teams

**Executive Leadership (C-Suite, VPs)**
- Real-time company performance dashboards in executive areas
- Strategic KPIs, financial metrics, operational health
- Board room displays for meetings and presentations
- Department-specific dashboards (CFO: financial metrics, COO: operations)

**Sales Teams**
- Live sales pipeline and revenue tracking in sales bullpen
- Individual and team quota progress
- Deal stage visibility and conversion funnels
- Regional/territory performance comparisons

**Marketing Teams**
- Campaign performance metrics (ROI, lead generation, engagement)
- Social media analytics and sentiment tracking
- Website traffic and conversion dashboards
- Marketing qualified leads (MQL) flow

**Operations & Manufacturing**
- Production line metrics (throughput, efficiency, downtime)
- Quality control statistics and defect rates
- Inventory levels and supply chain visibility
- Equipment status and maintenance schedules

**Customer Support**
- Real-time ticket queue and response time metrics
- Customer satisfaction scores (CSAT, NPS)
- Agent performance and availability
- SLA compliance tracking

**IT & DevOps**
- System uptime and infrastructure health
- Incident response status and ticket queue
- Security alerts and compliance dashboards
- Application performance monitoring (APM)

**HR & People Operations**
- Hiring pipeline and time-to-fill metrics
- Employee engagement scores
- Headcount and org structure visualizations
- Training completion and certification tracking

**Finance & Accounting**
- Budget vs. actual spend tracking
- Cash flow and accounts receivable aging
- Expense management and approval workflows
- Monthly/quarterly close progress

---

### Grocery Store Operational Areas

**Bakery Department**
- Production schedules and batch tracking
- Waste/shrink monitoring
- Labor hours vs. sales productivity
- Oven/equipment temperature monitoring
- Inventory levels for key ingredients
- Daily sales by category (bread, pastries, cakes)
- *Food Safety Note*: Touchless operation ideal for food prep areas

**Deli Department**
- Prepared food sales tracking
- Hot case rotation schedules
- Temperature logs for food safety compliance
- Slicing and portioning productivity
- Catering order status
- Labor scheduling vs. customer traffic
- *Food Safety Note*: Eliminates cross-contamination from touch interaction

**Floral Department**
- Daily sales and shrink rates
- Arrangement productivity tracking
- Inventory freshness monitoring
- Special order status
- Seasonal trend analysis

**Produce Department**
- Receiving and quality inspection logs
- Cooler temperature monitoring
- Culling/waste tracking
- Rotation compliance (FIFO)
- Sales velocity by item
- Markdown schedules

**Meat & Seafood Department**
- Cut schedules and case yields
- Temperature monitoring (cases, coolers, freezers)
- Sanitation log compliance
- Sales by protein type
- Special cut/order tracking
- Packaging productivity
- *Food Safety Note*: View-only displays support sanitation protocols

**Back Office**
- Store-level sales reports (hourly, daily, weekly)
- Labor scheduling vs. budget
- Inventory management and ordering
- Vendor delivery schedules
- P&L performance tracking
- Compliance checklist status

**Receiving & Warehouse**
- Delivery schedules and dock status
- Invoice matching and discrepancy tracking
- Temperature checks for refrigerated deliveries
- Stock level visibility
- Expiration date tracking (FEFO)
- Put-away task completion

**Store Management Office**
- Multi-department performance dashboard
- Labor vs. sales optimization
- Shrink and waste across all departments
- Customer traffic patterns
- Department labor productivity
- Key operational metrics rollup

---

## Current Status

### POC Phase (Current)

**Objectives**:
1. Demonstrate Raspberry Pi can reliably display Power BI dashboards
2. Validate $50 hardware cost per unit
3. Implement zero-touch authentication (service principal)
4. Measure 72-hour uptime and recovery
5. Identify requirements for corporate deployment

**Success Criteria**:
- [ ] Power BI report displays full-screen
- [ ] Auto-refresh every 60 seconds
- [ ] 72-hour continuous operation without intervention
- [ ] Boot time <2 minutes
- [ ] Hardware cost <$60
- [ ] Stakeholder approval for pilot

**Timeline**:
- **Week 1**: Hardware setup, Azure config, token service
- **Week 2**: Pi deployment, 72-hour test, documentation
- **Next**: Stakeholder demo and pilot approval

---

### Production Phase (Future)

**Objectives**:
1. Deploy dedicated data displays to operational areas
2. Deploy 100+ units at <$150/unit total cost
3. Provide real-time operational metrics to all locations
4. Enable centralized remote management
5. Maintain 98%+ uptime across all locations

**Success Criteria**:
- 98% uptime across all devices
- <2 support incidents per location annually
- Zero user training required (touchless operation)
- Successful repurposing of existing display infrastructure
- 90-day deployment timeline
- Positive user feedback (improved data visibility)
- 70-90% cost savings vs commercial digital signage solutions

---

## Project Roadmap

### Phase 1: POC Development (2 weeks)
**Status**: In progress

**Activities**:
- Hardware setup, Azure config, token service
- Pi deployment, 72-hour test, documentation

---

### Phase 2: Stakeholder Demo (1 week)
**Status**: Pending POC completion

**Activities**:
- Prepare presentation and cost analysis
- Live demo with backup video
- Q&A preparation

---

### Phase 3: Pilot Approval (2-4 weeks)
**Status**: Planned

**Activities**:
- IT security review
- Network requirements gathering
- Pilot store selection (10 stores)
- Budget approval

---

### Phase 4: Production Pilot (6-8 weeks)
**Status**: Planned

**Activities**:
- 10-store deployment
- Monitoring and refinement
- Full rollout planning

---

### Phase 5: Production Rollout (14 weeks)
**Status**: Future

**Activities**:
- Phased deployment (3 waves: 30, 40, 30 stores)
- Centralized management
- Support team training
- Ongoing operations

---

## Value Proposition

### Financial Benefits

**Cost Comparison (100 displays, 5 years)**:
```
BEACON (baseline):                $85,973    $860/display
BEACON (optimized):               $30,961    $310/display
Commercial Digital Signage:       $150,000+  $1,500+/display
Desktop PC Repurposing:           $120,000+  $1,200+/display

Savings vs. Commercial:           74-79%
Savings vs. Desktop PCs:          40-74%
```

**Key Insight**: Repurpose existing monitors/TVs = $0 display hardware cost

---

### Operational Benefits

- **Lower device theft risk**: Less valuable hardware
- **No charging management**: Always-on, plugged in
- **Simpler user experience**: View-only, no navigation/training
- **Faster boot times**: ~2 min vs 5+ min tablets
- **Zero configuration drift**: No user interaction
- **Dedicated purpose**: Prevents non-work usage

---

### Data Visibility Value

- **Constant metrics visibility**: Improves team awareness
- **Real-time data**: Enables faster decision-making
- **Democratized access**: Operational intelligence for all teams
- **Reduced manual reporting**: Automated data distribution
- **Data-driven culture**: Encourages metrics-based decisions

---

### Food Safety Applicability (for applicable environments)

- **Touchless operation**: Eliminates cross-contamination risk
- **No cleaning protocols**: View-only design requires no sanitization
- **Sanitation compliance**: Supports food safety requirements

---

## Strategic Alignment

**Data-Driven Culture**: Democratizes access to real-time operational metrics across all teams

**Cost Optimization**: 85% reduction in display infrastructure costs enables broader deployment

**Technology Modernization**: Cloud-based, IoT-enabled, scalable solution

**Operational Excellence**: Real-time data visibility enables faster, more informed decision-making

**Employee Empowerment**: Gives frontline teams immediate visibility into performance and goals

**Touchless Operation**: Zero-interaction design ideal for any operational environment (including food safety-critical areas)

---

## Scope

### In Scope - POC

- Single Raspberry Pi device setup
- Personal Azure/Power BI integration
- Home network deployment
- Stakeholder documentation and demo
- Cost analysis and ROI projections

---

### In Scope - Production (Future)

- Multi-device centralized management
- Corporate network integration
- IT security review and compliance
- Store-specific data filtering
- Remote management tools

---

### Out of Scope

- Creating new Power BI reports (use existing reports)
- TV/monitor hardware procurement (use existing displays)
- Corporate network infrastructure changes (IT responsibility)
- Multi-site deployment during POC
- Customer-facing public displays (operational areas only)
- Interactive touchscreen functionality (view-only by design)

---

## Next Steps

### This Week
1. Complete POC hardware setup
2. Deploy personal Azure/Power BI integration
3. Run 72-hour reliability test
4. Document results

### Next Week
1. Create stakeholder presentation
2. Finalize cost analysis
3. Prepare live demo and backup video
4. Schedule stakeholder meeting

### Week 3
1. Present POC to stakeholders
2. Request pilot program approval
3. Discuss IT requirements
4. Identify pilot stores

### If Approved
1. Engage IT for security review
2. Plan corporate network integration
3. Develop remote management tools
4. Begin 10-store pilot deployment

---

## Related Documentation

- [Business Case](business-case.md) - Detailed business drivers, stakeholders, competitive analysis
- [Deployment Overview](../deployment/README.md) - Enterprise deployment phases and gates
- [Cost Analysis](../deployment/cost-analysis.md) - TCO models and ROI
- [GETTING-STARTED.md](../../GETTING-STARTED.md) - Technical setup guide
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - System architecture and design

---

**Last Updated**: 2025
**Review Date**: After POC completion
**Status**: Active Development
