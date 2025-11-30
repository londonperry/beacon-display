# BEACON Data Flow

**Audience:** For developers understanding request flow and debugging issues

This document describes request flows, token lifecycle, and refresh cycles.

---

## Request Flow Overview

```
Display Client (Pi) → Token Service → Azure AD → Power BI API → Power BI Content
     ↑                      ↓             ↓           ↓              ↓
     └──────────────────────┴─────────────┴───────────┴──────────────┘
                     (Embed Token with 1-hour validity)
```

---

## Initial Load Sequence

### Step-by-Step Flow

**1. Display Client Boots**
```
Raspberry Pi powered on
    ↓
Systemd starts beacon-display.service
    ↓
start-display.sh launches X server and Chromium
    ↓
Chromium loads display-client/index.html in kiosk mode
```

**2. JavaScript Initialization**
```javascript
// config-loader.js loads configuration
const config = await loadConfig('config.json');

// Extract required values
const {
    deviceId,
    tokenServiceUrl,
    groupId,
    reportId,
    refreshIntervalSeconds,
    tokenRefreshMinutes,
    filters
} = config;
```

**3. Token Request**
```javascript
// powerbi-embed.js requests embed token
const response = await fetch(tokenServiceUrl, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        groupId: groupId,
        reportId: reportId
    })
});

const tokenData = await response.json();
// tokenData = { token: "...", expiration: "...", reportId: "..." }
```

**HTTP Request:**
```
POST http://192.168.1.100:3000/api/embed-token
Content-Type: application/json

{
  "groupId": "12345678-1234-1234-1234-123456789abc",
  "reportId": "87654321-4321-4321-4321-cba987654321"
}
```

**4. Token Service Processes Request**
```javascript
// server.js receives request
app.post('/api/embed-token', async (req, res) => {
    const { groupId, reportId } = req.body;

    // Step 4a: Authenticate to Azure AD
    const accessToken = await getAccessToken();

    // Step 4b: Request embed token from Power BI API
    const embedToken = await generateEmbedToken(groupId, reportId, accessToken);

    // Step 4c: Return embed token to display client
    res.json(embedToken);
});
```

**5. Azure AD Authentication**
```javascript
async function getAccessToken() {
    const tokenRequest = {
        scopes: ['https://analysis.windows.net/powerbi/api/.default']
    };

    const response = await cca.acquireTokenByClientCredential(tokenRequest);
    return response.accessToken;
}
```

**Azure AD Request:**
```
POST https://login.microsoftonline.com/{TENANT_ID}/oauth2/v2.0/token
Content-Type: application/x-www-form-urlencoded

client_id={CLIENT_ID}
&scope=https://analysis.windows.net/powerbi/api/.default
&client_secret={CLIENT_SECRET}
&grant_type=client_credentials
```

**Azure AD Response:**
```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**6. Power BI Embed Token Request**
```javascript
async function generateEmbedToken(groupId, reportId, accessToken) {
    const url = `https://api.powerbi.com/v1.0/myorg/groups/${groupId}/reports/${reportId}/GenerateToken`;

    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            accessLevel: 'View'
        })
    });

    return await response.json();
}
```

**Power BI API Request:**
```
POST https://api.powerbi.com/v1.0/myorg/groups/{groupId}/reports/{reportId}/GenerateToken
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "accessLevel": "View"
}
```

**Power BI API Response:**
```json
{
  "token": "H4sIAAAAAAAE...",
  "tokenId": "12345678-1234-1234-1234-123456789abc",
  "expiration": "2025-11-30T13:00:00Z"
}
```

**7. Display Client Embeds Report**
```javascript
// powerbi-embed.js embeds report with token
const embedConfig = {
    type: 'report',
    tokenType: models.TokenType.Embed,
    accessToken: tokenData.token,
    embedUrl: `https://app.powerbi.com/reportEmbed?reportId=${reportId}&groupId=${groupId}`,
    id: reportId,
    settings: {
        panes: {
            filters: { expanded: false, visible: false },
            pageNavigation: { visible: false }
        },
        background: models.BackgroundType.Transparent
    }
};

const report = await powerbi.embed(embedContainer, embedConfig);
```

**8. Power BI Content Loads**
```
Display client requests report content from app.powerbi.com
    ↓
Power BI validates embed token
    ↓
Report data and visuals rendered in iframe
    ↓
User sees dashboard on screen
```

**Total time:** ~90-105 seconds from power-on to fully rendered

---

## Token Lifecycle

### Access Token (Azure AD → Token Service)

**Purpose:** Authenticates token service to Power BI API

**Lifetime:**
```
Generation: Azure AD issues token
    ↓
Validity: 1 hour (3600 seconds)
    ↓
Caching: MSAL automatically caches and refreshes
    ↓
Expiration: Token service requests new token as needed
```

**Scope:** `https://analysis.windows.net/powerbi/api/.default`

**Characteristics:**
- Cached by MSAL library
- Auto-refreshed when expired
- Not exposed to display client
- Used server-side only

### Embed Token (Power BI API → Display Client)

**Purpose:** Authorizes display client to view specific report

**Lifetime:**
```
Generation: Power BI API issues token (via token service)
    ↓
Validity: 1 hour (3600 seconds) from generation time
    ↓
Refresh: Display client requests new token at 50 minutes
    ↓
Expiration: Old token invalid, new token used
```

**Scope:** Specific workspace + report

**Characteristics:**
- Report-specific (one token per report)
- Passed to display client (public exposure acceptable)
- Manual refresh required (no auto-renewal by Power BI)
- Read-only access (cannot modify report)

### Token Refresh Flow

**At T+50 minutes:**

```javascript
// powerbi-embed.js automatic refresh
setInterval(async () => {
    console.log('Refreshing embed token...');

    // 1. Request new token from token service
    const response = await fetch(tokenServiceUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ groupId, reportId })
    });

    const newTokenData = await response.json();

    // 2. Update Power BI embed with new token
    await report.setAccessToken(newTokenData.token);

    console.log('Token refreshed successfully');
}, TOKEN_REFRESH_INTERVAL);
```

**Why 50 minutes?**
- Tokens expire at 60 minutes
- 10-minute buffer accounts for:
  - Network delays
  - Clock skew between systems
  - Processing time
- Prevents authentication failures during refresh

**What happens if refresh fails?**
- Error displayed on screen
- User sees "Authentication Failed" message
- Display client retries every 5 minutes
- Service restart may be required

---

## Data Refresh Flow

### Automatic Data Refresh

**Purpose:** Update report with latest data from Power BI dataset

**Every 60 seconds:**

```javascript
// powerbi-embed.js automatic data refresh
setInterval(async () => {
    console.log('Refreshing report data...');

    try {
        await report.refresh();
        console.log('Data refreshed successfully');
    } catch (error) {
        console.error('Data refresh failed:', error);
        // Display error message to user
    }
}, DATA_REFRESH_INTERVAL);
```

**Flow:**

```
Display client calls report.refresh()
    ↓
Power BI JavaScript library requests fresh data
    ↓
Power BI service queries dataset
    ↓
New data returned to browser
    ↓
Visuals re-render with updated data
```

**Performance:**
- Network request: ~100ms
- Query execution: 500ms - 5s (depends on dataset complexity)
- Rendering: 500ms - 2s (depends on visual complexity)
- Total: ~1-7 seconds per refresh

**Optimization:**
- Configure `refreshIntervalSeconds` based on data freshness needs
- Simple reports: 30 seconds
- Standard reports: 60 seconds
- Complex reports: 120 seconds

---

## Network Traffic Analysis

### Bandwidth Usage

**Initial Load:**
```
HTML/CSS/JS:           ~500 KB
Power BI Client lib:   ~2 MB
Report metadata:       ~100 KB
Report data:           2-3 MB (varies by complexity)
Visual assets:         ~500 KB
Total:                 ~5-6 MB
```

**Hourly:**
```
Token refresh (1x):    ~2 KB
Data refresh (60x):    50-100 KB each
Total:                 ~3-6 MB/hour
```

**Daily:**
```
Initial load:          ~6 MB
Token refreshes (24):  ~48 KB
Data refreshes (1440): ~72-144 MB
Total:                 ~80-150 MB/day
```

**Monthly:**
```
30 days × 150 MB:      ~4.5 GB/month
```

### Network Endpoints

**Display Client Connections:**

| Endpoint | Purpose | Protocol | Frequency |
|----------|---------|----------|-----------|
| Token Service | Embed token requests | HTTP/HTTPS | Every 50 min |
| login.microsoftonline.com | Azure AD auth (via token service) | HTTPS | Every 50 min |
| api.powerbi.com | Embed token generation | HTTPS | Every 50 min |
| app.powerbi.com | Report content and data | HTTPS | Initial + every 60s |
| cdn.jsdelivr.net | Power BI Client library | HTTPS | Initial load only |

**Request Pattern (over 1 hour):**

```
T+0:    Initial load (all endpoints)
T+1:    Data refresh (app.powerbi.com)
T+2:    Data refresh (app.powerbi.com)
...
T+49:   Data refresh (app.powerbi.com)
T+50:   Token refresh (all endpoints)
T+51:   Data refresh (app.powerbi.com)
...
T+59:   Data refresh (app.powerbi.com)
T+60:   Start next hour
```

---

## Error Handling Flow

### Network Errors

**Scenario:** Token service unreachable

```javascript
try {
    const response = await fetch(tokenServiceUrl, {
        method: 'POST',
        body: JSON.stringify({ groupId, reportId })
    });

    if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const tokenData = await response.json();
} catch (error) {
    // Display user-friendly error
    errorHandler.show(
        'Network Error',
        'Cannot reach token service. Check network connection.',
        error.message
    );

    // Retry after 5 minutes
    setTimeout(retryTokenRequest, 5 * 60 * 1000);
}
```

**User sees:**
```
Network Error
Cannot reach token service. Check network connection.

Details: Failed to fetch
```

### Authentication Errors

**Scenario:** Invalid client secret

```javascript
// Token service catches Azure AD error
try {
    const accessToken = await getAccessToken();
} catch (error) {
    // Log error server-side
    console.error('Azure AD authentication failed:', error);

    // Return error to display client
    res.status(401).json({
        error: 'Authentication failed',
        message: 'Invalid Azure credentials. Contact administrator.',
        details: error.message
    });
}
```

**User sees:**
```
Authentication Failed
Invalid Azure credentials. Contact administrator.
```

### Power BI Errors

**Scenario:** Report not found or insufficient permissions

```javascript
// Token service handles Power BI API errors
const response = await fetch(embedTokenUrl, { ... });

if (!response.ok) {
    const errorData = await response.json();

    res.status(response.status).json({
        error: 'Power BI Error',
        message: 'Cannot access report. Check workspace permissions.',
        details: errorData.error?.message
    });
}
```

**User sees:**
```
Power BI Error
Cannot access report. Check workspace permissions.
```

---

## Performance Optimization

### Caching Strategy

**Token Service:**
- Cache access tokens (MSAL handles automatically)
- Do NOT cache embed tokens (security risk, short lifetime)

**Display Client:**
- Power BI Client library caches report metadata
- Visual assets cached by browser
- Data not cached (always fresh)

### Request Reduction

**Minimize token requests:**
- Use 50-minute refresh (not shorter)
- Don't request tokens on every data refresh
- Batch multiple report requests if possible

**Optimize data refresh:**
- Adjust `refreshIntervalSeconds` based on need
- Simple reports: 30-60 seconds
- Complex reports: 120-300 seconds
- Real-time critical: 15-30 seconds (requires Pi 4+)

### Network Resilience

**Retry Logic:**
```javascript
async function fetchWithRetry(url, options, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            const response = await fetch(url, options);
            if (response.ok) return response;

            // Wait before retry (exponential backoff)
            await new Promise(resolve =>
                setTimeout(resolve, 1000 * Math.pow(2, i))
            );
        } catch (error) {
            if (i === maxRetries - 1) throw error;
        }
    }
}
```

**Timeouts:**
```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 10000); // 10s timeout

try {
    const response = await fetch(url, {
        signal: controller.signal,
        ...options
    });
} finally {
    clearTimeout(timeoutId);
}
```

---

## Monitoring and Logging

### Client-Side Logging

**What to log:**
- Token requests (timestamp, success/failure)
- Data refresh cycles (timestamp, duration)
- Errors (network, auth, Power BI)
- Memory usage (before/after refresh)

**Example:**
```javascript
console.log(`[${new Date().toISOString()}] Token requested`);
console.log(`[${new Date().toISOString()}] Token received, expires at ${expiration}`);
console.log(`[${new Date().toISOString()}] Data refresh completed in 2.3s`);
```

**Accessed via:**
```bash
# SSH to Pi
sudo journalctl -u beacon-display -f
```

### Server-Side Logging

**What to log:**
- Incoming token requests (source IP, timestamp)
- Azure AD authentication (success/failure)
- Power BI API calls (workspace, report, result)
- Errors and stack traces

**Example:**
```javascript
app.post('/api/embed-token', async (req, res) => {
    const { groupId, reportId } = req.body;
    const clientIp = req.ip;

    console.log(`[${new Date().toISOString()}] Token request from ${clientIp} for report ${reportId}`);

    try {
        const embedToken = await generateEmbedToken(groupId, reportId);
        console.log(`[${new Date().toISOString()}] Token generated successfully`);
        res.json(embedToken);
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Token generation failed:`, error);
        res.status(500).json({ error: error.message });
    }
});
```

---

## Debugging Data Flow

### Trace Complete Request

**1. Display client initiates:**
```bash
# Browser console (F12 on Pi)
[2025-11-30T12:00:00] Requesting embed token...
```

**2. Network request sent:**
```bash
# Browser Network tab
POST http://192.168.1.100:3000/api/embed-token
Status: 200 OK
Time: 850ms
```

**3. Token service processes:**
```bash
# Token service console
[2025-11-30T12:00:00] Token request from 192.168.1.150 for report 87654321...
[2025-11-30T12:00:00] Authenticating to Azure AD...
[2025-11-30T12:00:01] Access token acquired
[2025-11-30T12:00:01] Requesting embed token from Power BI...
[2025-11-30T12:00:02] Embed token generated successfully
```

**4. Display client embeds:**
```bash
# Browser console
[2025-11-30T12:00:02] Token received, expires at 2025-11-30T13:00:00Z
[2025-11-30T12:00:02] Embedding report...
[2025-11-30T12:00:05] Report loaded successfully
```

### Common Flow Issues

**Issue: 404 Not Found**
- Check tokenServiceUrl in config.json
- Verify token service is running
- Test with `curl http://TOKEN-SERVICE-URL/health`

**Issue: 401 Unauthorized**
- Check CLIENT_SECRET hasn't expired
- Verify service principal in workspace
- Check API permissions granted

**Issue: Slow loading**
- Check network latency (ping times)
- Simplify Power BI report
- Increase refresh intervals

---

## Related Documentation

- **[Architecture Overview](README.md)** - System design
- **[Components](components.md)** - Component details
- **[Authentication](authentication.md)** - Auth implementation
- **[Security Model](security-model.md)** - Security requirements
- **[Troubleshooting Network](../troubleshooting/network.md)** - Network debugging

---

**Last Updated:** 2025-11-30
