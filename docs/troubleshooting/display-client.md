# Display Client Troubleshooting

**Audience:** For diagnosing browser and Power BI embed issues

This document covers blank screens, embed errors, loading failures, browser errors, and refresh problems.

---

## Blank Screen Issues

### Issue: Blank/Black Screen on Display

**Symptoms:**
- Display powers on but shows nothing
- No error messages
- Black screen with or without cursor

#### Diagnosis

**1. Check HDMI connection:**
```bash
# On Pi, check HDMI status
tvservice -s
# Should show: state 0x12000a [HDMI CEA (16) RGB lim 16:9], 1920x1080 @ 60.00Hz
```

**2. Check if service is running:**
```bash
sudo systemctl status beacon-display
# Should show "active (running)"
```

**3. Check X server:**
```bash
ps aux | grep X
# Should show X server process
```

**4. Check Chromium process:**
```bash
ps aux | grep chromium
# Should show chromium-browser process
```

#### Solutions

**1. Restart display service:**
```bash
sudo systemctl restart beacon-display

# Check status
sudo systemctl status beacon-display

# View logs
sudo journalctl -u beacon-display -n 50
```

**2. Force HDMI output:**
```bash
# Edit /boot/config.txt
sudo nano /boot/config.txt

# Add/uncomment:
hdmi_force_hotplug=1
hdmi_drive=2

# Save and reboot
sudo reboot
```

**3. Test HDMI cable:**
- Try different HDMI cable
- Try different TV/monitor input
- Verify mini-HDMI (not micro-HDMI)

**4. Manual start for debugging:**
```bash
# Stop service
sudo systemctl stop beacon-display

# Run manually
cd ~/beacon-display/raspberry-pi
./start-display.sh

# Watch for errors in output
```

---

## Loading Forever Issues

### Issue: "Loading..." Message Never Disappears

**Symptoms:**
- Display shows "Loading..." indefinitely
- Network request never completes
- No error message

#### Diagnosis

**1. Check token service (on laptop):**
```bash
curl http://localhost:3000/health
# Should return: {"status":"healthy"}
```

**2. Check from Pi:**
```bash
# Test ping
ping -c 3 YOUR-LAPTOP-IP

# Test token service
curl http://YOUR-LAPTOP-IP:3000/health
```

**3. Check config.json:**
```bash
cat ~/beacon-display/display-client/config.json
# Verify tokenServiceUrl has correct IP:port
```

**4. Check firewall:**
```bash
# Mac: System Preferences → Security → Firewall
# Linux: sudo ufw status
# Windows: Windows Defender Firewall
```

#### Solutions

**1. Start token service:**
```bash
# On laptop
cd token-service/laptop-version
npm start
```

**2. Fix tokenServiceUrl:**
```bash
# Edit config.json
nano ~/beacon-display/display-client/config.json

# Update to correct laptop IP
{
  "tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token"
}

# Restart display
sudo systemctl restart beacon-display
```

**3. Allow firewall:**
```bash
# Mac
# System Preferences → Security & Privacy → Firewall
# Firewall Options → Add Node.js, Allow incoming connections

# Linux
sudo ufw allow 3000

# Windows
# Windows Defender → Advanced settings → Inbound Rules
# New Rule → Port 3000 → Allow
```

**4. Test from Pi:**
```bash
# Verify connectivity
curl http://YOUR-LAPTOP-IP:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{"groupId":"YOUR-GROUP-ID","reportId":"YOUR-REPORT-ID"}'

# Should return token object
```

---

## Embed Errors

### Issue: "Failed to Embed Report"

**Symptoms:**
- Error message on display
- Power BI embed fails
- JavaScript errors in logs

#### Diagnosis

**1. Check browser console (if accessible):**
```bash
# Press F12 (if keyboard connected to Pi)
# Or check logs:
sudo journalctl -u beacon-display -n 100 | grep -i error
```

**2. Verify Power BI embed token:**
```bash
# Test token generation
curl -X POST http://YOUR-LAPTOP-IP:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{"groupId":"YOUR-GROUP-ID","reportId":"YOUR-REPORT-ID"}'

# Check response has token, expiration, reportId
```

**3. Check groupId and reportId:**
```bash
# From Power BI URL:
# app.powerbi.com/groups/{GROUP-ID}/reports/{REPORT-ID}/...

# Compare with config.json
cat ~/beacon-display/display-client/config.json | grep -E "groupId|reportId"
```

#### Solutions

**1. Correct IDs in config.json:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "groupId": "CORRECT-WORKSPACE-GUID",
  "reportId": "CORRECT-REPORT-GUID"
}

# Restart
sudo systemctl restart beacon-display
```

**2. Check Power BI permissions:**
```bash
# Power BI Service → Workspace → Workspace access
# Verify service principal is Member
```

**3. Verify report is published:**
```bash
# Open report in Power BI Service
# Ensure it loads successfully
# Check it's in correct workspace
```

**4. Clear browser cache:**
```bash
# Stop service
sudo systemctl stop beacon-display

# Clear Chromium cache
rm -rf ~/.cache/chromium

# Restart
sudo systemctl start beacon-display
```

---

## Refresh Failures

### Issue: Report Loads But Doesn't Refresh

**Symptoms:**
- Initial load successful
- Data becomes stale
- No automatic updates

#### Diagnosis

**1. Check refreshIntervalSeconds:**
```bash
cat ~/beacon-display/display-client/config.json | grep refreshIntervalSeconds
# Should be 60 (or desired interval)
```

**2. Check service is running:**
```bash
sudo systemctl status beacon-display
# Should show "active (running)" continuously
```

**3. Check logs for refresh attempts:**
```bash
sudo journalctl -u beacon-display -f
# Should see periodic refresh messages
```

**4. Check network connectivity:**
```bash
ping -c 5 api.powerbi.com
```

#### Solutions

**1. Verify refresh configuration:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50
}

# Restart service
sudo systemctl restart beacon-display
```

**2. Check JavaScript console:**
```bash
# If browser errors, check logs
sudo journalctl -u beacon-display -n 200 | grep -i "refresh\|error"
```

**3. Restart display service:**
```bash
sudo systemctl restart beacon-display
```

**4. Test network stability:**
```bash
# Ping test for 5 minutes
ping -c 300 api.powerbi.com
# Check for packet loss
```

---

## Token Expiry Issues

### Issue: "Authentication Failed" After 1 Hour

**Symptoms:**
- Report works initially
- Stops working after ~1 hour
- Error about authentication or token expiry

#### Diagnosis

**1. Check tokenRefreshMinutes:**
```bash
cat ~/beacon-display/display-client/config.json | grep tokenRefreshMinutes
# Should be 50 (less than 60-minute token expiry)
```

**2. Check token service is still running:**
```bash
# From laptop
curl http://localhost:3000/health

# From Pi
curl http://YOUR-LAPTOP-IP:3000/health
```

**3. Check logs around expiry time:**
```bash
# Check logs at ~50 minutes after start
sudo journalctl -u beacon-display -n 100 | grep -i "token\|refresh"
```

#### Solutions

**1. Ensure tokenRefreshMinutes < 60:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "tokenRefreshMinutes": 50
}

# Restart
sudo systemctl restart beacon-display
```

**2. Verify token service uptime:**
```bash
# Ensure token service stays running
# On laptop, run in background or as service

# Option 1: Background process
cd token-service/laptop-version
nohup npm start > /tmp/token-service.log 2>&1 &

# Option 2: Keep laptop awake
# Mac: System Preferences → Energy Saver → Prevent sleep
```

**3. Check network stability:**
```bash
# Ensure WiFi doesn't disconnect
# Pi may lose connection to token service

# Test continuous connectivity
ping -c 360 YOUR-LAPTOP-IP  # 5 minutes
```

**4. Add token refresh logging:**
```javascript
// In powerbi-embed.js, add console.log for debugging
console.log(`Token refresh scheduled for ${TOKEN_REFRESH_INTERVAL / 60000} minutes`);

setInterval(async () => {
    console.log('Refreshing token at', new Date());
    // ... refresh code
}, TOKEN_REFRESH_INTERVAL);
```

---

## Browser Errors

### Issue: Chromium Crashes or Freezes

**Symptoms:**
- Display freezes
- Chromium process crashes
- High memory usage
- System becomes unresponsive

#### Diagnosis

**1. Check memory usage:**
```bash
free -h
# Used should be <400MB on Pi Zero 2 W
```

**2. Check Chromium process:**
```bash
ps aux | grep chromium
# Check memory column (%MEM)
```

**3. Check for crashes in logs:**
```bash
sudo journalctl -u beacon-display -n 200 | grep -i "crash\|killed\|oom"
```

**4. Check temperature:**
```bash
vcgencmd measure_temp
# Should be <60°C
```

#### Solutions

**1. Simplify Power BI report:**
- Reduce number of visuals (5 or fewer for Pi Zero 2 W)
- Remove complex visuals (maps, scatter plots)
- Apply filters to reduce data volume
- Use simpler chart types

**2. Increase refresh interval:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "refreshIntervalSeconds": 120  # Instead of 60
}
```

**3. Restart service (watchdog does this automatically):**
```bash
sudo systemctl restart beacon-display
```

**4. Check watchdog is working:**
```bash
# Watchdog should auto-restart at 85% memory
sudo systemctl status beacon-display | grep -i memory

# Check MemoryMax setting
sudo systemctl show beacon-display | grep MemoryMax
# Should show: MemoryMax=412M (for Pi Zero 2 W)
```

**5. Upgrade hardware if needed:**
- Pi 4 (2GB) for complex reports
- Better performance, more memory headroom

---

## JavaScript Errors

### Issue: JavaScript Errors in Console

**Symptoms:**
- Errors in browser console
- Unexpected behavior
- Features not working

#### Diagnosis

**1. View logs:**
```bash
sudo journalctl -u beacon-display -n 200 | grep -i "error\|exception"
```

**2. Check file integrity:**
```bash
# Ensure all files present
ls -la ~/beacon-display/display-client/js/
# Should have: powerbi-embed.js, config-loader.js, error-handler.js
```

**3. Check Power BI Client library:**
```bash
# View index.html
cat ~/beacon-display/display-client/index.html | grep powerbi
# Should load from CDN: cdn.jsdelivr.net
```

#### Solutions

**1. Redeploy files:**
```bash
# From laptop
./scripts/deploy-to-pi.sh YOUR-PI-IP

# On Pi
sudo systemctl restart beacon-display
```

**2. Check CDN access:**
```bash
# Ensure Pi can reach CDN
curl -I https://cdn.jsdelivr.net/npm/powerbi-client@2.22.3/dist/powerbi.min.js

# Should return: 200 OK
```

**3. Test in browser on laptop:**
```bash
# Open display-client/index.html in browser
# Check console (F12) for errors
# Fix any issues found
```

---

## Network Request Failures

### Issue: Network Requests Fail Intermittently

**Symptoms:**
- Occasional failures
- Timeouts
- "Network Error" messages

#### Diagnosis

**1. Test network stability:**
```bash
# Continuous ping test
ping -c 300 app.powerbi.com

# Check packet loss percentage
```

**2. Check WiFi signal:**
```bash
iwconfig wlan0 | grep "Signal level"
# Good: -30 to -50 dBm
# Poor: -70 to -80 dBm
```

**3. Monitor network:**
```bash
# Watch network interface
watch -n 1 ifconfig wlan0
```

#### Solutions

**1. Improve WiFi signal:**
- Move Pi closer to router
- Use WiFi extender
- Change router channel (less interference)

**2. Switch to Ethernet:**
```bash
# For Pi Zero 2 W: USB Ethernet adapter
# For Pi 4/5: Built-in Gigabit Ethernet
# More reliable than WiFi
```

**3. Add retry logic (already in code):**
```javascript
// powerbi-embed.js already has retry logic
// Increase retries if needed
const MAX_RETRIES = 5;  // Instead of 3
```

**4. Increase timeout:**
```javascript
// In config.json or code
const TIMEOUT_MS = 30000;  // 30 seconds
```

---

## Related Documentation

- **[Troubleshooting Overview](README.md)** - Diagnostic approach
- **[Token Service Issues](token-service.md)** - Authentication problems
- **[Raspberry Pi Issues](raspberry-pi.md)** - Hardware and system problems
- **[Network Issues](network.md)** - Connectivity problems
- **[Data Flow](../architecture/data-flow.md)** - Understanding request flow

---

**Last Updated:** 2025-11-30
