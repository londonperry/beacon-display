# Phase 4-5: Raspberry Pi Deployment & Validation

> **Audience**: IT staff and makers
> **Duration**: 2.5 hours (2 hours deployment + 30 min validation)
> **Prerequisites**: Completed Phase 3 (token service running), Raspberry Pi with accessories
> **After This Phase**: Dedicated display showing your Power BI report

---

## Objective

Deploy BEACON to Raspberry Pi with auto-start configuration, test functionality, and validate 72-hour uptime.

**What Happens**:
1. Flash microSD card with Raspberry Pi OS
2. Deploy BEACON files to Pi
3. Configure display client with your settings
4. Enable auto-start service
5. Test refresh and recovery
6. Monitor performance for 72 hours

---

## Prerequisites Checklist

Before starting Phase 4:

- [ ] Raspberry Pi device (Zero 2 W, Pi 4, or Pi 5)
- [ ] microSD card (32GB Class 10 minimum)
- [ ] Power supply (5V 2.5A for Pi Zero, 5V 3A for Pi 4/5)
- [ ] HDMI cable
- [ ] Monitor or TV with HDMI input
- [ ] WiFi credentials (or Ethernet adapter)
- [ ] Laptop with BEACON files
- [ ] Token service running on laptop
- [ ] Laptop IP address (from Phase 3)
- [ ] Group ID and Report ID (from Phase 2)

---

## Phase 4A: Flash SD Card

### 4A.1 Download Raspberry Pi Imager

1. Go to [raspberrypi.com/software](https://raspberrypi.com/software)
2. Download and install for your OS (Windows, Mac, Linux)

### 4A.2 Insert microSD Card

Insert microSD card into your laptop's card reader.

### 4A.3 Select Operating System

In Raspberry Pi Imager:

1. Click **Choose OS**
2. Select **Raspberry Pi OS (other)**
3. Select **Raspberry Pi OS Lite (64-bit)**

**Why Lite?**
- Smaller, boots faster
- No desktop (we run Chromium in kiosk mode)
- Uses less resources

### 4A.4 Configure Advanced Options

1. Click gear icon (⚙️) **Advanced options**
2. Configure:
   - **Hostname**: `beacon-display`
   - **Enable SSH**: ✓ (checkbox)
   - **Username**: `pi`
   - **Password**: (create secure password)
   - **Configure WiFi**: (your WiFi name and password)
   - **WiFi country**: (your country)
   - **Timezone**: (your timezone)
3. Click **Save**

### 4A.5 Write to SD Card

1. Click **Choose Storage**
2. Select your microSD card
3. Click **Write** (takes 5-10 minutes)
4. Wait for "Write Successful" message

⚠️ **Warning**: This erases the SD card completely.

---

## Phase 4B: First Boot

### 4B.1 Insert SD Card into Pi

1. Insert flashed microSD card into Pi's microSD slot
2. Connect HDMI cable to Pi and monitor/TV
3. Connect power supply to Pi

### 4B.2 Wait for Boot

The Pi will boot and display activity on the monitor. This takes 2-3 minutes.

### 4B.3 Find Pi's IP Address

**Method 1: Check Router**
- Log into your router's web interface
- Look for DHCP client list
- Find device named `beacon-display`
- Note its IP address

**Method 2: Connect Keyboard**
- Connect USB keyboard to Pi
- Type: `hostname -I`
- Note the IP address

**Method 3: Network Scan**
```bash
# From laptop
nmap -sn 192.168.1.0/24 | grep -i beacon
```

**Record Pi IP**: `____________________`

---

## Phase 4C: Deploy Files to Pi

### 4C.1 Deploy from Laptop

```bash
# Navigate to beacon-display root
cd ~/beacon-display

# Run deployment script
./scripts/deploy-to-pi.sh YOUR-PI-IP-ADDRESS
```

Replace `YOUR-PI-IP-ADDRESS` with the IP from Phase 4B.

**What this does**:
- Copies display-client, token-service, and raspberry-pi directories to Pi
- Uses secure copy (scp) over SSH
- Should complete in 30-60 seconds

### 4C.2 SSH to Pi

```bash
ssh pi@YOUR-PI-IP-ADDRESS
```

Enter the password you created in Phase 4A.

**You're now on the Pi!** The prompt should show `pi@beacon-display:~$`

---

## Phase 4D: Run Installation Script

### 4D.1 Navigate to Installation

```bash
# On Pi
cd beacon-display
chmod +x raspberry-pi/install.sh
```

### 4D.2 Run Install Script

```bash
sudo raspberry-pi/install.sh
```

**What this does**:
- Installs Chromium browser
- Configures systemd auto-start service
- Sets up memory watchdog
- Creates daily restart schedule
- Enables all required services

**Time**: 5-10 minutes (downloads packages)

### 4D.3 Watch for Completion

Script will:
1. Install packages
2. Set up systemd service
3. Configure GPU memory split
4. Set up cron jobs
5. Print success message

---

## Phase 4E: Configure Display Client

### 4E.1 Edit Configuration

```bash
# On Pi, still in beacon-display directory
cd display-client
nano config.json
```

If `config.json` doesn't exist:
```bash
cp config.json.example config.json
nano config.json
```

### 4E.2 Update Configuration

Replace the template with your values:

```json
{
  "deviceId": "my-display-001",
  "tokenServiceUrl": "http://192.168.1.100:3000/api/embed-token",
  "groupId": "YOUR-GROUP-ID",
  "reportId": "YOUR-REPORT-ID",
  "refreshIntervalSeconds": 60,
  "tokenRefreshMinutes": 50,
  "filters": {}
}
```

**Field Guide**:
- `deviceId`: Unique name for this display (used in logs)
- `tokenServiceUrl`: Your laptop IP + port from Phase 3
- `groupId`: Power BI workspace ID from Phase 2
- `reportId`: Power BI report ID from Phase 2
- `refreshIntervalSeconds`: Data refresh frequency (60 = every minute)
- `tokenRefreshMinutes`: Token renewal (50 = refresh before 60 min expiry)
- `filters`: Optional report-level filters (usually empty for POC)

### 4E.3 Save Configuration

Press `Ctrl+X`, then `Y`, then Enter.

---

## Phase 4F: Reboot and Test

### 4F.1 Reboot Pi

```bash
sudo reboot
```

The Pi will disconnect from SSH and reboot. This takes ~2 minutes.

### 4F.2 Wait for Display

After reboot, look at the monitor connected to the Pi. You should see:

1. **Loading message** (5-10 seconds)
2. **Your Power BI report** loading
3. **Full report rendering** (10-15 seconds total from reboot)

**Expected**: Report displays with live data and auto-refreshes every 60 seconds.

### 4F.3 Monitor System

```bash
# SSH to Pi again
ssh pi@YOUR-PI-IP-ADDRESS

# Check service status
sudo systemctl status beacon-display

# View live logs
sudo journalctl -u beacon-display -f
```

Press `Ctrl+C` to exit logs.

---

## Phase 5: Validation (72-Hour Test)

### 5.1 Functional Tests

Run these tests while the display is running:

✅ **Auto-Refresh**: Report data updates every 60 seconds
- Watch for chart values changing
- Verify timestamps update in the data

✅ **Token Renewal**: No authentication prompts after 1 hour
- Let it run for 1+ hour
- Verify no login screens appear

✅ **Boot Recovery**: Power loss and recovery
```bash
# On Pi: Unplug power supply
# Wait 10 seconds
# Plug power back in
# Monitor should show report within 2 minutes
```

✅ **72-Hour Uptime**: Leave running continuously
- Check each day that display is still showing data
- Note any crashes or blank screens
- Verify service auto-restarted if it crashed

### 5.2 Performance Monitoring

Monitor hardware during operation:

```bash
# SSH to Pi
ssh pi@YOUR-PI-IP-ADDRESS

# Check memory usage (should be <400MB)
free -h

# Example output:
#               total        used        free
# Mem:          476Mi       310Mi       166Mi

# Check CPU temperature (should be <60°C)
vcgencmd measure_temp

# Example output: temp=52.4'C

# View service logs
sudo journalctl -u beacon-display -n 50
```

**Healthy ranges**:
- Memory: <400MB (80% of 512MB)
- Temperature: 45-55°C normal, 55-60°C acceptable
- CPU load: 30-50% during display

### 5.3 Recovery Testing

Test automatic recovery mechanisms:

**Memory Watchdog** (auto-restart at 85%):
```bash
# The watchdog script monitors memory
# If memory exceeds 85%, it automatically restarts the service
# Nothing to do - it's automatic
```

**Daily Reboot** (every 2 AM):
```bash
# Check cron schedule
crontab -l

# You should see a 2 AM restart entry
```

**Service Auto-Start** (power recovery):
- Unplug Pi power
- Wait 10 seconds
- Plug back in
- Within 2 minutes, display should show report
- No manual intervention needed

### 5.4 Success Criteria

After 72 hours, verify:

- [ ] Display shows Power BI report
- [ ] Data refreshes every 60 seconds
- [ ] No authentication prompts
- [ ] Service auto-restarted if crashes
- [ ] Memory <400MB consistently
- [ ] Temperature <60°C (no throttling)
- [ ] Boot time <2 minutes after power loss
- [ ] No manual interventions required

**If all criteria met**: POC is complete and ready for stakeholder demo!

---

## Troubleshooting Phase 4-5

### Display Shows "Loading..." Forever

**Cause**: Token service not reachable
**Solution**:
1. Verify token service running on laptop: `curl http://localhost:3000/health`
2. Verify Pi can reach laptop: SSH to Pi and run `curl http://192.168.1.100:3000/health`
3. Check config.json tokenServiceUrl is correct (exact IP address)
4. Check laptop firewall allows port 3000

See [Display Client Troubleshooting](../troubleshooting/display-client.md)

### "Failed to Generate Embed Token"

**Cause**: Azure credentials or permissions issue
**Solution**:
1. Verify Azure credentials in token service .env match Phase 2 exactly
2. Verify service principal added to Power BI workspace as Member
3. Check token service logs: `npm start` and watch for errors

See [Token Service Troubleshooting](../troubleshooting/token-service.md)

### Pi Won't Boot After Reboot

**Cause**: SD card, power, or configuration issue
**Solution**:
1. Check power supply is plugged in and providing power
2. Try different SD card or reflash
3. Check HDMI cable is firmly connected
4. Try different HDMI port on monitor/TV

See [Raspberry Pi Troubleshooting](../troubleshooting/raspberry-pi.md)

### High Memory Usage / System Crashes

**Cause**: Complex Power BI report
**Solution**:
1. Simplify Power BI report (fewer visuals)
2. Increase refresh interval: change `refreshIntervalSeconds` to 120
3. Monitor memory: `free -h`
4. Watchdog auto-restarts if >85%

See [Memory Optimization](../hardware/optimization.md)

---

## Next Steps

After successful 72-hour validation:

✅ **POC Complete**: You now have a working proof of concept

**Options**:
1. **Demo to Stakeholders**: Show decision makers the working display
2. **Move to Production**: Follow [Deployment Guide](../deployment/README.md)
3. **Add More Displays**: Deploy to multiple Raspberry Pi devices
4. **Optimize Further**: See [Hardware Optimization](../hardware/optimization.md)

---

## Related Documentation

- **[Setup Overview](README.md)** - All phases
- **[Configuration Reference](configuration-reference.md)** - Config schema and options
- **[Raspberry Pi Troubleshooting](../troubleshooting/raspberry-pi.md)** - Hardware issues
- **[Display Client Troubleshooting](../troubleshooting/display-client.md)** - Browser/rendering issues
- **[Hardware Guide](../hardware/README.md)** - Device options and performance
- **[Deployment Guide](../deployment/README.md)** - Enterprise rollout
