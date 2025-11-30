# BEACON Authentication

**Audience:** For developers implementing authentication or troubleshooting auth issues

This document describes Azure AD integration, MSAL implementation, and token management.

---

## Authentication Flow

```
1. Display boots → loads index.html
   │
2. Requests embed token from token service
   │
3. Token service authenticates to Azure AD
   │  (using CLIENT_ID + CLIENT_SECRET)
   │
4. Azure AD returns access token
   │
5. Token service requests embed token from Power BI
   │  (for specific workspace + report)
   │
6. Power BI returns embed token (valid 1 hour)
   │
7. Display receives embed token
   │
8. Power BI report renders
   │
9. Auto-refresh:
   ├─ Every 50 min: Request new embed token
   └─ Every 60 sec: Refresh report data
```

---

## Security Model

### Service Principal Authentication

BEACON uses **service principal** (application identity) rather than user authentication:

**Benefits:**
- No user interaction required
- Programmatic access
- Workspace-scoped permissions
- Suitable for unattended displays

**Requirements:**
- Azure AD app registration
- Client secret (12-month validity)
- Service principal added to Power BI workspace
- Report.Read.All permission

### Why Not User Authentication?

User-based authentication would require:
- Interactive login on each display
- Multi-factor authentication
- Session management
- User licenses for each display

Service principal avoids these complexities and costs.

---

## Azure AD Setup

### 1. Create App Registration

**Azure Portal → Azure Active Directory → App registrations → New registration**

**Settings:**
- Name: `BEACON-Display-POC` (or your preferred name)
- Supported account types: Single tenant
- Redirect URI: Not needed for service principal

**Record these values:**
- Application (client) ID → `CLIENT_ID`
- Directory (tenant) ID → `TENANT_ID`

### 2. Create Client Secret

**App registration → Certificates & secrets → New client secret**

**Settings:**
- Description: `BEACON Token Service`
- Expires: 12 months (recommended) or 24 months

**Record this value:**
- Secret value → `CLIENT_SECRET`

⚠️ **Important:** Copy the secret immediately - you cannot view it again after leaving the page.

⚠️ **Security:** Never commit this secret to version control. Store in `.env` file (POC) or Azure Key Vault (production).

### 3. Configure API Permissions

**App registration → API permissions → Add a permission**

**Select:**
- APIs my organization uses → `Power BI Service`
- Application permissions → `Report.Read.All`

**Grant admin consent:**
- Click "Grant admin consent for [Your Organization]"
- Confirm

**Why Report.Read.All:**
- Read-only access (security best practice)
- Workspace-scoped via role assignment
- No write permissions (prevents accidental changes)

### 4. Add Service Principal to Workspace

**Power BI Service (app.powerbi.com) → Workspace → Access**

**Steps:**
1. Open target workspace
2. Click "..." menu → Workspace access
3. Search for your app name (`BEACON-Display-POC`)
4. Add with **Member** role

**Role Requirements:**
- **Member**: Required for embed token generation
- **Viewer**: Insufficient (cannot generate tokens)
- **Admin**: Not needed (excessive permissions)

---

## MSAL Implementation

### Microsoft Authentication Library (MSAL)

BEACON uses `@azure/msal-node` for server-side Azure AD authentication.

**Package:**
```json
{
  "@azure/msal-node": "2.6.0"
}
```

### Configuration

**token-service/laptop-version/server.js:**

```javascript
const msal = require('@azure/msal-node');

const msalConfig = {
    auth: {
        clientId: process.env.CLIENT_ID,
        authority: `https://login.microsoftonline.com/${process.env.TENANT_ID}`,
        clientSecret: process.env.CLIENT_SECRET
    }
};

const cca = new msal.ConfidentialClientApplication(msalConfig);
```

**Configuration Fields:**
- `clientId`: Application (client) ID from app registration
- `authority`: Azure AD tenant-specific endpoint
- `clientSecret`: Secret value from app registration

### Token Acquisition

**Client Credentials Flow:**

```javascript
async function getAccessToken() {
    const tokenRequest = {
        scopes: ['https://analysis.windows.net/powerbi/api/.default']
    };

    try {
        const response = await cca.acquireTokenByClientCredential(tokenRequest);
        return response.accessToken;
    } catch (error) {
        console.error('Failed to acquire access token:', error);
        throw error;
    }
}
```

**Scope:**
- `https://analysis.windows.net/powerbi/api/.default`: Power BI service scope
- `.default`: Requests all permissions granted to the app

### Embed Token Generation

**After acquiring access token:**

```javascript
async function generateEmbedToken(groupId, reportId) {
    // 1. Get access token from Azure AD
    const accessToken = await getAccessToken();

    // 2. Request embed token from Power BI API
    const embedTokenUrl = `https://api.powerbi.com/v1.0/myorg/groups/${groupId}/reports/${reportId}/GenerateToken`;

    const response = await fetch(embedTokenUrl, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            accessLevel: 'View'
        })
    });

    const embedToken = await response.json();
    return embedToken;
}
```

**Embed Token Properties:**
- `token`: Token string for Power BI embed
- `expiration`: Token expiry time (1 hour from generation)
- `tokenId`: Unique identifier for the token

---

## Token Lifecycle

### Access Token (Azure AD)

**Purpose:** Authenticates token service to Power BI API

**Characteristics:**
- Issued by: Azure AD
- Audience: Power BI API
- Lifetime: 1 hour (default)
- Scope: Power BI service
- Renewal: Automatic (MSAL caches and refreshes)

**Usage:**
- Bearer token in Power BI API requests
- Not exposed to display client
- Used server-side only

### Embed Token (Power BI)

**Purpose:** Authorizes display client to view specific report

**Characteristics:**
- Issued by: Power BI API
- Audience: Power BI embed SDK
- Lifetime: 1 hour
- Scope: Specific workspace + report
- Renewal: Manual (display client requests new token)

**Usage:**
- Passed to display client
- Used by Power BI JavaScript library
- Report-specific (not workspace-wide)

### Token Refresh Strategy

**Display Client Logic (powerbi-embed.js):**

```javascript
// Refresh embed token at 50 minutes (before 60-minute expiry)
const TOKEN_REFRESH_INTERVAL = 50 * 60 * 1000; // 50 minutes in milliseconds

setInterval(async () => {
    try {
        const newToken = await fetchEmbedToken();
        await report.setAccessToken(newToken);
        console.log('Token refreshed successfully');
    } catch (error) {
        console.error('Token refresh failed:', error);
    }
}, TOKEN_REFRESH_INTERVAL);
```

**Why 50 minutes?**
- Tokens expire at 60 minutes
- 10-minute buffer for network delays
- Prevents authentication failures during refresh

**Data Refresh:**

```javascript
// Refresh report data every 60 seconds
const DATA_REFRESH_INTERVAL = 60 * 1000; // 60 seconds in milliseconds

setInterval(async () => {
    try {
        await report.refresh();
        console.log('Data refreshed successfully');
    } catch (error) {
        console.error('Data refresh failed:', error);
    }
}, DATA_REFRESH_INTERVAL);
```

---

## Network Requirements

### Display Client (Raspberry Pi) Must Access:

**Azure AD:**
- `login.microsoftonline.com:443` - Authentication endpoint
- HTTPS required

**Power BI API:**
- `api.powerbi.com:443` - Embed token requests (via token service)
- HTTPS required

**Power BI Content:**
- `app.powerbi.com:443` - Report content and data
- HTTPS required

**CDN:**
- `cdn.jsdelivr.net:443` - Power BI JavaScript library
- HTTPS required

**Token Service:**
- POC: `http://YOUR-LAPTOP-IP:3000` - HTTP acceptable for local network
- Production: `https://YOUR-COMPANY-DOMAIN` - HTTPS required

### Corporate Firewall Rules

**Required outbound access (production):**

```
Destination: login.microsoftonline.com
Protocol: HTTPS (443)
Purpose: Azure AD authentication

Destination: api.powerbi.com
Protocol: HTTPS (443)
Purpose: Power BI API requests

Destination: app.powerbi.com
Protocol: HTTPS (443)
Purpose: Power BI report content

Destination: cdn.jsdelivr.net
Protocol: HTTPS (443)
Purpose: Power BI JavaScript library

Destination: [Your token service]
Protocol: HTTPS (443)
Purpose: Embed token generation
```

---

## Error Handling

### Common Authentication Errors

#### 1. Invalid Client Secret

**Error:** `AADSTS7000215: Invalid client secret is provided`

**Cause:**
- Wrong CLIENT_SECRET in .env
- Secret expired (12-month validity)
- Typo when copying secret

**Solution:**
1. Azure Portal → App registration → Certificates & secrets
2. Check expiration date
3. Create new secret if expired
4. Update .env with new secret
5. Restart token service

#### 2. Unauthorized

**Error:** `AADSTS50034: The user account does not exist in tenant`

**Cause:**
- Wrong TENANT_ID in .env
- App not registered in correct tenant

**Solution:**
1. Verify TENANT_ID matches your Azure AD tenant
2. Check app registration is in correct directory

#### 3. Insufficient Privileges

**Error:** `This request is not authorized to perform this operation`

**Cause:**
- Service principal not added to Power BI workspace
- Insufficient workspace role (needs Member, not Viewer)
- Report.Read.All permission not granted

**Solution:**
1. Verify service principal in workspace with Member role
2. Check API permissions include Report.Read.All
3. Ensure admin consent granted

#### 4. Token Expired

**Error:** `The provided access token has expired`

**Cause:**
- Embed token not refreshed (>1 hour old)
- Network issue preventing refresh

**Solution:**
- Check tokenRefreshMinutes in config.json is <60
- Verify token service is reachable
- Check browser console for refresh errors

---

## Security Best Practices

### POC (Acceptable)

✅ **HTTP for token service** (local network only)
✅ **Secrets in .env file** (never committed)
✅ **No token caching** (generate fresh each request)
✅ **Basic error logging**

### Production (Required)

✅ **HTTPS for token service** (valid SSL certificate)
✅ **Secrets in Azure Key Vault** (not in environment variables)
✅ **Token caching** (reduce API calls, respect rate limits)
✅ **Comprehensive logging** (audit trail)
✅ **Network segmentation** (IoT VLAN)
✅ **Secret rotation** (automated, before expiry)
✅ **API rate limiting** (prevent abuse)
✅ **Monitoring and alerts** (failed auth attempts)

### Secret Management

**POC (.env file):**
```bash
# token-service/laptop-version/.env
TENANT_ID=your-tenant-id
CLIENT_ID=your-client-id
CLIENT_SECRET=your-client-secret  # 12-month expiry
```

**Production (Azure Key Vault):**
```javascript
const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

const credential = new DefaultAzureCredential();
const client = new SecretClient('https://your-vault.vault.azure.net', credential);

async function getSecret(secretName) {
    const secret = await client.getSecret(secretName);
    return secret.value;
}

const clientSecret = await getSecret('BEACON-CLIENT-SECRET');
```

**Benefits of Key Vault:**
- Centralized secret management
- Automated rotation
- Access auditing
- Managed identity integration
- Secret versioning

---

## Testing Authentication

### Test Token Service Locally

```bash
# 1. Check service is running
curl http://localhost:3000/health

# Expected: {"status":"healthy"}
```

```bash
# 2. Test embed token generation
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{
    "groupId":"YOUR-WORKSPACE-ID",
    "reportId":"YOUR-REPORT-ID"
  }'

# Expected: {"token":"...","expiration":"...","reportId":"..."}
```

### Test from Raspberry Pi

```bash
# From Pi, test token service reachability
curl http://YOUR-LAPTOP-IP:3000/health

# Test embed token generation
curl -X POST http://YOUR-LAPTOP-IP:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{
    "groupId":"YOUR-WORKSPACE-ID",
    "reportId":"YOUR-REPORT-ID"
  }'
```

### Validate Token Response

**Expected fields:**
- `token`: Long string (JWT format)
- `expiration`: ISO 8601 timestamp (1 hour from now)
- `tokenId`: GUID
- `reportId`: Matches request

**Example:**
```json
{
  "token": "H4sIAAAAAAAE...",
  "expiration": "2025-11-30T13:00:00Z",
  "tokenId": "12345678-1234-1234-1234-123456789abc",
  "reportId": "your-report-id"
}
```

---

## Related Documentation

- **[Architecture Overview](README.md)** - System design
- **[Components](components.md)** - Token service implementation
- **[Security Model](security-model.md)** - Security requirements
- **[Data Flow](data-flow.md)** - Request flow
- **[Troubleshooting Authentication](../troubleshooting/token-service.md)** - Auth error resolution

---

**Last Updated:** 2025-11-30
