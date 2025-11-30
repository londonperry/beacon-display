# BEACON Security Model

**Audience:** For security reviewers, IT teams, and production deployment

This document describes security requirements, threat models, and hardening steps for POC and production environments.

---

## Security Philosophy

BEACON uses **defense in depth** with different security requirements based on deployment phase:

- **POC:** Relaxed security for rapid development (local network only)
- **Production:** Hardened security for enterprise deployment

---

## POC vs Production Security

### POC Security (Acceptable for Development)

**Context:** Local network, development/testing only

✅ **Acceptable:**
- HTTP for token service (local network)
- Secrets in .env file (never committed to git)
- Password-based SSH
- Home WiFi with WPA2
- No network segmentation
- Basic error logging

⚠️ **Risks:**
- Secrets visible in process list
- Unencrypted traffic on local network
- No audit trail
- Limited monitoring

🎯 **Use Case:** Personal testing, proof-of-concept, 1-5 devices on home network

### Production Security (Required for Enterprise)

**Context:** Corporate network, multiple devices, business-critical data

✅ **Required:**
- HTTPS for token service (valid SSL certificate)
- Secrets in Azure Key Vault or secure environment
- Key-based SSH only (no passwords)
- Network segmentation (IoT VLAN)
- 802.1X authentication (optional but recommended)
- Firewall rules and access control
- Comprehensive logging and monitoring
- Incident response plan
- Regular security audits

🎯 **Use Case:** Corporate deployment, 10+ devices, customer-facing data

---

## Threat Model

### Assets to Protect

1. **Azure Client Secret** - Grants access to Power BI workspace
2. **Power BI Data** - Business intelligence and sensitive metrics
3. **Network Access** - Corporate network connectivity
4. **Device Access** - Physical and remote access to Raspberry Pi
5. **Token Service** - Authentication infrastructure

### Threat Scenarios

#### 1. Secret Exposure

**Threat:** Attacker gains access to CLIENT_SECRET

**Attack Vectors:**
- Committed to git repository
- Exposed in logs or error messages
- Stolen from compromised laptop
- Intercepted over unencrypted network

**Impact:**
- Read access to all reports in workspace
- Potential data exfiltration
- Unauthorized embed token generation

**Mitigations:**
- Never commit .env files (POC)
- Use Key Vault for production
- Rotate secrets regularly (12-month max)
- Monitor token generation logs
- Implement rate limiting

#### 2. Network Eavesdropping

**Threat:** Attacker intercepts network traffic

**Attack Vectors:**
- Man-in-the-middle on WiFi
- Unencrypted HTTP traffic
- Compromised network device

**Impact:**
- Embed token theft (1-hour validity)
- Viewing transmitted data
- Session hijacking

**Mitigations:**
- HTTPS for production token service
- WPA2/WPA3 WiFi encryption
- Network segmentation (IoT VLAN)
- 802.1X authentication (production)

#### 3. Unauthorized Physical Access

**Threat:** Attacker gains physical access to Raspberry Pi

**Attack Vectors:**
- Unattended device in public area
- SD card removed and cloned
- USB keyboard connected
- HDMI debugging

**Impact:**
- Config.json theft (workspace/report IDs)
- Device repurposing
- Network access from device

**Mitigations:**
- Secure physical location
- Locked cases or enclosures
- Disable USB ports in firmware
- Encrypted file system (optional)
- No sensitive data on device (IDs are not secrets)

#### 4. Token Service Compromise

**Threat:** Attacker compromises token service

**Attack Vectors:**
- Vulnerable dependencies
- Unpatched OS/software
- Weak access controls
- DDoS attack

**Impact:**
- Service disruption (displays stop working)
- Secret exposure if stored locally
- Unauthorized token generation

**Mitigations:**
- Regular dependency updates
- OS security patches
- Firewall and access control
- Rate limiting and monitoring
- Separate Key Vault access

---

## Azure AD Permissions

### Service Principal Configuration

**Required Permissions:**
- Application permission: `Report.Read.All`
- Scope: Workspace-level (not tenant-wide)
- Role: Member (in Power BI workspace)

**Why Report.Read.All:**
- Read-only access (cannot modify reports)
- Workspace-scoped via role assignment
- No user impersonation
- Auditable via Azure AD logs

**Why Not More Permissions:**
- Report.ReadWrite.All: Unnecessary (displays don't modify content)
- Workspace.ReadWrite.All: Excessive (don't need workspace management)
- Tenant.Read.All: Too broad (limit to specific workspace)

### Workspace Role Requirements

**Member Role (Required):**
- Can generate embed tokens
- Can view reports
- Cannot modify workspace settings
- Cannot delete workspace

**Viewer Role (Insufficient):**
- Can view reports
- Cannot generate embed tokens ❌

**Admin Role (Not Recommended):**
- Full workspace control
- Excessive permissions for display-only use case

---

## Network Security

### POC Network Configuration

```
Home Router (192.168.1.1)
├─ Laptop (192.168.1.100) - Token Service
└─ Raspberry Pi (192.168.1.150) - Display
```

**Security Measures:**
- WPA2/WPA3 WiFi encryption
- Strong WiFi password
- Laptop firewall allows port 3000
- No port forwarding to internet

**Acceptable Risks:**
- HTTP traffic visible on local network
- Shared network with personal devices

### Production Network Configuration

```
Corporate Network
│
├─ DMZ / Application Subnet
│  └─ Token Service (HTTPS, internal domain)
│
└─ IoT VLAN (Segmented)
   ├─ Display Pi 001 (10.100.1.11)
   ├─ Display Pi 002 (10.100.1.12)
   └─ Display Pi 003 (10.100.1.13)
```

**Security Measures:**
- **Network Segmentation:** IoT VLAN isolated from corporate network
- **Firewall Rules:** Only required outbound traffic allowed
- **802.1X Authentication:** Device certificates for network access
- **HTTPS:** Token service behind reverse proxy with SSL
- **Internal DNS:** Token service not exposed to internet
- **Access Control:** SSH from management subnet only

### Required Firewall Rules (Production)

**Outbound from IoT VLAN:**

```
# Azure AD Authentication
Allow: 10.100.1.0/24 → login.microsoftonline.com:443 (HTTPS)

# Power BI API
Allow: 10.100.1.0/24 → api.powerbi.com:443 (HTTPS)

# Power BI Content
Allow: 10.100.1.0/24 → app.powerbi.com:443 (HTTPS)

# CDN (Power BI Library)
Allow: 10.100.1.0/24 → cdn.jsdelivr.net:443 (HTTPS)

# Internal Token Service
Allow: 10.100.1.0/24 → tokenservice.internal.company.com:443 (HTTPS)

# DNS
Allow: 10.100.1.0/24 → DNS-Server:53 (UDP)

# NTP (Time Sync)
Allow: 10.100.1.0/24 → NTP-Server:123 (UDP)

# Deny all other outbound traffic
Deny: 10.100.1.0/24 → 0.0.0.0/0:* (ALL)
```

**Inbound to IoT VLAN:**

```
# SSH from Management Subnet Only
Allow: 10.200.1.0/24 → 10.100.1.0/24:22 (SSH, key-based only)

# Deny all other inbound traffic
Deny: 0.0.0.0/0 → 10.100.1.0/24:* (ALL)
```

---

## Secret Management

### POC: .env File

**Location:** `token-service/laptop-version/.env`

**Content:**
```bash
TENANT_ID=12345678-1234-1234-1234-123456789abc
CLIENT_ID=87654321-4321-4321-4321-cba987654321
CLIENT_SECRET=your_secret_value_here
PORT=3000
NODE_ENV=development
```

**Security Measures:**
- Listed in .gitignore (never committed)
- File permissions: 600 (owner read/write only)
- Located on encrypted laptop drive
- Regular secret rotation (12 months max)

**Risks:**
- Visible in process list (`ps aux | grep node`)
- Accessible if laptop compromised
- Manual rotation required

### Production: Azure Key Vault

**Configuration:**
```javascript
const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

const credential = new DefaultAzureCredential();
const vaultUrl = 'https://beacon-keyvault.vault.azure.net';
const client = new SecretClient(vaultUrl, credential);

// Fetch secrets at startup
async function loadSecrets() {
    const tenantId = await client.getSecret('BEACON-TENANT-ID');
    const clientId = await client.getSecret('BEACON-CLIENT-ID');
    const clientSecret = await client.getSecret('BEACON-CLIENT-SECRET');

    return {
        TENANT_ID: tenantId.value,
        CLIENT_ID: clientId.value,
        CLIENT_SECRET: clientSecret.value
    };
}
```

**Security Benefits:**
- Centralized secret management
- Access auditing (who accessed which secret)
- Automated rotation
- Secret versioning
- Managed identity integration (no hardcoded credentials)
- Network access control
- Soft-delete and purge protection

**Access Control:**
- Token service uses Managed Identity
- Key Vault access policy: Get + List secrets only
- No human access to secrets in production

---

## SSH Security

### POC: Password Authentication

**Acceptable for development:**
```bash
# SSH with password
ssh pi@192.168.1.150
# Enter password: raspberry (change default!)
```

**Basic hardening:**
- Change default password
- Disable root login
- Use non-default username

### Production: Key-Based Authentication

**Required for production:**

1. **Generate SSH key pair:**
```bash
ssh-keygen -t ed25519 -C "beacon-management"
```

2. **Deploy public key to Pi:**
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub pi@10.100.1.11
```

3. **Disable password authentication:**
```bash
# On Pi: /etc/ssh/sshd_config
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

4. **Restart SSH service:**
```bash
sudo systemctl restart ssh
```

**Additional hardening:**
- Change default SSH port (security through obscurity)
- Install fail2ban (ban after failed attempts)
- Use certificate-based authentication (advanced)
- Restrict SSH access to management subnet only

---

## Logging and Monitoring

### POC Logging

**Token Service:**
- Console output (stdout/stderr)
- Basic request logging
- Error messages

**Display Client:**
- Browser console (requires F12 on Pi)
- systemd journal (`journalctl -u beacon-display`)

### Production Logging

**Token Service:**
- Centralized log aggregation (Azure Log Analytics, Splunk, ELK)
- Structured JSON logs
- Log levels: DEBUG, INFO, WARN, ERROR
- Audit trail: Who requested tokens, when, for which reports

**Display Client:**
- Remote syslog forwarding
- Health metrics (memory, CPU, temperature)
- Error tracking and alerting

**What to Log:**

✅ **Security Events:**
- Authentication attempts (success/failure)
- Token generation requests
- Secret access (Key Vault)
- SSH login attempts
- Service restarts

✅ **Operational Events:**
- Service startup/shutdown
- Memory threshold alerts
- Network connectivity issues
- Token refresh failures

❌ **Never Log:**
- CLIENT_SECRET values
- Embed tokens (can be used for access)
- Full stack traces with secrets

**Alert Triggers:**
- Failed authentication (>5 in 10 minutes)
- Memory >85% (automatic restart)
- Service down >5 minutes
- Unusual token request patterns

---

## Compliance and Auditing

### Data Residency

**Power BI Data:**
- Stored in Microsoft Azure (region-specific)
- Check Power BI tenant region
- May require data residency compliance

**BEACON Data:**
- No local data storage on Pi
- Config.json contains IDs (not sensitive)
- Logs may contain business context

### GDPR Considerations

**Personal Data:**
- Power BI reports may contain personal data
- Displays should be in secure locations
- Screen privacy for sensitive information

**Data Processing:**
- Service principal acts as data processor
- Audit logs record access

### SOC 2 / ISO 27001

**For production deployments:**
- Document architecture and data flows
- Implement access controls
- Enable audit logging
- Regular vulnerability assessments
- Incident response procedures
- Change management process

---

## Secret Rotation

### Client Secret Rotation (12-Month Expiry)

**Process:**

1. **Create new secret** (Azure Portal):
   - App registration → Certificates & secrets
   - New client secret (12-month expiry)
   - Record new secret value

2. **Update configuration:**
   - POC: Update .env file, restart token service
   - Production: Update Key Vault secret

3. **Validate:**
   - Test token generation
   - Monitor displays for errors

4. **Delete old secret** (after validation):
   - Azure Portal → Delete expired secret

**Automation (Production):**
```bash
# Azure CLI script for rotation
az keyvault secret set \
  --vault-name beacon-keyvault \
  --name BEACON-CLIENT-SECRET \
  --value $NEW_SECRET_VALUE

# Token service auto-reloads from Key Vault
```

**Monitoring:**
- Set alert 30 days before expiry
- Automated rotation via Azure Functions (advanced)

---

## Vulnerability Management

### Dependency Updates

**Token Service (Node.js):**
```bash
# Check for vulnerabilities
npm audit

# Update dependencies
npm update

# Fix vulnerabilities
npm audit fix
```

**Display Client:**
- Power BI Client from CDN (auto-updated)
- Manual updates for local JavaScript files

**Raspberry Pi OS:**
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Check for security updates
sudo apt list --upgradable
```

**Update Schedule:**
- Security patches: Within 7 days
- Dependency updates: Monthly
- OS updates: Quarterly (with testing)

### Vulnerability Scanning

**Production:**
- Regular dependency scans (npm audit, Snyk)
- OS vulnerability scanning (Nessus, OpenVAS)
- Web application scanning (token service)
- Penetration testing (annually)

---

## Incident Response

### Security Incident Scenarios

#### Scenario 1: Secret Exposure

**Detection:** CLIENT_SECRET found in public repository

**Response:**
1. Immediately rotate secret (create new, delete old)
2. Update all token services
3. Review audit logs for unauthorized access
4. Investigate how secret was exposed
5. Update security procedures

#### Scenario 2: Unauthorized Access

**Detection:** Unusual token generation patterns, failed auth attempts

**Response:**
1. Review authentication logs
2. Identify source of unauthorized requests
3. Block IP/network if malicious
4. Rotate secrets if compromised
5. Notify security team

#### Scenario 3: Device Compromise

**Detection:** Physical tampering, unauthorized SSH access

**Response:**
1. Disconnect device from network
2. Image SD card for forensics
3. Reflash device with clean OS
4. Review access logs
5. Update physical security

---

## Security Checklist

### POC Deployment

- [ ] Default Pi password changed
- [ ] .env file not committed to git
- [ ] WiFi WPA2/WPA3 encryption enabled
- [ ] Laptop firewall configured
- [ ] Token service only accessible on local network
- [ ] CLIENT_SECRET has 12-month expiry
- [ ] Service principal has Member role (not Admin)

### Production Deployment

- [ ] HTTPS for token service with valid certificate
- [ ] Secrets stored in Azure Key Vault
- [ ] Network segmentation (IoT VLAN)
- [ ] Firewall rules configured and tested
- [ ] SSH key-based authentication only
- [ ] Password authentication disabled
- [ ] fail2ban or equivalent installed
- [ ] Centralized logging configured
- [ ] Monitoring and alerting enabled
- [ ] Secret rotation process documented
- [ ] Incident response plan created
- [ ] Regular security audits scheduled
- [ ] Vulnerability scanning enabled
- [ ] Physical security measures implemented
- [ ] Compliance requirements reviewed

---

## Related Documentation

- **[Architecture Overview](README.md)** - System design
- **[Authentication](authentication.md)** - Azure AD integration
- **[Components](components.md)** - System components
- **[Data Flow](data-flow.md)** - Request flow
- **[Deployment Guide](../../DEPLOYMENT.md)** - Production deployment

---

**Last Updated:** 2025-11-30
