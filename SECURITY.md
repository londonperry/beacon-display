# Security Policy

This document outlines the security model, practices, and incident reporting procedures for the BEACON Display project.

---

## 📋 Table of Contents

1. [Security Overview](#security-overview)
2. [Deployment Modes](#deployment-modes)
3. [Authentication & Authorization](#authentication--authorization)
4. [Secret Management](#secret-management)
5. [Network Security](#network-security)
6. [SSH & Access Control](#ssh--access-control)
7. [Vulnerability Reporting](#vulnerability-reporting)
8. [Dependency Security](#dependency-security)
9. [Security Checklist](#security-checklist)

---

## 🔒 Security Overview

BEACON implements a **service principal-based authentication model** using Azure AD. The system is designed to operate securely in both development (POC) and enterprise (production) environments, with distinct security requirements for each deployment mode.

**Key Security Principles**:
- ✅ Secrets never committed to version control
- ✅ Service principals (app identity, not user credentials)
- ✅ Least privilege access (read-only, workspace-scoped)
- ✅ Token expiry and automatic renewal
- ✅ Environment-specific security models
- ✅ No user interaction required (zero-trust after deployment)

---

## 🔐 Deployment Modes

BEACON supports two distinct security models based on deployment context.

### POC (Proof of Concept) - Acceptable Security

**When**: Local development, single device testing, non-production environments

**Configuration**:

| Component | POC Setting | Rationale |
|-----------|------------|-----------|
| **Network** | Home WiFi (WPA2) | Isolated development environment |
| **Token Service** | Laptop HTTP (port 3000) | Local network only, no internet exposure |
| **Azure Credentials** | `.env` file | Not committed, acceptable for development |
| **SSH** | Password-based | Convenient for single developer |
| **Certificates** | Self-signed or none | No external certificate infrastructure needed |
| **Firewall** | Home router default | Sufficient isolation for POC |

**Security Model**:
```
┌─────────────────────────────────────────┐
│  Personal Network (POC)                 │
│                                         │
│  ┌─────────────┐       ┌──────────────┐ │
│  │ Raspberry Pi│──HTTP─│ Laptop       │ │
│  │  (Display)  │       │(Token Service) │
│  └─────────────┘       └──────┬───────┘ │
└────────────────────────────────┼────────┘
                                 │
                           Internet (for Azure/PBI)
```

✅ **Acceptable**:
- HTTP for local token service
- Secrets in `.env` file (never committed)
- Password-based SSH for single user
- Home WiFi WPA2 encryption
- Limited credential exposure

### Production - Required Security

**When**: Enterprise deployment, multiple devices, customer-facing environments, compliance requirements

**Configuration**:

| Component | Production Setting | Rationale |
|-----------|-------------------|-----------|
| **Network** | Dedicated IoT VLAN (802.1X) | Network segmentation and isolation |
| **Token Service** | Company server HTTPS | Enterprise infrastructure, certificate-backed |
| **Azure Credentials** | Azure Key Vault | Centralized secret management, audit logging |
| **SSH** | Key-based only | Enhanced security, auditability |
| **Certificates** | Valid CA certificate | Enterprise-trusted, no self-signed |
| **Firewall** | Explicit inbound/outbound rules | Zero-trust network architecture |
| **Monitoring** | Centralized SIEM | Audit logging and alerts |

**Security Model**:
```
┌─────────────────────────────────────┐
│  Corporate Network                  │
│                                     │
│  ┌──────────────┐  Secure Token     │
│  │ Raspberry Pi ├────────────────── ┤──────┐
│  │   (VLAN)     │  (HTTPS + Key     │      │
│  └──────────────┘   Vault)          │      │
│       ↓                             │      │
│  IoT VLAN                           │      │
│  (Segmented, 802.1X)                │      │
└─────────────────────────────────────┘      │
                                             │
                   ┌─────────────────────────┘
                   │
            ┌──────▼───────────┐
            │  Azure Key Vault │
            │  (Secrets)       │
            ├──────────────────┤
            │  Azure AD        │
            │  (Auth)          │
            ├──────────────────┤
            │  Power BI        │
            │  (Reports)       │
            └──────────────────┘
```

✅ **Required**:
- HTTPS with valid certificates
- Secrets in Azure Key Vault (encrypted, audited)
- Key-based SSH only (no passwords)
- Dedicated IoT VLAN with 802.1X authentication
- Firewall rules (explicit allow lists)
- Centralized audit logging
- Regular security reviews
- Annual secret rotation

---

## 🔐 Authentication & Authorization

### Service Principal Architecture

BEACON uses **Azure AD Service Principals** (app identity, not user accounts) for authentication.

**Why Service Principals**:
- ✅ No human user credentials needed
- ✅ Application-level permissions
- ✅ Workspace-scoped access
- ✅ Automatic token handling
- ✅ Audit trail for all access

### Authentication Flow

```
1. Display boots → Loads index.html
2. JavaScript requests embed token
3. Token Service (laptop/cloud) handles request
4. Token Service authenticates to Azure AD
   └─ Using: CLIENT_ID + CLIENT_SECRET
5. Azure AD validates service principal
   └─ Returns: Access Token (Azure AD)
6. Token Service requests embed token from Power BI
   └─ Using: Access Token + workspace/report IDs
7. Power BI validates request
   └─ Returns: Embed Token (1-hour validity)
8. Token Service sends to Display
9. Display embeds Power BI report
10. Report displays with auto-refresh (60 sec)
11. Automatic token renewal (every 50 min)
```

### Access Control Model

**Service Principal Permissions** (POC Setup):

1. **Azure AD**:
   - Type: Service Principal (single tenant)
   - Permissions: Microsoft Graph (minimal)
   - Scope: Limited to Power BI operations

2. **Power BI**:
   - Permission: `Report.Read.All` (Application permission)
   - Type: Read-only (no write/delete)
   - Scope: Workspace-scoped (not tenant-wide)
   - Role: Workspace Member (minimum required)

**Access Restrictions**:
- ❌ Cannot use "My Workspace" (personal workspace)
- ❌ Cannot use Pro workspace without premium capacity
- ❌ Cannot write/delete reports or datasets
- ✅ Can only read assigned workspace content

---

## 🔑 Secret Management

### Types of Secrets

| Secret | Value | Format | Storage | Rotation |
|--------|-------|--------|---------|----------|
| **TENANT_ID** | Azure AD tenant ID | UUID | `.env.example` (template) | N/A |
| **CLIENT_ID** | App registration ID | UUID | `.env.example` (template) | N/A |
| **CLIENT_SECRET** | App secret value | String | `.env` file (POC) or Key Vault (Prod) | 12 months |
| **Private Keys** | SSH key pair | PEM file | `~/.ssh/id_rsa` (key-based) | On rotation |
| **Token Values** | Azure AD/Power BI tokens | JWT | Runtime memory only | Auto-refresh |

### POC Secret Handling

**`.env` File** (Never Commit):

```bash
# .env - NEVER commit this file
# Use .env.example as template instead

TENANT_ID=your-tenant-id
CLIENT_ID=your-client-id
CLIENT_SECRET=your-secret-value-here
PORT=3000
NODE_ENV=development
```

**Safe Practices**:
1. ✅ Copy from `.env.example` as template
2. ✅ Add to `.gitignore` (prevent commits)
3. ✅ Never share via email or chat
4. ✅ Keep locally on development machine
5. ✅ Delete when no longer needed
6. ✅ Rotate annually (12-month expiry)

**Getting CLIENT_SECRET**:
1. Go to [portal.azure.com](https://portal.azure.com)
2. Navigate to: Azure Active Directory → App registrations → Your app
3. Select: **Certificates & secrets** → **Client secrets**
4. Click: **+ New client secret**
5. Set expiry: **12 months**
6. **Copy immediately** (cannot view again)
7. Paste into `.env` file

### Production Secret Handling

**Azure Key Vault** (Required for Production):

```yaml
Key Vault: beacon-display-secrets
├─ tenant-id
├─ client-id
├─ client-secret (auto-rotated annually)
├─ api-key (if applicable)
└─ ssh-private-key (backed up)
```

**Access Control**:
- ✅ Managed identity for token service
- ✅ RBAC (Role-Based Access Control)
- ✅ Audit logging enabled
- ✅ Time-limited access tokens
- ✅ No direct secret viewing (audit trail)

**Implementation**:
1. Create Azure Key Vault
2. Store secrets with expiry dates
3. Enable audit logging
4. Configure managed identities
5. Set up automatic rotation
6. Document access procedures

### Secret Rotation

**POC Rotation** (Every 12 months):

```bash
# On Azure Portal:
1. Azure AD → App registrations → BEACON-Display-POC
2. Certificates & secrets → + New client secret
3. Delete old secret (expired after 12 months)
4. Update .env file with new secret
5. Test token service: curl http://localhost:3000/health
```

**Production Rotation**:
- Automated via Key Vault
- Annual schedule (or on-demand)
- Zero-downtime (secrets retrieved at runtime)
- Audit trail recorded
- No manual intervention needed

---

## 🌐 Network Security

### POC Network

**Topology**:
```
Home Router (192.168.1.1 / default gateway)
├─ Laptop (192.168.1.100) - Token Service HTTP:3000
├─ Raspberry Pi (192.168.1.x) - Display Client
└─ Other devices
```

**Outbound Access Required**:
- `login.microsoftonline.com:443` (Azure AD authentication)
- `api.powerbi.com:443` (Power BI API)
- `app.powerbi.com:443` (Power BI content)
- `cdn.jsdelivr.net:443` (Power BI JavaScript library)

**Firewall Rules**:
- Home router default settings (sufficient)
- WPA2 WiFi encryption required
- No open wireless networks

### Production Network

**IoT VLAN Configuration**:

Provide to network security team:

```
BEACON Display IoT Network Requirements

VLAN Configuration:
├─ Dedicated IoT VLAN (isolated from corporate network)
├─ VLAN Name: IoT-BEACON or IT-defined
├─ Addressing: DHCP with MAC reservations
└─ Authentication: 802.1X with certificates OR WPA2-Enterprise

Devices:
├─ Count: ~100 × Raspberry Pi Zero 2 W
├─ MAC addresses: Provided in bulk
└─ Hostnames: beacon-display-001, beacon-display-002, etc.

Required Outbound Access:
├─ 192.168.x.x:3000 (internal token service - HTTPS)
├─ login.microsoftonline.com:443 (Azure AD)
├─ api.powerbi.com:443 (Power BI API)
├─ app.powerbi.com:443 (Power BI content)
├─ cdn.jsdelivr.net:443 (Power BI JS library)
└─ apt.raspberrypi.com:443 (OS updates)

Inbound Access:
└─ SSH (TCP 22) from Management VLAN only
   (IT team for updates/troubleshooting)

Outbound Blocked:
├─ No direct internet (via gateway only)
├─ No peer-to-peer between displays
└─ No management traffic outside VLAN

Bandwidth:
├─ Per device average: 100 KB/min
├─ Peak (boot/refresh): 5 Mbps
├─ Monthly: ~1.5 GB/device
└─ 100 devices: ~150 GB/month

Security:
├─ Network segmentation (dedicated VLAN)
├─ Firewall between VLANs
├─ Audit logging for all access
└─ Intrusion detection (optional)
```

**Firewall Rules** (Production):

```
# Inbound to IoT VLAN
DENY    All         (default deny)
ALLOW   SSH:22      from Management VLAN only

# Outbound from IoT VLAN
ALLOW   HTTPS:443   to Azure (login.microsoftonline.com, api.powerbi.com, cdn.jsdelivr.net)
ALLOW   TCP:3000    to internal token service (HTTPS)
ALLOW   DNS:53      to corporate DNS only
DENY    All others  (default deny)
```

---

## 🔐 SSH & Access Control

### POC SSH (Password-Based)

**Initial Setup**:
1. Raspberry Pi Imager sets username: `pi`, password: (your choice)
2. First SSH connection:
   ```bash
   ssh pi@<pi-ip-address>
   # Enter password when prompted
   ```
3. Accept host key fingerprint (first time only)

**Security**:
- ⚠️ Password-based (acceptable for POC)
- ✅ Home network isolation
- ✅ Non-routable from internet
- ✅ SSH uses encryption (SSH protocol)

### Production SSH (Key-Based)

**Setup**:

1. **Generate key pair** (on management workstation):
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/beacon-display -C "beacon-display-key"
   # Output:
   # ~/.ssh/beacon-display (private key - keep secret)
   # ~/.ssh/beacon-display.pub (public key - distribute)
   ```

2. **Deploy public key** to all Raspberry Pi devices:
   ```bash
   # During initial provisioning
   # Add public key to /home/pi/.ssh/authorized_keys
   cat ~/.ssh/beacon-display.pub >> /home/pi/.ssh/authorized_keys
   chmod 600 /home/pi/.ssh/authorized_keys
   ```

3. **Disable password SSH**:
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   # Set: PubkeyAuthentication yes
   sudo systemctl restart ssh
   ```

4. **Connect with key**:
   ```bash
   ssh -i ~/.ssh/beacon-display pi@<pi-ip-address>
   # No password prompt
   ```

**Key Management**:
- ✅ Private key stored in `~/.ssh/` with 600 permissions
- ✅ Private key backed up in Key Vault
- ✅ Public key distributed with provisioning
- ✅ Key rotation on staff changes
- ✅ Audit logging of all SSH access

**Access Control**:
- ✅ SSH available only from Management VLAN
- ✅ Firewall restricts SSH to authorized hosts
- ✅ Bastion host for external access (if needed)
- ✅ Session recording for compliance

---

## 🚨 Vulnerability Reporting

### Responsible Disclosure

If you discover a security vulnerability in BEACON, please follow responsible disclosure practices:

**DO NOT**:
- ❌ Open a public GitHub issue
- ❌ Post on social media or forums
- ❌ Share with unauthorized parties
- ❌ Exploit the vulnerability

**DO**:
- ✅ Report privately to maintainers
- ✅ Allow reasonable time for patches
- ✅ Follow coordinated disclosure timeline

### Reporting Process

**Via Email** (Recommended):

Send security reports to:
```
security@beacon-display.example.com
(To be replaced with actual email - currently maintainer email)
```

**Include in Report**:
1. **Vulnerability type**: (e.g., credential exposure, injection, etc.)
2. **Affected component**: (token service, display client, pi setup, etc.)
3. **Severity**: (critical, high, medium, low)
4. **Proof of concept**: (detailed steps to reproduce)
5. **Recommended fix**: (if you have one)
6. **Timeline expectations**: (when you'd expect public disclosure)

**Response Timeline**:
- **24 hours**: Acknowledgment of report
- **48 hours**: Initial assessment and impact analysis
- **7 days**: Proposed timeline for patch
- **14 days**: Security patch released (most cases)
- **30 days**: Public disclosure (coordinated)

### Vulnerability Disclosure

Once patched and released:
1. ✅ Vulnerability disclosed in release notes
2. ✅ Upgrade path documented
3. ✅ Credit given to reporter (if desired)
4. ✅ Patch available across all deployment modes

---

## 📦 Dependency Security

### Dependency Management

**Token Service Dependencies** (`token-service/laptop-version/package.json`):

| Package | Version | Purpose | Security Notes |
|---------|---------|---------|-----------------|
| `express` | 4.18.2 | Web framework | Monitor for updates |
| `@azure/msal-node` | 2.6.0 | Azure authentication | Critical - official Microsoft |
| `dotenv` | 16.3.1 | Environment variables | No secrets in code |
| `cors` | 2.8.5 | Cross-origin requests | Restrict to Pi origins |

### Security Audit

**Running Dependency Audit**:

```bash
cd token-service/laptop-version

# Check for known vulnerabilities
npm audit

# Show detailed information
npm audit --detail

# Fix automatically (if safe)
npm audit fix

# Fix with review
npm audit fix --dry-run  # Review first
npm audit fix            # Then apply
```

**GitHub Dependabot**:
- ✅ Automated security alerts enabled
- ✅ Automatic PRs for security updates
- ✅ Quarterly dependency reviews
- ✅ No unnecessary dependency additions

### Supply Chain Security

**Practices**:
1. ✅ Minimize external dependencies
2. ✅ Use well-maintained packages only
3. ✅ Review updates before merging
4. ✅ Lock dependency versions in `package-lock.json`
5. ✅ No dependencies with hardcoded secrets
6. ✅ Regular vulnerability scanning

---

## ✅ Security Checklist

### For Contributors

Before submitting code or PRs:

**Code Security**:
- [ ] No hardcoded secrets (API keys, tokens, passwords)
- [ ] No `.env` or `config.json` files committed
- [ ] Configuration uses environment variables
- [ ] Example files provided (`.env.example`, `config.json.example`)
- [ ] No command injection vulnerabilities
- [ ] No SQL injection vulnerabilities
- [ ] No XSS (cross-site scripting) vulnerabilities
- [ ] Proper error handling (no sensitive info in errors)

**Configuration Security**:
- [ ] POC approach documented
- [ ] Production requirements documented
- [ ] Security implications noted in comments
- [ ] Access control properly implemented
- [ ] Least privilege principle followed

**Dependency Security**:
- [ ] No unnecessary dependencies added
- [ ] Dependencies from official sources
- [ ] Known vulnerabilities checked (`npm audit`)
- [ ] Dependencies documented in PR

### For Maintainers

**Release Security**:
- [ ] All tests pass
- [ ] No new security warnings
- [ ] Dependencies up to date
- [ ] Security documentation updated
- [ ] Changelog documents security fixes
- [ ] Release notes include security notes

**Ongoing Security**:
- [ ] Monthly dependency audit
- [ ] Quarterly security review
- [ ] Annual secret rotation
- [ ] Regular penetration testing (production)
- [ ] Vulnerability log maintained
- [ ] Security policy updated as needed

### For Deployers

**POC Deployment**:
- [ ] `.env` file NOT committed
- [ ] `.env` file NOT shared via unencrypted channels
- [ ] Laptop restricted to trusted network
- [ ] WiFi encrypted (WPA2+)
- [ ] SSH credentials protected
- [ ] Regular backups maintained

**Production Deployment**:
- [ ] Azure Key Vault configured
- [ ] Secret rotation scheduled (12 months)
- [ ] IoT VLAN segmented
- [ ] Firewall rules implemented
- [ ] 802.1X authentication enabled
- [ ] SSH key-based (passwords disabled)
- [ ] Audit logging enabled
- [ ] Monitoring/alerting configured
- [ ] Security review completed
- [ ] Incident response plan documented

---

## 📚 Related Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Security model overview
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production security requirements
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Security guidelines for contributors
- **[GETTING-STARTED.md](GETTING-STARTED.md)** - POC setup and secret handling

---

## 🔄 Updates & Maintenance

**Last Updated**: 2025-11-14

**Security Model Version**: 1.0

**Next Review**: 2026-11-14 (annual)

---

## ❓ Questions?

If you have security questions or concerns:

1. **Check this document** - Most questions covered above
2. **Review ARCHITECTURE.md** - Security model details
3. **Check DEPLOYMENT.md** - Production requirements
4. **Open GitHub Discussion** - Non-sensitive questions
5. **Email maintainers** - Sensitive security concerns (privately)

---

**Remember**: Security is everyone's responsibility. If you see something, say something. Report vulnerabilities privately and responsibly.
