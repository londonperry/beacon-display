# Configuration Reference

> **Audience**: Technical users and administrators
> **Purpose**: Complete configuration file schema and options
> **Use Case**: Understanding all configuration options for display-client and token-service

---

## Display Client Configuration

### File Location

`display-client/config.json`

### Full Schema

```json
{
  "deviceId": "string",
  "tokenServiceUrl": "string or null",
  "groupId": "string",
  "reportId": "string",
  "refreshIntervalSeconds": number,
  "tokenRefreshMinutes": number,
  "filters": {
    "filterName": "value"
  }
}
```

---

## Configuration Fields

### deviceId

**Type**: String
**Required**: Yes
**Description**: Unique identifier for this display device

**Purpose**:
- Logged in service health checks
- Device identification in multi-display deployments
- Debugging and support

**Examples**:
```json
"deviceId": "store-001-backroom"
"deviceId": "executive-dashboard-ny"
"deviceId": "pi-zero-001"
```

**Naming Convention**: `[location]-[department]-[number]`

---

### tokenServiceUrl

**Type**: String or null
**Required**: Conditional (required if using Power BI with authentication)
**Default**: null
**Description**: URL to token service endpoint for generating embed tokens

**Purpose**:
- Points display client to authentication service
- If null, uses public/demo Power BI content (no auth)

**Examples**:

**POC (Local Token Service)**:
```json
"tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token"
```

**Production (Cloud Token Service)**:
```json
"tokenServiceUrl": "https://beacon-token.company.com/api/embed-token"
```

**Public Demo (No Auth)**:
```json
"tokenServiceUrl": null
```

**Format Requirements**:
- Must be valid URL with protocol (`http://` or `https://`)
- Must include full path to endpoint (`/api/embed-token`)
- No trailing slash

---

### groupId

**Type**: String (GUID)
**Required**: Yes
**Description**: Power BI workspace ID

**How to Find**:
1. Open Power BI workspace
2. Look at URL: `app.powerbi.com/groups/{THIS-IS-GROUP-ID}/...`
3. Copy the GUID between `/groups/` and `/dashboards` or `/reports`

**Example**:
```json
"groupId": "a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5"
```

**Important**:
- Must be workspace GUID, not workspace name
- Cannot use "My Workspace" (must be shared workspace)
- If wrong ID, you'll get authentication or permission errors

---

### reportId

**Type**: String (GUID)
**Required**: Yes
**Description**: Power BI report ID

**How to Find**:
1. Open Power BI report (not dashboard)
2. Look at URL: `.../reports/{THIS-IS-REPORT-ID}/...`
3. Copy the GUID between `/reports/` and the next `/`

**Example**:
```json
"reportId": "f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1"
```

**Important**:
- Must be report ID, not dashboard ID
- Reports and dashboards have different IDs
- If wrong, report won't load

**Difference**:
- **Report URL**: `.../reports/{REPORT-ID}/...`
- **Dashboard URL**: `.../dashboards/{DASHBOARD-ID}/...`

---

### refreshIntervalSeconds

**Type**: Number (integer)
**Required**: Yes
**Default**: 60
**Range**: 30-3600 (30 seconds to 1 hour)
**Description**: How often the Power BI report data refreshes

**Purpose**:
- Controls data freshness on display
- Affects network bandwidth usage
- Can impact Pi memory usage

**Examples**:

**Real-time Monitoring** (refresh every 30 seconds):
```json
"refreshIntervalSeconds": 30
```

**Standard Operations** (refresh every 60 seconds):
```json
"refreshIntervalSeconds": 60
```

**Bandwidth Constrained** (refresh every 5 minutes):
```json
"refreshIntervalSeconds": 300
```

**Performance Tuning**:
- **Pi Zero 2 W**: Use 60+ seconds (limited memory)
- **Pi 4/5**: Can use 30+ seconds (more memory)
- **Complex reports**: Use 60+ seconds (slower refresh)
- **Simple dashboards**: Can use 30 seconds (faster)

---

### tokenRefreshMinutes

**Type**: Number (integer)
**Required**: Yes
**Default**: 50
**Range**: 1-59 (must be less than 60)
**Description**: How often embed token is renewed

**Purpose**:
- Embed tokens expire after 60 minutes
- Must refresh before expiration
- If not refreshed, display goes blank after 1 hour

**Examples**:

**Standard** (refresh at 50 minutes):
```json
"tokenRefreshMinutes": 50
```

**Conservative** (refresh at 45 minutes):
```json
"tokenRefreshMinutes": 45
```

**Aggressive** (refresh at 55 minutes):
```json
"tokenRefreshMinutes": 55
```

**Important**:
- **Must be less than 60** (token expiry time)
- 50 is recommended (10-minute buffer)
- If higher than 60, display will go blank

---

### filters

**Type**: Object (key-value pairs)
**Required**: No (can be empty object {})
**Default**: {}
**Description**: Report-level filters applied at load time

**Purpose**:
- Filter report to specific data
- Store-specific dashboards without creating multiple reports
- Row-level security alternative

**Examples**:

**No Filters**:
```json
"filters": {}
```

**Single Filter**:
```json
"filters": {
  "storeId": "001"
}
```

**Multiple Filters**:
```json
"filters": {
  "storeId": "001",
  "region": "Northeast",
  "department": "Sales"
}
```

**Format**:
- Key: Filter field name (must match Power BI field exactly)
- Value: Filter value (string)
- Multiple filters combined as AND logic

**Important**:
- Filters are applied at report load time
- Power BI must have these fields available
- Case-sensitive field names
- Not suitable for highly dynamic filters

---

## Token Service Configuration

### File Location

`token-service/laptop-version/.env` (POC)
`token-service/cloud-version/.env` (Production)

### Schema

```bash
TENANT_ID=azure-tenant-guid
CLIENT_ID=azure-client-id
CLIENT_SECRET=azure-client-secret
PORT=3000
NODE_ENV=development
```

---

## Token Service Fields

### TENANT_ID

**Type**: String (GUID)
**Required**: Yes
**Description**: Azure Active Directory tenant ID

**How to Find**:
1. Azure Portal → Azure AD → Properties
2. Copy "Directory (tenant) ID"

**Example**:
```bash
TENANT_ID=a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5
```

---

### CLIENT_ID

**Type**: String (GUID)
**Required**: Yes
**Description**: Azure app registration client ID

**How to Find**:
1. Azure Portal → Azure AD → App registrations → Your app
2. Copy "Application (client) ID"

**Example**:
```bash
CLIENT_ID=f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1
```

---

### CLIENT_SECRET

**Type**: String
**Required**: Yes
**Description**: Azure app registration client secret value

**How to Create**:
1. Azure Portal → Your app → Certificates & secrets
2. Click "+ New client secret"
3. Copy Value column immediately (cannot view again)

**Example**:
```bash
CLIENT_SECRET=ABC~xyz123.secretvalue456.abc.def
```

**⚠️ Security**:
- Never commit to Git
- Never share
- Rotate every 12 months
- Should be 30-40 characters

---

### PORT

**Type**: Number
**Default**: 3000
**Description**: Port token service listens on

**Examples**:
```bash
PORT=3000           # Standard
PORT=8080           # Common alternative
PORT=3100           # If 3000 already in use
```

**POC vs Production**:
- **POC**: HTTP on port 3000 (laptop)
- **Production**: HTTPS on port 443 (cloud)

---

### NODE_ENV

**Type**: String
**Values**: `development` or `production`
**Default**: development
**Description**: Environment mode

**Examples**:
```bash
NODE_ENV=development    # POC (more logging)
NODE_ENV=production     # Cloud (minimal logging)
```

**Differences**:
- **development**: Verbose logging, helpful error messages
- **production**: Minimal logging, optimized performance

---

## Configuration Examples

### Example 1: POC with Local Token Service

**display-client/config.json**:
```json
{
  "deviceId": "laptop-test-001",
  "tokenServiceUrl": "http://localhost:3000/api/embed-token",
  "groupId": "a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5",
  "reportId": "f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {}
}
```

**token-service/.env**:
```bash
TENANT_ID=a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5
CLIENT_ID=f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1
CLIENT_SECRET=ABC~xyz123.secret456
PORT=3000
NODE_ENV=development
```

---

### Example 2: Pi Deployment with Store Filter

**display-client/config.json**:
```json
{
  "deviceId": "store-001-backroom",
  "tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token",
  "groupId": "a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5",
  "reportId": "f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {
    "storeId": "001"
  }
}
```

---

### Example 3: Production Cloud Deployment

**display-client/config.json**:
```json
{
  "deviceId": "store-001-backroom",
  "tokenServiceUrl": "https://beacon-token.company.com/api/embed-token",
  "groupId": "a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5",
  "reportId": "f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {
    "storeId": "001",
    "region": "Northeast"
  }
}
```

**token-service/.env** (on cloud server):
```bash
TENANT_ID=a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5
CLIENT_ID=f1e2d3c4-b5a4-4321-8765-4321a1b1c1d1
CLIENT_SECRET=ABC~xyz123.secret456
PORT=3000
NODE_ENV=production
```

---

## Validation

### Checking Configuration

Use these commands to validate your configuration:

**Display Client**:
```bash
# Check config.json is valid JSON
cd display-client
cat config.json | jq .   # Requires jq tool, or just open in editor
```

**Token Service**:
```bash
# Check .env syntax
cd token-service/laptop-version
cat .env

# Verify token service is working
npm start
curl http://localhost:3000/health
```

---

## Troubleshooting Configuration

### "Invalid JSON in config.json"

**Cause**: JSON syntax error (missing comma, quote, etc.)
**Solution**:
1. Open config.json in code editor
2. Use editor's JSON validator
3. Check for trailing commas
4. Ensure all quotes are closed

### "groupId or reportId not found"

**Cause**: Wrong ID format or not found in Power BI
**Solution**:
1. Verify IDs from Power BI URLs (not copied exactly)
2. Ensure no extra spaces or characters
3. Use correct Power BI workspace and report

### "tokenServiceUrl returns 401 Unauthorized"

**Cause**: Azure credentials invalid in .env
**Solution**:
1. Verify TENANT_ID, CLIENT_ID, CLIENT_SECRET match Azure Portal
2. Verify service principal added to Power BI workspace
3. Check client secret hasn't expired

### "refreshIntervalSeconds too high"

**Cause**: Configured >3600 seconds
**Solution**:
1. Set to reasonable value: 30-300 seconds
2. Higher values reduce bandwidth but delay data freshness

---

## Related Documentation

- **[Setup Overview](README.md)** - Setup phases
- **[Token Service Setup](token-service.md)** - Using token service
- **[Raspberry Pi Deployment](raspberry-pi.md)** - Configuring Pi
- **[Architecture: Authentication](../architecture/authentication.md)** - How auth works
- **[Troubleshooting](../troubleshooting/README.md)** - Common issues
