# Phase 1: POC Laptop Setup - Browser Testing

> **Audience**: First-time users and POC testers
> **Duration**: 30 minutes
> **Hardware Required**: None (laptop only)
> **Prerequisites**: None

---

## Objective

Test the BEACON display client in your browser using a public Power BI sample, without needing Azure credentials or a Raspberry Pi.

**What You'll Learn**:
- How the display client works
- Basic configuration structure
- Browser compatibility

**Next Step**: [Phase 2: Azure Setup](azure-configuration.md)

---

## Step 1: Get the Code

Clone or download the BEACON repository:

```bash
# Clone from GitHub
git clone https://github.com/londonperry/beacon-display.git
cd beacon-display

# Or download ZIP and extract
```

---

## Step 2: Prepare Display Client

```bash
# Navigate to display client
cd display-client

# Copy public sample configuration
cp config-public-sample.json config.json

# List files to verify
ls -la config.json
```

**What's in config-public-sample.json?**

This configuration uses Microsoft's public Power BI demo content, so no Azure authentication is required. It displays a sample dashboard to prove the display client works.

---

## Step 3: Open in Browser

```bash
# macOS
open index.html

# Linux (with xdg-open)
xdg-open index.html

# Windows (PowerShell)
Start-Process index.html
```

**Alternative**: Drag `index.html` into your web browser

---

## Step 4: Verify Display

You should see:
- ✅ Power BI dashboard loading animation
- ✅ Sample dashboard with data visualizations
- ✅ No errors in browser console (F12)

**Expected**: The public Power BI sample loads successfully within 10-15 seconds.

---

## Troubleshooting Phase 1

### Blank Screen / Nothing Loads

**Cause**: Browser console errors
**Solution**:
1. Press **F12** to open Developer Tools
2. Click **Console** tab
3. Look for red error messages
4. Check file paths in index.html

### CORS or Network Errors

**Cause**: Browser security blocking external requests
**Solution**:
1. This is expected when opening local HTML files
2. Next phases (token service) resolve this by using a proper web server

### Display Looks Wrong

**Cause**: Browser zoom or resolution
**Solution**:
1. Press **Ctrl+0** (or **Cmd+0** on Mac) to reset zoom
2. Press **F11** for full-screen mode

---

## What's Next?

Once Phase 1 is working, you have two options:

### Option A: Use Public Sample Only
Stop here and test the display client concept. Skip token service and Pi deployment.

### Option B: Use Your Own Power BI Reports
Continue to [Phase 2: Azure Setup](azure-configuration.md) to authenticate with your own Power BI workspace.

---

## Understanding the Configuration

The `config-public-sample.json` file looks like:

```json
{
  "deviceId": "public-sample-demo",
  "tokenServiceUrl": null,
  "groupId": "MICROSOFT_PUBLIC_DEMO_ID",
  "reportId": "MICROSOFT_PUBLIC_DEMO_ID",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {}
}
```

**Note**: `tokenServiceUrl` is `null` for the public sample because it uses Microsoft's public demo (no authentication needed).

For details on configuration options, see [Configuration Reference](configuration-reference.md).

---

## Testing the Display Client Code

The display client consists of three JavaScript files:

- `js/config-loader.js` - Loads and validates configuration
- `js/powerbi-embed.js` - Integrates Power BI client library
- `js/error-handler.js` - Displays user-friendly error messages

Open **index.html** in a text editor to see the HTML structure and understand how these pieces fit together.

---

## Browser Requirements

**Supported Browsers**:
- ✅ Chrome 90+
- ✅ Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Chromium (used on Raspberry Pi)

**Not Supported**:
- ❌ Internet Explorer (no ES6 support)

---

## Performance Notes

At this stage, performance depends on your internet connection and Power BI service availability. Once you move to Phase 3 (token service), you'll use your own workspace for more predictable performance.

---

## Advancing to Phase 2

Ready for the next phase? Go to [Phase 2: Azure Configuration](azure-configuration.md) to set up:
- Azure Active Directory service principal
- Power BI workspace and permissions
- Client secret for authentication

---

## Related Documentation

- **[Setup Overview](README.md)** - All setup phases
- **[Azure Configuration](azure-configuration.md)** - Phase 2: Set up Azure AD
- **[Configuration Reference](configuration-reference.md)** - Config file schema
- **[Troubleshooting: Display Client](../troubleshooting/display-client.md)** - Common issues
- **[Architecture: Display Client](../architecture/components.md)** - Technical details
