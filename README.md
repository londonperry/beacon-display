# BEACON Display System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status: POC](https://img.shields.io/badge/Status-POC-blue)](docs/project/README.md)
[![Node.js 18+](https://img.shields.io/badge/Node.js-18%2B-green)](https://nodejs.org/)
[![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-Zero%202%20W-red)](docs/hardware/README.md)

**B**usiness **E**mbedded **A**nalytics **C**ontent **O**n **N**etwork

Open-source, low-cost Power BI dashboard display system for operational teams, back-office areas, and research projects.

## 🎯 Overview

Transform any existing monitor or TV into a self-managing, always-on dashboard display. BEACON delivers dedicated real-time data visibility at a fraction of traditional display solution costs, with superior uptime and zero-touch operation.

**Cost**: $50-150 per display (hardware only, repurpose existing monitors/TVs)
**Status**: Proof of Concept (contributions welcome!)
**Version**: 1.0.0
**License**: MIT

## ✨ Features

- 💰 **Low Cost**: $50-150 per display using Raspberry Pi Zero 2 W + existing monitors
- 🔒 **Secure**: Azure AD authentication with service principals, no password-based SSH
- 🔄 **Auto-Refresh**: Data updates every 60 seconds, tokens refresh every 50 minutes
- 🛡️ **Self-Healing**: Watchdog monitors and auto-recovers from failures
- 🚀 **Zero-Touch**: No user interaction required after initial setup
- 📱 **Multi-Device**: Supports Raspberry Pi Zero 2 W, Pi 4, Pi 5, and compatible SBCs
- 🌐 **Flexible**: Works with any Power BI workspace and custom reports
- 📊 **Real-Time**: Live dashboard updates without browser refresh

## 🎯 Use Cases

**Individual & Hobbyists**
- Personal home dashboards (weather, stocks, smart home metrics)
- Learning Power BI embedding and Azure authentication
- Raspberry Pi experimentation and IoT projects

**Small Business & Startups**
- Low-cost operations monitoring dashboards
- Department-specific metrics and KPI displays
- Cost-effective alternative to commercial digital signage

**Enterprise & Research**
- POC for large-scale dashboard deployments
- Testing Power BI embedding approaches
- Evaluating Raspberry Pi for operational displays
- Research and educational projects

## Quick Start

```bash
# Test with public Power BI sample (no setup required)
cd display-client
cp config-public-sample.json config.json
open index.html
```

## Documentation

### Quick Start
- **[Setup Guide](docs/setup/README.md)** - Complete POC deployment (6 hours, all phases)
- **[Troubleshooting](docs/troubleshooting/README.md)** - Common issues and quick diagnostics
- **[Architecture Overview](docs/architecture/README.md)** - System design and technical details

### Complete Documentation Index
📖 **[Browse All Documentation](docs/README.md)** - Complete index organized by audience and task

**Key Documents**:
| Document | Purpose |
|----------|---------|
| **[Setup Guide](docs/setup/README.md)** | 5-phase POC setup (browser → Pi deployment) |
| **[Architecture](docs/architecture/README.md)** | Technical design and authentication flow |
| **[Hardware Guide](docs/hardware/README.md)** | Device compatibility and specifications |
| **[Troubleshooting](docs/troubleshooting/README.md)** | Issues by component (token service, Pi, network, etc.) |
| **[Deployment Guide](docs/deployment/README.md)** | Enterprise rollout (pilot to 100+ locations) |
| **[Business Case](docs/project/business-case.md)** | ROI, requirements, stakeholder alignment |
| **[Cost Analysis](docs/deployment/cost-analysis.md)** | TCO models and financial justification |

## Prerequisites

**Hardware**: Raspberry Pi (Zero 2 W / 4 / 5) or compatible device ($15-60), 32GB+ microSD ($10), HDMI cable ($8), Power supply ($8-12)
**Accounts**: Azure (free tier), Power BI Pro or workspace access
**Software**: Node.js 18+, Raspberry Pi Imager
**Compatibility**: See [Hardware Guide](docs/hardware/README.md) for full device support list

## Project Structure

```
beacon-display/
├── token-service/       # Azure AD authentication service
├── display-client/      # Browser-based Power BI display
├── raspberry-pi/        # Pi setup and auto-start scripts
└── scripts/             # Deployment utilities
```

## 🔒 Security

BEACON implements a **service principal-based authentication model** with distinct security modes for POC and production environments.

**Key Practice**: Never commit `.env` or `config.json` files. Always use example templates.

For complete security information, requirements, vulnerability reporting, and best practices, see **[SECURITY.md](SECURITY.md)**.

## 🤝 Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding features, improving documentation, or helping with deployment scenarios, your help is appreciated.

**Getting Started:**
1. Read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
2. Review [Setup Guide](docs/setup/README.md) for setup
3. Check [existing issues](https://github.com/londonperry/beacon-display/issues) to avoid duplicates
4. Open an issue or discussion before major changes

**Contribution Areas:**
- 🐛 Bug fixes and issue resolution
- 📚 Documentation improvements
- 🧪 Testing infrastructure and test coverage
- ⚡ Performance optimization (especially for Pi Zero 2 W)
- 🚀 Raspberry Pi compatibility improvements
- 🏗️ Deployment automation
- 🔧 Enterprise features (monitoring, management, etc.)

## 📚 Documentation

**Complete documentation** organized by audience and task: **[Browse All Documentation](docs/README.md)**

- **[Setup Guide](docs/setup/README.md)** - Step-by-step POC setup (6 hours, 5 phases)
- **[Architecture](docs/architecture/README.md)** - System design and technical deep dive
- **[Hardware Guide](docs/hardware/README.md)** - Device support and specifications
- **[Troubleshooting](docs/troubleshooting/README.md)** - Common issues and diagnostics
- **[Deployment Guide](docs/deployment/README.md)** - Enterprise deployment (pilot to production)
- **[Business Case](docs/project/business-case.md)** - Business case and project scope
- **[Cost Analysis](docs/deployment/cost-analysis.md)** - TCO models and ROI
- **[SECURITY.md](SECURITY.md)** - Security model, vulnerabilities, best practices
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[CLAUDE.md](.claude/CLAUDE.md)** - AI assistant guidance

## 📊 Project Status

**Current Phase**: Proof of Concept
- [x] Core token service (Azure AD authentication)
- [x] Display client (Power BI embedding)
- [x] Raspberry Pi deployment scripts
- [ ] Automated testing infrastructure
- [ ] GitHub Actions CI/CD
- [ ] Multi-device management dashboard
- [ ] Enterprise monitoring and alerting

## 💬 Community

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions** (coming soon): Ask questions and share ideas
- **Security Issues**: Report vulnerabilities responsibly (see SECURITY.md)

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

BEACON is built on excellent open-source projects:
- [Express.js](https://expressjs.com/) - Web framework
- [MSAL Node](https://github.com/AzureAD/microsoft-authentication-library-for-js) - Azure AD authentication
- [Power BI Embedded Client](https://github.com/microsoft/PowerBI-JavaScript) - Power BI integration
- [Raspberry Pi OS](https://www.raspberrypi.com/software/) - Operating system

---

## 🚀 Quick Links

- **Setup**: [Setup Guide](docs/setup/README.md) - Complete POC deployment (6 hours)
- **Architecture**: [Architecture Overview](docs/architecture/README.md) - How it works
- **Hardware**: [Hardware Guide](docs/hardware/README.md) - Device options
- **Troubleshoot**: [Troubleshooting](docs/troubleshooting/README.md) - Fix issues fast
- **Deploy**: [Deployment Guide](docs/deployment/README.md) - Scale to enterprise
- **Business**: [Business Case](docs/project/business-case.md) - ROI and justification
- **Security**: [SECURITY.md](SECURITY.md) - Security model and best practices
- **Contribute**: [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

---

**Ready to get started?** 👉 **[Browse All Documentation](docs/README.md)** or go straight to **[Setup Guide](docs/setup/README.md)** for step-by-step instructions.
