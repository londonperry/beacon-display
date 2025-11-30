# BEACON Display Documentation

Complete documentation for the BEACON Display System - low-cost Power BI dashboard displays using Raspberry Pi.

**Status**: Complete refactoring to organized, topic-based documentation
**Last Updated**: 2025-11-30
**Version**: 2.0 (Refactored structure)

---

## 🚀 Quick Start by Audience

### 👤 Hobbyists & Individual Users
**Goal**: Personal dashboards for home, learning, experimentation

1. **Start Here**: [POC Laptop Setup](setup/poc-laptop.md) - Test in browser first (30 min)
2. **Add Authentication**: [Azure Configuration](setup/azure-configuration.md) - Set up Azure AD (2 hours)
3. **Run Service**: [Token Service Setup](setup/token-service.md) - Start auth service (1 hour)
4. **Deploy Hardware**: [Raspberry Pi Deployment](setup/raspberry-pi.md) - Deploy to Pi (2 hours)
5. **Validate**: Run 72-hour test and you're done!

**Total Time**: ~6 hours | **Cost**: $43-50 | **Difficulty**: Intermediate

---

### 🏢 Small Business & Startups
**Goal**: Low-cost operational dashboards, department KPIs, 5-10 locations

1. **Understand the Project**: [Project Overview](project/README.md) - Vision and goals (10 min)
2. **Learn the Business Case**: [Business Case](project/business-case.md) - ROI and stakeholder alignment (30 min)
3. **Complete POC**: Follow hobbyist path above (6 hours)
4. **Plan Pilot**: [Deployment Planning](deployment/planning.md) - Team, timeline, prerequisites (2 hours)
5. **Run Pilot**: [Pilot Deployment](deployment/pilot.md) - Deploy 10-50 devices (6-8 weeks)
6. **Scale Up**: [Operations Guide](deployment/operations.md) - Support and maintenance

**Total First Project**: 2-3 weeks | **Cost**: $3,500-4,000 | **Difficulty**: Intermediate-Advanced

---

### 🏭 Enterprise & IT Teams
**Goal**: Large-scale dashboard deployment, 100+ locations, enterprise integration

1. **Make the Case**: [Business Case](project/business-case.md) - ROI, requirements, competitive analysis (1 hour)
2. **Understand Technical Architecture**: [Architecture Overview](architecture/README.md) - System design (1 hour)
3. **Plan Enterprise Deployment**: [Deployment Planning](deployment/planning.md) - Team, timeline, infrastructure (2-3 hours)
4. **Cost Analysis**: [Cost Analysis](deployment/cost-analysis.md) - TCO models and ROI scenarios (1 hour)
5. **Execute POC**: Complete hobbyist path (6 hours)
6. **Plan Pilot**: [Pilot Deployment](deployment/pilot.md) - 10-50 device test (1-2 weeks planning)
7. **Production Rollout**: [Production Rollout](deployment/production.md) - 100+ device deployment (8-12 weeks execution)
8. **Operations**: [Operations Guide](deployment/operations.md) - Support, maintenance, lifecycle (ongoing)

**Total Program**: 4-6 months | **Cost**: $31K-86K over 5 years | **Difficulty**: Advanced

---

## 📋 Quick Start by Task

### 🛠️ "I want to set up BEACON"
**Start with [Setup Overview](setup/README.md)**

Then follow the 5 phases:
1. [Phase 1: Browser Testing](setup/poc-laptop.md) - No hardware needed
2. [Phase 2: Azure Setup](setup/azure-configuration.md) - Configure Power BI
3. [Phase 3: Token Service](setup/token-service.md) - Authentication service
4. [Phase 4: Raspberry Pi](setup/raspberry-pi.md) - Deploy to hardware
5. [Phase 5: Validation](setup/raspberry-pi.md#phase-5-validation) - Test for 72 hours

---

### 🔧 "Something isn't working"
**Start with [Troubleshooting Overview](troubleshooting/README.md)**

Then choose by component:
- [Token Service Issues](troubleshooting/token-service.md) - Auth and token generation problems
- [Display Client Issues](troubleshooting/display-client.md) - Browser and rendering problems
- [Raspberry Pi Issues](troubleshooting/raspberry-pi.md) - Hardware and boot problems
- [Network Issues](troubleshooting/network.md) - Connectivity and firewall problems

---

### 🏗️ "I want to deploy at scale"
**Start with [Deployment Overview](deployment/README.md)**

Then follow by phase:
1. [Planning Guide](deployment/planning.md) - Team, timeline, infrastructure
2. [Pilot Deployment](deployment/pilot.md) - 10-50 device pilot program
3. [Production Rollout](deployment/production.md) - 100+ device deployment
4. [Operations Guide](deployment/operations.md) - Support and maintenance
5. [Cost Analysis](deployment/cost-analysis.md) - TCO and budget planning

---

### 📊 "I need business justification"
**Start with [Project Overview](project/README.md)**

Then deep-dive:
1. [Business Case](project/business-case.md) - ROI, requirements, competitive analysis
2. [Cost Analysis](deployment/cost-analysis.md) - 5-year TCO models
3. [Deployment Planning](deployment/planning.md) - Timeline and resource requirements
4. [Architecture Overview](architecture/README.md) - Technical feasibility

---

## 📚 Complete Documentation Index

### Setup & Installation
| Document | Duration | Purpose |
|----------|----------|---------|
| **[Setup Overview](setup/README.md)** | 5 min | Prerequisites, phases overview, quick decisions |
| **[Phase 1: POC Laptop](setup/poc-laptop.md)** | 30 min | Test display client in browser (no hardware) |
| **[Phase 2: Azure Config](setup/azure-configuration.md)** | 2 hours | Create service principal and configure Power BI |
| **[Phase 3: Token Service](setup/token-service.md)** | 1 hour | Install and run Node.js authentication service |
| **[Phase 4: Raspberry Pi](setup/raspberry-pi.md)** | 2.5 hours | Deploy to Pi and validate for 72 hours |
| **[Configuration Reference](setup/configuration-reference.md)** | Reference | Complete schema for all config options |

### Architecture & Design
| Document | Audience | Purpose |
|----------|----------|---------|
| **[Architecture Overview](architecture/README.md)** | Decision makers | System design and principles |
| **[Components](architecture/components.md)** | Developers | Token service, display client, scripts details |
| **[Authentication](architecture/authentication.md)** | Security engineers | Azure AD integration and token flow |
| **[Security Model](architecture/security-model.md)** | Security teams | POC vs Production security models |
| **[Data Flow](architecture/data-flow.md)** | Developers | Request lifecycle and refresh cycles |

### Hardware
| Document | Audience | Purpose |
|----------|----------|---------|
| **[Hardware Overview](hardware/README.md)** | All users | Device compatibility and selection guide |
| **[Raspberry Pi](hardware/raspberry-pi.md)** | Pi users | Zero 2W, Pi 4, Pi 5 detailed specs |
| **[Alternative Devices](hardware/alternative-devices.md)** | Enterprise | Intel NUC, Orange Pi, other options |
| **[Optimization](hardware/optimization.md)** | Operators | Memory, network, thermal tuning |

### Deployment
| Document | Audience | Purpose |
|----------|----------|---------|
| **[Deployment Overview](deployment/README.md)** | IT managers | Strategy and phases |
| **[Planning Guide](deployment/planning.md)** | Project managers | Prerequisites, timeline, team roles |
| **[Pilot Deployment](deployment/pilot.md)** | IT staff | 10-50 device pilot program |
| **[Production Rollout](deployment/production.md)** | IT operations | 100+ device phased deployment |
| **[Cost Analysis](deployment/cost-analysis.md)** | Finance/IT leadership | TCO models and ROI |
| **[Operations Guide](deployment/operations.md)** | IT support | Support, maintenance, lifecycle |

### Troubleshooting
| Document | Audience | Purpose |
|----------|----------|---------|
| **[Troubleshooting Overview](troubleshooting/README.md)** | All users | Diagnostic approach and symptom index |
| **[Token Service](troubleshooting/token-service.md)** | Developers, IT | Auth failures, token issues |
| **[Display Client](troubleshooting/display-client.md)** | All users, IT | Blank screens, loading failures |
| **[Raspberry Pi](troubleshooting/raspberry-pi.md)** | Pi users | Boot, memory, thermal issues |
| **[Network](troubleshooting/network.md)** | Network admins | Connectivity, firewall, DNS |

### Project Information
| Document | Audience | Purpose |
|----------|----------|---------|
| **[Project Overview](project/README.md)** | Stakeholders | Vision, goals, roadmap |
| **[Business Case](project/business-case.md)** | Executives | ROI, requirements, competitive analysis |

---

## 🔒 Security & Compliance

- **[Security Policy](../SECURITY.md)** (root) - Security model, vulnerability reporting, best practices
- **[Security Architecture](architecture/security-model.md)** - Technical security implementation
- **[Deployment Security](deployment/planning.md#security-hardening)** - Enterprise security checklist

---

## 🤝 Contributing

- **[Contributing Guidelines](../CONTRIBUTING.md)** (root) - How to contribute code and docs
- **[Project Context for AI](../.claude/CLAUDE.md)** (root) - Guidance for AI assistants working on codebase

---

## 🔗 External Links

- **[GitHub Repository](https://github.com/londonperry/beacon-display)** - Source code
- **[Report Issues](https://github.com/londonperry/beacon-display/issues)** - Bug reports and feature requests
- **[License](../LICENSE)** - MIT License (root)

---

## 💡 Tips for Finding Information

### By Component
If you know which part has the issue:
- **Token Service** → [Token Service Setup](setup/token-service.md) or [Troubleshooting](troubleshooting/token-service.md)
- **Display Client** → [Configuration](setup/configuration-reference.md) or [Troubleshooting](troubleshooting/display-client.md)
- **Raspberry Pi** → [Deployment](setup/raspberry-pi.md) or [Troubleshooting](troubleshooting/raspberry-pi.md)
- **Network** → [Architecture](architecture/data-flow.md) or [Troubleshooting](troubleshooting/network.md)

### By Phase
What phase are you in?
- **Learning**: [Project Overview](project/README.md) → [Architecture](architecture/README.md)
- **Setting Up**: [Setup Overview](setup/README.md) → specific phase
- **Troubleshooting**: [Troubleshooting Overview](troubleshooting/README.md) → component
- **Deploying**: [Deployment Overview](deployment/README.md) → your scale

### By Audience
What's your role?
- **Hobbyist/Developer** → [Setup Guide](setup/README.md)
- **IT Administrator** → [Deployment Guide](deployment/README.md) then [Operations](deployment/operations.md)
- **IT Manager** → [Business Case](project/business-case.md) then [Planning](deployment/planning.md)
- **Security Team** → [Security Model](architecture/security-model.md)
- **Finance/Leadership** → [Cost Analysis](deployment/cost-analysis.md)

### Quick Search
Use your browser's `/` key in GitHub to search across all documentation.

---

## 📖 Documentation Statistics

- **Total Documentation**: 28 files, 8,000+ lines
- **Average File Length**: ~285 lines (readable in one sitting)
- **Complete Coverage**: All aspects covered from business case to operations
- **Audience Targeting**: Each file specifies intended audience
- **Relative Links**: All cross-references are internal links

---

## 🎯 Common Paths Through Documentation

### Path 1: Complete Beginner (30 hours)
1. [Project Overview](project/README.md) - 10 min
2. [Setup Overview](setup/README.md) - 5 min
3. [Phase 1: POC Laptop](setup/poc-laptop.md) - 30 min
4. [Phase 2: Azure Config](setup/azure-configuration.md) - 2 hours
5. [Phase 3: Token Service](setup/token-service.md) - 1 hour
6. [Phase 4: Raspberry Pi](setup/raspberry-pi.md) - 2.5 hours
7. [Architecture Overview](architecture/README.md) - 1 hour
8. Total: ~8 hours hands-on, plus waiting time

### Path 2: Experienced Developer (15 hours)
1. [Business Case](project/business-case.md) - 30 min
2. [Architecture Overview](architecture/README.md) - 1 hour
3. [Setup Overview](setup/README.md) - 5 min
4. Skim: [Phase 2](setup/azure-configuration.md), [3](setup/token-service.md), [4](setup/raspberry-pi.md) - 3 hours
5. [Deployment Planning](deployment/planning.md) - 1.5 hours
6. Total: ~6 hours hands-on

### Path 3: Enterprise Decision Maker (8 hours)
1. [Business Case](project/business-case.md) - 1 hour
2. [Cost Analysis](deployment/cost-analysis.md) - 1 hour
3. [Deployment Planning](deployment/planning.md) - 1 hour
4. [Pilot Deployment](deployment/pilot.md) - 0.5 hour
5. Live Demo - 4 hours
6. Total: 7.5 hours

---

## 📞 Need Help?

- **Setup Issues?** → [Setup Troubleshooting](troubleshooting/README.md)
- **Technical Questions?** → [Architecture](architecture/README.md)
- **Deployment Planning?** → [Deployment Overview](deployment/README.md)
- **Cost Justification?** → [Cost Analysis](deployment/cost-analysis.md)
- **Security Questions?** → [Security Model](architecture/security-model.md)
- **Found a Bug?** → [GitHub Issues](https://github.com/londonperry/beacon-display/issues)

---

**Welcome to BEACON Display! Start with the [Quick Start section](#-quick-start-by-audience) that matches your role above.**
