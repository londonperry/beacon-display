# Token Service Troubleshooting

**Audience:** For diagnosing token service and authentication issues

This document covers token service startup problems, authentication failures, token generation issues, and Azure AD problems.

---

## Service Startup Issues

### Issue: Token Service Won't Start

**Symptoms:**
- `npm start` fails
- Port already in use error
- Module not found errors
- Environment variable errors

#### Diagnosis

**Check if service is already running:**
```bash
# Check for existing process
lsof -i :3000
ps aux | grep node
```

**Check for missing dependencies:**
```bash
cd token-service/laptop-version
npm list
```

**Check environment variables:**
```bash
cat .env
# Verify all required variables present:
# TENANT_ID, CLIENT_ID, CLIENT_SECRET, PORT
```

#### Solutions

**1. Kill existing process:**
```bash
# Find process on port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or kill all node processes
pkill node
```

**2. Install dependencies:**
```bash
cd token-service/laptop-version
rm -rf node_modules package-lock.json
npm install
```

**3. Fix .env file:**
```bash
# Ensure .env exists
cp .env.example .env

# Edit with correct values
nano .env

# Verify format (no quotes, no spaces around =)
TENANT_ID=12345678-1234-1234-1234-123456789abc
CLIENT_ID=87654321-4321-4321-4321-cba987654321
CLIENT_SECRET=your_secret_value
PORT=3000
NODE_ENV=development
```

**4. Check file permissions:**
```bash
chmod 600 .env
chmod +x server.js
```

**5. Start service:**
```bash
npm start

# Or with debug output
DEBUG=* npm start
```

---

## Authentication Failures

### Issue: "Invalid Client Secret"

**Error message:** `AADSTS7000215: Invalid client secret is provided`

**Symptoms:**
- Token generation fails
- 401 Unauthorized responses
- Error in token service logs

#### Diagnosis

**1. Verify credentials:**
```bash
cd token-service/laptop-version
cat .env | grep -E "TENANT_ID|CLIENT_ID|CLIENT_SECRET"
```

**2. Check secret expiry in Azure Portal:**
- Azure Portal → Azure AD → App registrations → Your app
- Certificates & secrets → Check expiration date

**3. Test token service health:**
```bash
curl http://localhost:3000/health
# Should return: {"status":"healthy"}
```

**4. Test with verbose logging:**
```bash
# In token-service code, temporarily add:
console.log('TENANT_ID:', process.env.TENANT_ID);
console.log('CLIENT_ID:', process.env.CLIENT_ID);
console.log('CLIENT_SECRET:', process.env.CLIENT_SECRET ? '***' : 'MISSING');
```

#### Solutions

**1. Secret expired - create new secret:**
```bash
# Azure Portal steps:
# 1. Go to App registration → Certificates & secrets
# 2. Click "New client secret"
# 3. Description: "BEACON Token Service"
# 4. Expires: 12 months
# 5. Copy secret value immediately (can't view again)
```

**2. Update .env file:**
```bash
nano token-service/laptop-version/.env

# Update CLIENT_SECRET line
CLIENT_SECRET=new_secret_value_here

# Save and exit
```

**3. Restart token service:**
```bash
# Stop service (Ctrl+C if running in terminal)
# Or kill process
pkill node

# Restart
cd token-service/laptop-version
npm start
```

**4. Test token generation:**
```bash
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{
    "groupId":"YOUR-WORKSPACE-ID",
    "reportId":"YOUR-REPORT-ID"
  }'

# Should return token object
```

**5. Delete old expired secret:**
```bash
# Azure Portal → App registration → Certificates & secrets
# Delete expired secret
```

---

### Issue: "Unauthorized" / "User Does Not Exist"

**Error message:** `AADSTS50034: The user account does not exist in tenant`

**Symptoms:**
- 401 responses
- Tenant mismatch errors

#### Diagnosis

**1. Verify TENANT_ID:**
```bash
# Get from Azure Portal
# Azure AD → Overview → Tenant ID

# Compare with .env
cat token-service/laptop-version/.env | grep TENANT_ID
```

**2. Check app registration tenant:**
```bash
# Azure Portal → Azure AD → App registrations
# Verify your app is in correct directory
```

#### Solutions

**1. Correct TENANT_ID in .env:**
```bash
nano token-service/laptop-version/.env

# Update to correct tenant ID
TENANT_ID=correct-tenant-id-here

# Restart service
```

**2. Verify app is in correct Azure AD tenant:**
- Switch to correct directory in Azure Portal (top-right)
- Ensure app registration exists in that tenant

---

### Issue: "Insufficient Privileges"

**Error message:** `This request is not authorized to perform this operation`

**Symptoms:**
- Can authenticate but can't generate embed tokens
- 403 Forbidden responses from Power BI API

#### Diagnosis

**1. Check API permissions:**
```bash
# Azure Portal → App registration → API permissions
# Should have: Report.Read.All (Application permission)
# Status: Granted for [Your Organization]
```

**2. Verify service principal in workspace:**
```bash
# Power BI Service (app.powerbi.com)
# Navigate to workspace
# Click "..." → Workspace access
# Search for your app name
# Should be listed with Member role
```

**3. Check workspace type:**
```bash
# Cannot use "My Workspace"
# Must be a regular workspace (Pro or Premium)
```

#### Solutions

**1. Grant API permissions:**
```bash
# Azure Portal → App registration → API permissions
# Click "Add a permission"
# Select "Power BI Service"
# Select "Application permissions"
# Check "Report.Read.All"
# Click "Add permissions"
# Click "Grant admin consent for [Your Organization]"
```

**2. Add service principal to workspace:**
```bash
# Power BI Service (app.powerbi.com)
# Open target workspace
# Click "..." menu → Workspace access
# Add user/group → Enter app name (e.g., "BEACON-Display-POC")
# Select app from dropdown
# Set role to "Member" (not Viewer)
# Click "Add"
```

**3. Verify workspace is Pro/Premium:**
```bash
# Power BI Service → Workspace settings
# Check workspace type
# If "My Workspace", create new workspace
# Move report to new workspace
```

**4. Wait for propagation (if just added):**
```bash
# Changes may take 5-15 minutes to propagate
# Try again after waiting
```

---

## Token Generation Issues

### Issue: Token Request Times Out

**Symptoms:**
- Long delay (>30 seconds) before response
- Timeout errors
- Intermittent failures

#### Diagnosis

**1. Check network latency:**
```bash
# Test Azure AD endpoint
ping login.microsoftonline.com

# Test Power BI API
ping api.powerbi.com
```

**2. Check token service logs:**
```bash
# Look for slow requests
# Note timestamps between request and response
```

**3. Test direct Azure AD auth:**
```bash
# Use curl to test authentication speed
time curl -X POST https://login.microsoftonline.com/$TENANT_ID/oauth2/v2.0/token \
  -d "client_id=$CLIENT_ID" \
  -d "scope=https://analysis.windows.net/powerbi/api/.default" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "grant_type=client_credentials"
```

#### Solutions

**1. Check firewall/proxy:**
```bash
# Corporate networks may block or slow requests
# Check with IT team
# May need proxy configuration
```

**2. Increase timeout in token service:**
```javascript
// In server.js, add timeout to fetch calls
const response = await fetch(url, {
    method: 'POST',
    headers: headers,
    body: body,
    timeout: 30000  // 30 seconds
});
```

**3. Implement retry logic:**
```javascript
async function fetchWithRetry(url, options, retries = 3) {
    for (let i = 0; i < retries; i++) {
        try {
            const response = await fetch(url, options);
            if (response.ok) return response;
        } catch (error) {
            if (i === retries - 1) throw error;
            await new Promise(r => setTimeout(r, 1000 * (i + 1)));
        }
    }
}
```

---

### Issue: "Report Not Found"

**Error message:** `Report with ID 'xxx' not found`

**Symptoms:**
- Valid authentication but can't access report
- 404 Not Found from Power BI API

#### Diagnosis

**1. Verify report ID:**
```bash
# Get from Power BI report URL:
# app.powerbi.com/groups/{GROUP-ID}/reports/{REPORT-ID}/...

# Compare with config.json
cat ~/beacon-display/display-client/config.json | grep reportId
```

**2. Verify workspace ID:**
```bash
# Get from Power BI workspace URL:
# app.powerbi.com/groups/{THIS-IS-GROUP-ID}/...

# Compare with config.json
cat ~/beacon-display/display-client/config.json | grep groupId
```

**3. Check service principal access:**
```bash
# Power BI Service → Workspace → Workspace access
# Verify service principal is listed
# Verify it has Member role
```

#### Solutions

**1. Correct report ID:**
```bash
# Update config.json with correct IDs
nano ~/beacon-display/display-client/config.json

{
  "groupId": "CORRECT-WORKSPACE-GUID",
  "reportId": "CORRECT-REPORT-GUID"
}
```

**2. Move report to workspace:**
```bash
# If report is in "My Workspace"
# File → Save a copy
# Choose target workspace
# Save
# Update config.json with new IDs
```

**3. Re-add service principal:**
```bash
# Remove and re-add service principal to workspace
# Sometimes fixes permission issues
```

---

## Azure Problems

### Issue: Rate Limiting

**Error message:** `Too many requests`

**Symptoms:**
- 429 status codes
- Temporary failures
- "Retry after X seconds" messages

#### Diagnosis

**1. Check request frequency:**
```bash
# Count token requests per hour
# Should be ~2 per hour (50-minute refresh)

# If much higher, investigate why
```

**2. Review logs for request patterns:**
```bash
# Look for rapid successive requests
# May indicate display clients in refresh loop
```

#### Solutions

**1. Implement rate limiting:**
```javascript
// In token service
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 10, // Max 10 requests per hour per IP
    message: 'Too many requests, please try again later'
});

app.use('/api/embed-token', limiter);
```

**2. Implement caching (careful with security):**
```javascript
// Cache tokens for 45 minutes (never >60)
// Only in production, with proper security
const cache = new Map();

function getCachedToken(groupId, reportId) {
    const key = `${groupId}:${reportId}`;
    const cached = cache.get(key);

    if (cached && cached.expiry > Date.now()) {
        return cached.token;
    }
    return null;
}
```

**3. Increase tokenRefreshMinutes:**
```json
{
  "tokenRefreshMinutes": 55
}
```

**4. Contact Microsoft support:**
- If legitimate high usage
- May be able to increase limits

---

### Issue: Multi-Factor Authentication (MFA) Required

**Error:** Service principal cannot complete MFA

**Symptoms:**
- MFA prompt appears
- Authentication fails silently

#### Solution

**Service principals don't support MFA:**
- Ensure using service principal (app), not user account
- Service principal authentication is app-only
- No MFA required for client credentials flow

**If user auth is accidentally configured:**
```bash
# Switch to client credentials flow
# Update MSAL config in server.js:
const cca = new msal.ConfidentialClientApplication({
    auth: {
        clientId: process.env.CLIENT_ID,
        authority: `https://login.microsoftonline.com/${process.env.TENANT_ID}`,
        clientSecret: process.env.CLIENT_SECRET  // Key: using secret, not user flow
    }
});

// Use acquireTokenByClientCredential (not acquireTokenByCode)
```

---

## Service Management

### Check Service Status

```bash
# Health check
curl http://localhost:3000/health

# Detailed test
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{
    "groupId":"TEST-GROUP-ID",
    "reportId":"TEST-REPORT-ID"
  }'
```

### Restart Service

```bash
# If running in terminal: Ctrl+C

# If running as background process:
pkill node
cd token-service/laptop-version
npm start

# Or with logging:
npm start > /tmp/token-service.log 2>&1 &
```

### View Logs

```bash
# If running in terminal: logs appear in console

# If running in background:
tail -f /tmp/token-service.log

# If running as systemd service (production):
sudo journalctl -u beacon-token-service -f
```

---

## Related Documentation

- **[Troubleshooting Overview](README.md)** - Diagnostic approach
- **[Authentication Details](../architecture/authentication.md)** - Auth implementation
- **[Security Model](../architecture/security-model.md)** - Security requirements
- **[Display Client Issues](display-client.md)** - Client-side problems
- **[Network Issues](network.md)** - Connectivity problems

---

**Last Updated:** 2025-11-30
