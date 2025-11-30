# BEACON Architecture Overview

**Audience:** For developers and technical stakeholders

This document provides a high-level overview of the BEACON system architecture, design principles, and technical approach.

---

## System Overview

```
┌─────────────────────────────────────────┐
│  Personal Network (POC)                 │
│                                         │
│  ┌─────────────┐       ┌──────────────┐ │
│  │ Raspberry Pi│──────▶│ Your Laptop  │ │
│  │  (Display)  │       │(Token Service) │
│  └─────────────┘       └──────┬───────┘ │
└────────────────────────────────┼────────┘
                                 │
                           Internet
                                 │
               ┌─────────────────┼──────────────┐
               │                 │              │
         ┌──────▼─────┐   ┌──────▼──────┐  ┌───▼────┐
         │  Azure AD  │   │  Power BI   │  │  CDN   │
         └────────────┘   └─────────────┘  └────────┘
```

## Design Principles

### 1. **Simplicity First**
- Minimal dependencies (Power BI Client from CDN)
- Browser-based rendering (no native compilation)
- Pure HTML5/ES6 JavaScript
- No transpilation or build process required

### 2. **Cost Optimization**
- Target: $50 per device (POC), $150 per device (production)
- Leverage existing displays (no new hardware purchase)
- Open-source components
- Low power consumption (~$2/year electricity)

### 3. **Zero-Touch Operation**
- Auto-start on boot
- Self-healing via watchdog
- Automatic token refresh
- Daily restart for memory cleanup
- No manual intervention required

### 4. **Security by Design**
- Service principal authentication (not user-based)
- Read-only permissions
- Token expiry and renewal
- Network segmentation (production)
- Secrets management via environment variables or Key Vault

### 5. **Hardware Abstraction**
- Single codebase across all devices
- Auto-detection of hardware capabilities
- Dynamic resource allocation
- Graceful degradation on constrained devices

### 6. **Production-Ready Path**
- Clear migration from POC to production
- Documented security hardening steps
- Scalable architecture (1 to 100+ devices)
- Enterprise deployment guides

---

## High-Level Architecture

BEACON uses a **two-component architecture**:

### Component 1: Token Service
**Location:** Your laptop (POC) or company infrastructure (production)
**Purpose:** Authenticates with Azure AD and generates Power BI embed tokens
**Technology:** Node.js, Express, MSAL

### Component 2: Display Client
**Location:** Raspberry Pi (Chromium browser)
**Purpose:** Embeds and displays Power BI reports
**Technology:** HTML5, JavaScript ES6+, Power BI Client library

These components communicate over HTTP (POC) or HTTPS (production) with a simple REST API.

---

## Software Stack

### Operating System
**Raspberry Pi OS Lite (64-bit)**
- Based on Debian 12 "Bookworm"
- ARM64 architecture
- No desktop environment (headless)
- ~1GB installed size

### Display Stack
- **Chromium:** Kiosk mode (full-screen, no UI)
- **Power BI Client:** v2.22.3 from CDN
- **JavaScript:** ES6+ (no transpilation)
- **Auto-start:** systemd service

### Token Service Stack
- **Node.js:** 18 LTS or 20 LTS
- **Express:** Web server framework
- **MSAL:** Microsoft Authentication Library
- **HTTPS:** Production only (POC uses HTTP locally)

---

## Performance Characteristics

### Boot Sequence

```
Power On               T+0s
├─ Bootloader         T+5s
├─ Linux Kernel       T+15s
├─ System Services    T+30s
├─ Network Ready      T+45s
├─ X Server           T+60s
├─ Chromium Launch    T+75s
├─ Fetch Token        T+85s
├─ Load Report        T+90s
└─ Fully Rendered     T+105s

Total: ~2 minutes
```

### Resource Usage

**Idle (after boot):**
- Memory: 200MB (40%)
- CPU: 5-10%
- Temp: 40-45°C

**Active Display:**
- Memory: 350MB (70%)
- CPU: 30-50%
- Temp: 50-55°C

**Peak Load:**
- Memory: 450MB (90% - watchdog restarts if >85%)
- CPU: 80-100%
- Temp: 60°C

---

## Constraints & Limitations

### Hardware Constraints
- **RAM:** 512MB total (must stay <400MB on Pi Zero 2 W)
- **WiFi:** 2.4GHz only (no 5GHz on Pi Zero 2 W)
- **CPU:** Single-core performance for complex reports
- **Storage:** No battery backup

### Network Constraints
- Requires internet access for Azure AD and Power BI
- Token service must be reachable from display
- ~100MB daily bandwidth
- Corporate networks may need firewall rules

### Power BI Constraints
- Requires Pro or Premium workspace
- Service principal must be workspace Member
- Cannot use "My Workspace"
- Row-level security required for multi-tenancy

### Development Constraints
- Token service availability (laptop must be on for POC)
- Client secret expires every 12 months
- Limited debugging on Pi (remote logs via SSH)

---

## Why This Architecture?

### Browser-Based Display
- **Pros:** No native app development, works on any device with Chromium, automatic Power BI updates
- **Cons:** Requires modern browser, memory overhead, limited offline capability

### Service Principal Authentication
- **Pros:** No user interaction, programmatic access, workspace-scoped permissions
- **Cons:** Secret rotation required, setup complexity

### Raspberry Pi Hardware
- **Pros:** Low cost ($15-75), fanless, small form factor, community support
- **Cons:** Limited RAM, WiFi range, single-core performance

### Node.js Token Service
- **Pros:** Easy deployment, MSAL library support, cloud-portable
- **Cons:** Must be always-on for POC, requires Node.js runtime

---

## Related Documentation

- **[Components](components.md)** - Detailed component descriptions and file structure
- **[Authentication](authentication.md)** - Azure AD integration and token flow
- **[Security Model](security-model.md)** - POC vs Production security requirements
- **[Data Flow](data-flow.md)** - Request flow and token lifecycle
- **[Hardware Guide](../hardware/README.md)** - Supported devices and specifications
- **[Troubleshooting](../troubleshooting/README.md)** - Common issues and diagnostics

---

**Last Updated:** 2025-11-30
