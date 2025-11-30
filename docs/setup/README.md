# Setup & Installation Guide

> **Audience**: All users - hobbyists, developers, and IT staff
> **Purpose**: Complete setup guide for deploying BEACON from POC to production
> **Time**: 6-8 hours total across all phases

---

## Overview

BEACON setup follows a proven 5-phase approach that progressively adds complexity:

1. **Phase 1**: Browser Testing (30 min) - Test display client without any hardware
2. **Phase 2**: Azure Setup (2 hours) - Configure Azure AD and Power BI
3. **Phase 3**: Token Service (1 hour) - Run authentication service on your laptop
4. **Phase 4**: Raspberry Pi (2 hours) - Deploy to actual hardware
5. **Phase 5**: Validation (30 min) - Test and monitor performance

**Total Time**: ~6 hours
**Hardware Cost**: $43-50
**Difficulty**: Intermediate (no advanced coding required)

---

## Quick Start Decision Tree

**Are you new to BEACON?**
→ Start with [Phase 1: Browser Testing](poc-laptop.md)

**Do you have Azure/Power BI set up already?**
→ Yes → [Skip to Token Service](token-service.md)
→ No → [Azure Configuration Guide](azure-configuration.md)

**Ready to deploy to Raspberry Pi?**
→ [Raspberry Pi Deployment](raspberry-pi.md)

**Need to understand configuration options?**
→ [Configuration Reference](configuration-reference.md)

---

## Phase Overview

### Phase 1: Browser Testing (30 min)
**What**: Test display client in your browser using public Power BI sample
**Why**: Verify basic setup works before adding complexity
**Hardware Required**: None (laptop only)
**Details**: [POC Laptop Setup](poc-laptop.md)

### Phase 2: Azure & Power BI (2 hours)
**What**: Create Azure service principal and configure Power BI workspace
**Why**: Authenticate with Azure AD and generate embed tokens
**Complexity**: Medium (mostly UI clicks in Azure Portal)
**Details**: [Azure Configuration](azure-configuration.md)

### Phase 3: Token Service (1 hour)
**What**: Run Node.js authentication service on your laptop
**Why**: Generate embed tokens for Power BI reports
**Hardware Required**: Laptop with Node.js
**Details**: [Token Service Setup](token-service.md)

### Phase 4: Raspberry Pi (2 hours)
**What**: Deploy to Raspberry Pi with auto-start configuration
**Why**: Create dedicated hardware display
**Hardware Required**: Raspberry Pi Zero 2 W or similar
**Details**: [Raspberry Pi Deployment](raspberry-pi.md)

### Phase 5: Validation (30 min)
**What**: Test auto-refresh, token renewal, and recovery
**Why**: Ensure system is production-ready
**Details**: [72-hour validation test](raspberry-pi.md#phase-5-validation)

---

## Prerequisites

### For All Phases
- [ ] Power BI account (Pro or Premium workspace)
- [ ] Access to Azure Active Directory (admin approval may be needed)
- [ ] Internet connection

### For Phase 3+
- [ ] Node.js 18+ installed
- [ ] npm (comes with Node.js)

### For Phase 4+
- [ ] Raspberry Pi device (Zero 2 W, Pi 4, or Pi 5)
- [ ] microSD card (32GB Class 10 recommended)
- [ ] Power supply (5V 2.5A minimum)
- [ ] HDMI cable and monitor/TV
- [ ] WiFi access or Ethernet adapter

---

## System Requirements

### Minimum (POC)
```
CPU:      Dual-core
RAM:      512MB
Storage:  32GB microSD / disk
Network:  2.4GHz WiFi or Ethernet
Display:  HDMI 1080p
```

### Recommended (Small deployments)
```
CPU:      Quad-core
RAM:      2GB
Storage:  64GB microSD
Network:  5GHz WiFi or Ethernet
Display:  HDMI 2K
```

### Production (Large deployments)
See [Hardware Guide](../hardware/README.md) for enterprise recommendations

---

## Network Requirements

### During Setup (POC)
```
Pi → Laptop:3000              (token service)
Pi → login.microsoftonline.com (Azure AD)
Pi → api.powerbi.com          (Power BI API)
Pi → app.powerbi.com          (Power BI UI)
Pi → cdn.jsdelivr.net         (Power BI JS library)
```

### For Production
See [DEPLOYMENT.md](../deployment/README.md#network-requirements) for enterprise network setup

---

## Troubleshooting During Setup

**Issue**: Can't connect to token service?
→ [Display Client Troubleshooting](../troubleshooting/display-client.md)

**Issue**: Token service errors?
→ [Token Service Troubleshooting](../troubleshooting/token-service.md)

**Issue**: Pi won't boot?
→ [Raspberry Pi Troubleshooting](../troubleshooting/raspberry-pi.md)

**Issue**: Network problems?
→ [Network Troubleshooting](../troubleshooting/network.md)

---

## Timeline Summary

| Phase | Duration | Key Tasks |
|-------|----------|-----------|
| **1: Browser** | 30 min | Download sample, test display client |
| **2: Azure** | 2 hours | Create service principal, configure Power BI |
| **3: Token Service** | 1 hour | Install Node.js, start auth service |
| **4: Pi Deployment** | 2 hours | Flash SD card, deploy files, configure |
| **5: Validation** | 30 min | Test refresh, uptime, recovery |
| **Total** | ~6 hours | Complete POC ready for demo |

---

## Next Steps

**Ready to begin?**

1. Start with **[Phase 1: Browser Testing](poc-laptop.md)** if you're new
2. Jump to **[Token Service](token-service.md)** if Azure is already configured
3. Go straight to **[Raspberry Pi Deployment](raspberry-pi.md)** if everything is ready

**Want to learn more first?**
- [Architecture Overview](../architecture/README.md) - Understand how the system works
- [Hardware Guide](../hardware/README.md) - Device specifications and options
- [Project Definition](../project/README.md) - Business context and goals

---

## Related Documentation

- **[POC Laptop Setup](poc-laptop.md)** - Phase 1 browser testing
- **[Azure Configuration](azure-configuration.md)** - Phase 2 Azure & Power BI setup
- **[Token Service Setup](token-service.md)** - Phase 3 authentication service
- **[Raspberry Pi Deployment](raspberry-pi.md)** - Phase 4-5 hardware deployment
- **[Configuration Reference](configuration-reference.md)** - Config file schema and options
- **[Troubleshooting Overview](../troubleshooting/README.md)** - Common issues
- **[Architecture Overview](../architecture/README.md)** - Technical details
