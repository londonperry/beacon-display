# Phase 3: Token Service Setup

> **Audience**: Developers and IT staff
> **Duration**: 1 hour
> **Prerequisites**: Completed Phase 2 (Azure configuration), Node.js 18+
> **After This Phase**: Token service running, generating embed tokens

---

## Objective

Install and run the BEACON token service on your laptop. This Node.js service authenticates with Azure AD and generates Power BI embed tokens every time the display requests one.

**What Happens**:
1. Token service starts on your laptop at `localhost:3000`
2. Display sends token request to token service
3. Token service authenticates with Azure AD using your service principal
4. Azure returns access token
5. Token service requests embed token from Power BI
6. Power BI returns embed token
7. Display receives token and renders report

---

## Step 1: Install Node.js

### Check if Already Installed

```bash
node --version      # Should show v18.x or v20.x
npm --version       # Should show 9.x or higher
```

### If Not Installed

1. Download [Node.js LTS](https://nodejs.org/) (version 18 or 20)
2. Run installer and follow prompts
3. Verify installation:
   ```bash
   node --version
   npm --version
   ```

---

## Step 2: Navigate to Token Service

```bash
# From beacon-display root directory
cd token-service/laptop-version

# Verify you're in the right place
ls -la
# You should see: server.js, package.json, .env.example
```

---

## Step 3: Install Dependencies

```bash
npm install
```

This reads `package.json` and downloads required packages:
- `express` - Web server
- `@azure/msal-node` - Azure authentication
- `dotenv` - Environment variable management
- `cors` - Cross-origin request handling

**Time**: 2-5 minutes (downloads ~100MB)

---

## Step 4: Configure Environment Variables

### 4.1 Create .env File

```bash
cp .env.example .env
```

### 4.2 Edit .env

Open `.env` in a text editor:

```bash
# macOS/Linux
nano .env

# OR any editor
code .env     # VS Code
vim .env      # Vim
```

### 4.3 Add Your Azure Credentials

Enter the values from Phase 2:

```bash
TENANT_ID=your-directory-id-here
CLIENT_ID=your-client-id-here
CLIENT_SECRET=your-client-secret-value-here
PORT=3000
NODE_ENV=development
```

**Example** (with fake values):

```bash
TENANT_ID=a1b2c3d4-e5f6-4g7h-8i9j-k0l1m2n3o4p5
CLIENT_ID=f9e8d7c6-b5a4-4321-8765-4321a1b1c1d1
CLIENT_SECRET=ABC~xyz123_secretvalue456.abc
PORT=3000
NODE_ENV=development
```

### 4.4 Save File

- **nano**: Press `Ctrl+X`, then `Y`, then Enter
- **code**: Press `Cmd+S` or `Ctrl+S`
- **vim**: Press `:wq` then Enter

---

## Step 5: Start Token Service

```bash
npm start
```

You should see output similar to:

```
> server.js
Token service listening on port 3000
```

**Don't close this terminal** - the service runs in the foreground.

---

## Step 6: Test Token Service (New Terminal)

Open a new terminal window:

### Test Health Endpoint

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{"status":"healthy","uptime":123.456}
```

### Test Embed Token Generation

```bash
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{"groupId":"YOUR-GROUP-ID","reportId":"YOUR-REPORT-ID"}'
```

Replace with **your actual IDs from Phase 2**:

Expected response:

```json
{
  "embedToken": "eyJ0eXAiOiJKV1...",
  "embedUrl": "https://app.powerbi.com/reportEmbed?reportId=...",
  "expiration": "2025-01-20T15:30:00.000Z"
}
```

**If you see an error**, check:
1. IDs are correct (no extra spaces)
2. Service principal is added to workspace (Phase 2)
3. Service principal has Member role (not Viewer)
4. Check token service console for error details

---

## Step 7: Find Your Laptop IP Address

The Raspberry Pi needs to reach your laptop on your local network.

### macOS/Linux

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Look for something like: `inet 192.168.1.100`

### Windows (PowerShell)

```powershell
ipconfig | findstr IPv4
```

Look for `IPv4 Address: 192.168.x.x`

**Record this IP**: `____________________`

---

## Configuration Summary

After Phase 3, you have:

✅ Token service running on laptop
✅ Service accessible at `http://localhost:3000`
✅ Health check passing
✅ Embed tokens generating successfully
✅ Laptop IP address identified

---

## Troubleshooting Phase 3

### "Cannot find module '@azure/msal-node'"

**Cause**: npm install didn't complete
**Solution**:
1. Delete `node_modules` folder: `rm -rf node_modules`
2. Reinstall: `npm install`
3. Try `npm start` again

### "Error: ENOENT: no such file or directory, open '.env'"

**Cause**: .env file not created
**Solution**:
1. Verify you're in `token-service/laptop-version` directory
2. Run: `cp .env.example .env`
3. Edit and add your credentials

### curl returns "401 Unauthorized"

**Cause**: Azure credentials invalid or service principal not added to workspace
**Solution**:
1. Verify TENANT_ID, CLIENT_ID, CLIENT_SECRET match Azure Portal exactly
2. Verify service principal added to Power BI workspace as Member
3. Check token service console for detailed error

### "ERR_REFUSED" when curl localhost:3000

**Cause**: Token service not running
**Solution**:
1. Check if terminal is still running token service
2. If closed, restart: `npm start`
3. Wait 2-3 seconds for startup

### Display service still says "loading..."

This will be fixed in Phase 4 when you configure the display client with your token service URL.

---

## Security Reminders

⚠️ **For POC (Laptop)**:
- .env file with secrets is acceptable locally
- .env is in .gitignore (won't commit)
- Keep laptop on WiFi for security

⚠️ **For Production**:
- Move secrets to Azure Key Vault
- Use HTTPS (not HTTP)
- Restrict network access to token service
- See [Security Model](../architecture/security-model.md)

---

## Keeping Token Service Running

### Option A: Keep Terminal Open
The simplest approach - just keep the terminal window open while testing.

### Option B: Background Process
Run in background and write to log file:

```bash
npm start > token-service.log 2>&1 &
echo $! > token-service.pid
```

To stop later:
```bash
kill $(cat token-service.pid)
```

### Option C: Use Process Manager (Production)
For permanent deployment, see [DEPLOYMENT.md](../deployment/README.md).

---

## Next Phase

Now your token service is running! Continue to [Phase 4: Raspberry Pi Deployment](raspberry-pi.md) to:
1. Deploy display client to Pi
2. Configure display client to use your token service
3. Test end-to-end integration

---

## Related Documentation

- **[Setup Overview](README.md)** - All setup phases
- **[Raspberry Pi Deployment](raspberry-pi.md)** - Phase 4: Use this token service
- **[Configuration Reference](configuration-reference.md)** - Config options
- **[Token Service Troubleshooting](../troubleshooting/token-service.md)** - Advanced diagnostics
- **[Architecture: Authentication](../architecture/authentication.md)** - How authentication works
- **[DEPLOYMENT.md](../deployment/README.md)** - Production token service setup
