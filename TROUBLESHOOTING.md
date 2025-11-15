# BEACON Troubleshooting

Common issues and diagnostic procedures.

## Quick Diagnostic Commands

### On Raspberry Pi
```bash
# Check display service status
sudo systemctl status beacon-display

# View recent logs
sudo journalctl -u beacon-display -n 50

# Check memory usage (should be <400MB)
free -h

# Check CPU temperature (should be <60°C)
vcgencmd measure_temp

# Test network connectivity
ping -c 3 8.8.8.8
ping -c 3 YOUR-LAPTOP-IP

# Test token service reachability
curl http://YOUR-LAPTOP-IP:3000/health
```

### On Your Laptop
```bash
# Check token service is running
curl http://localhost:3000/health

# Test embed token generation
curl -X POST http://localhost:3000/api/embed-token \
  -H "Content-Type: application/json" \
  -d '{"groupId":"YOUR-GROUP-ID","reportId":"YOUR-REPORT-ID"}'

# Find laptop IP address
# Mac/Linux:
ifconfig | grep "inet " | grep -v 127.0.0.1
# Windows:
ipconfig | findstr IPv4
```

---

## Common Issues

### Issue: Pi Won't Boot

**Symptoms**: No HDMI output, no activity LED flashing

**Causes**:
- Corrupt SD card
- Insufficient power supply
- Bad SD card image
- HDMI cable/TV issue

**Solutions**:
1. Check power supply is 2.5A minimum
2. Try different power cable
3. Reflash SD card with Raspberry Pi Imager
4. Try different SD card
5. Check HDMI cable is firmly connected
6. Try different TV/monitor input
7. Check mini-HDMI end (not micro-HDMI)

---

### Issue: Display Shows "Loading..." Forever

**Symptoms**: Loading message never disappears, blank screen

**Causes**:
- Token service not running
- Network connectivity issue
- Wrong tokenServiceUrl in config.json
- Laptop firewall blocking port 3000

**Solutions**:
1. **Check token service is running** on laptop:
   ```bash
   curl http://localhost:3000/health
   ```
   If fails: Start token service (`npm start` in token-service/laptop-version)

2. **Verify Pi can reach laptop**:
   ```bash
   # From Pi:
   ping YOUR-LAPTOP-IP
   curl http://YOUR-LAPTOP-IP:3000/health
   ```

3. **Check config.json** has correct IP:
   ```bash
   # On Pi:
   cat ~/beacon-display/display-client/config.json
   # tokenServiceUrl should be http://YOUR-LAPTOP-IP:3000/api/embed-token
   ```

4. **Check laptop firewall**:
   - Mac: System Preferences → Security → Firewall → Allow port 3000
   - Windows: Windows Defender → Allow port 3000
   - Linux: `sudo ufw allow 3000`

5. **View browser console** (if testing in browser on laptop):
   - Open index.html
   - Press F12
   - Look for errors in Console tab

---

### Issue: "Failed to Generate Embed Token"

**Symptoms**: Error message displayed on screen

**Causes**:
- Wrong Azure credentials in .env
- Client secret expired
- Service principal not added to Power BI workspace
- Wrong workspace/report ID

**Solutions**:
1. **Test token service directly**:
   ```bash
   curl http://localhost:3000/health
   ```
   Should return: `{"status":"healthy"}`

2. **Verify .env file** has correct values:
   ```bash
   cd token-service/laptop-version
   cat .env
   # Check TENANT_ID, CLIENT_ID, CLIENT_SECRET match Azure Portal
   ```

3. **Check client secret hasn't expired**:
   - Azure Portal → Azure AD → App registrations → Your app
   - Certificates & secrets
   - Check expiration date (12-month validity)
   - Create new secret if expired

4. **Verify service principal in workspace**:
   - Go to app.powerbi.com
   - Open workspace
   - Click **...** → Workspace access
   - Search for your app name (BEACON-Display-POC)
   - Should have **Member** role

5. **Verify workspace and report IDs**:
   - Workspace URL: `app.powerbi.com/groups/{THIS-IS-GROUP-ID}/...`
   - Report URL: `.../reports/{THIS-IS-REPORT-ID}/...`
   - Must match config.json values

6. **Check token service logs**:
   ```bash
   # Restart token service with logging
   cd token-service/laptop-version
   npm start
   # Watch console output for errors
   ```

---

### Issue: Report Loads But Doesn't Refresh

**Symptoms**: Report shows old/stale data

**Causes**:
- Auto-refresh not working
- JavaScript errors
- Network timeout
- Display service crashed

**Solutions**:
1. **Check refreshIntervalSeconds** in config.json:
   ```bash
   cat ~/beacon-display/display-client/config.json
   # Should have "refreshIntervalSeconds": 60
   ```

2. **Restart display service**:
   ```bash
   sudo systemctl restart beacon-display
   ```

3. **Check service status**:
   ```bash
   sudo systemctl status beacon-display
   # Should show "active (running)"
   ```

4. **View logs for errors**:
   ```bash
   sudo journalctl -u beacon-display -n 100
   ```

5. **Check network connectivity**:
   ```bash
   ping -c 5 api.powerbi.com
   ```

---

### Issue: "Authentication Failed" After 1 Hour

**Symptoms**: Report disappears or shows login prompt after ~1 hour

**Causes**:
- Token not refreshing (embed tokens expire after 1 hour)
- tokenRefreshMinutes set too high

**Solutions**:
1. **Check tokenRefreshMinutes** in config.json:
   ```json
   {
     "tokenRefreshMinutes": 50
   }
   ```
   Should be **less than 60** (token expiry), recommended **50**

2. **Verify token service is running**:
   ```bash
   curl http://YOUR-LAPTOP-IP:3000/health
   ```

3. **Check browser console** for refresh errors (if testing on laptop)

4. **Restart display**:
   ```bash
   sudo systemctl restart beacon-display
   ```

---

### Issue: High Memory Usage / Pi Crashes

**Symptoms**: Pi becomes unresponsive, display frozen, system restart

**Causes**:
- Complex Power BI report
- Memory leak
- Too many browser processes

**Solutions**:
1. **Check current memory usage**:
   ```bash
   free -h
   # Used memory should be <400MB (80% of 512MB)
   ```

2. **Watchdog auto-restarts** if memory >85%:
   ```bash
   # Check if watchdog is running
   sudo systemctl status beacon-display
   ```

3. **Simplify Power BI report**:
   - Reduce number of visuals
   - Apply filters to reduce data volume
   - Use simpler chart types

4. **Increase refresh interval**:
   ```json
   {
     "refreshIntervalSeconds": 120
   }
   ```

5. **Configure daily restart** (happens at 2 AM by default):
   ```bash
   # Check cron schedule
   crontab -l
   ```

6. **Upgrade hardware** if needed:
   - Raspberry Pi 4 (2GB: $45, 4GB: $55)
   - Better performance for complex reports

---

### Issue: Pi Runs Hot / Overheating

**Symptoms**: Temperature >60°C, display laggy, throttling warnings

**Causes**:
- No heatsink
- Enclosed case without ventilation
- Ambient temperature too high

**Solutions**:
1. **Check temperature**:
   ```bash
   vcgencmd measure_temp
   # Normal: 45-55°C
   # Warning: 55-60°C
   # Throttling: >70°C
   ```

2. **Add heatsink case**: $7 passive cooling case

3. **Improve ventilation**:
   - Don't enclose Pi in tight space
   - Ensure airflow around device

4. **Reduce CPU load**:
   - Simplify report
   - Increase refresh interval
   - Check for runaway processes: `top`

---

### Issue: WiFi Connection Drops

**Symptoms**: Display goes blank intermittently, network timeouts

**Causes**:
- Weak WiFi signal
- 2.4GHz interference
- Router issues

**Solutions**:
1. **Check WiFi signal strength**:
   ```bash
   iwconfig wlan0
   # Look for "Signal level"
   ```

2. **Move Pi closer to router** or use WiFi extender

3. **Check 2.4GHz interference**:
   - Microwave ovens
   - Bluetooth devices
   - Other WiFi networks
   - Change router channel

4. **Use wired Ethernet** (via USB adapter):
   - More reliable than WiFi
   - Micro USB to Ethernet adapter (~$10)

5. **Verify WiFi credentials** in Pi config:
   ```bash
   sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
   ```

---

## Performance Optimization

### For Slow Report Loading

**Issue**: Report takes >30 seconds to load

**Solutions**:
1. Simplify Power BI report (fewer visuals)
2. Apply filters to reduce data volume
3. Pre-aggregate data in Power BI
4. Optimize DAX queries
5. Consider Pi 4 upgrade for complex reports

### For Laggy Display

**Issue**: Display stutters or refreshes slowly

**Solutions**:
1. Use wired Ethernet instead of WiFi
2. Place Pi closer to router
3. Reduce refresh frequency (90-120 seconds)
4. Check network congestion
5. Simplify report visuals

### For Memory Issues

**Issue**: Pi runs out of memory, crashes frequently

**Solutions**:
1. Watchdog auto-restarts at 85% memory
2. Schedule daily restart (2 AM default)
3. Reduce report complexity
4. Close unused browser tabs (shouldn't be any in kiosk mode)
5. Check for memory leaks: `free -h` over time

---

## Service Management

### Restart Display Service
```bash
sudo systemctl restart beacon-display
```

### View Service Status
```bash
sudo systemctl status beacon-display
```

### View Live Logs
```bash
sudo journalctl -u beacon-display -f
```

### View Last 100 Log Lines
```bash
sudo journalctl -u beacon-display -n 100
```

### Enable Service (auto-start on boot)
```bash
sudo systemctl enable beacon-display
```

### Disable Service
```bash
sudo systemctl disable beacon-display
```

### Manual Start (for testing)
```bash
# Stop service first
sudo systemctl stop beacon-display

# Run manually to see output
cd ~/beacon-display/raspberry-pi
./start-display.sh
```

---

## Still Having Issues?

### Gather Diagnostic Information

1. **System info**:
   ```bash
   cat /etc/os-release
   uname -a
   ```

2. **Memory and CPU**:
   ```bash
   free -h
   top -n 1
   vcgencmd measure_temp
   ```

3. **Network**:
   ```bash
   ip addr show
   ping -c 3 8.8.8.8
   curl http://YOUR-LAPTOP-IP:3000/health
   ```

4. **Service logs**:
   ```bash
   sudo journalctl -u beacon-display -n 200 > ~/beacon-logs.txt
   ```

5. **Config files**:
   ```bash
   cat ~/beacon-display/display-client/config.json
   ```

### Check Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
- [GETTING-STARTED.md](GETTING-STARTED.md) - Setup guide
- [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment

### Reset to Default

If all else fails, start fresh:

```bash
# On Pi: Remove everything
cd ~
rm -rf beacon-display

# Re-deploy from laptop
cd ~/beacon-display
./scripts/deploy-to-pi.sh YOUR-PI-IP

# SSH to Pi and reinstall
ssh pi@YOUR-PI-IP
cd beacon-display
chmod +x raspberry-pi/install.sh
sudo raspberry-pi/install.sh
```

---

**Last Updated**: 2025
