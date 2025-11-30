# Raspberry Pi Troubleshooting

**Audience:** For diagnosing Raspberry Pi hardware and system issues

This document covers boot problems, memory issues, thermal management, HDMI problems, and auto-start failures.

---

## Boot Problems

### Issue: Pi Won't Boot

**Symptoms:**
- No HDMI output
- No activity LED flashing
- No network connectivity
- Power LED may or may not be on

#### Diagnosis

**1. Check power supply:**
```bash
# Minimum requirements:
# Pi Zero 2 W: 5V @ 2.5A (micro-USB)
# Pi 4: 5V @ 3A (USB-C)
# Pi 5: 5V @ 5A (USB-C)
```

**2. Check SD card:**
```bash
# On laptop, verify SD card readable
# Check for corruption
# Verify files present
```

**3. Check LED behavior:**
- **Power LED (red):** Should be solid on
- **Activity LED (green):** Should flash during boot
- **No LEDs:** Power supply issue
- **Power LED only:** SD card or boot issue

#### Solutions

**1. Check power supply:**
- Use official Raspberry Pi power supply
- Try different power cable
- Ensure minimum amperage (2.5A-5A)
- Check for voltage warnings in logs (if Pi has booted before)

**2. Reflash SD card:**
```bash
# On laptop
# Download Raspberry Pi Imager
# Flash Raspberry Pi OS Lite (64-bit)
# Configure WiFi and SSH in Imager
# Redeploy BEACON files
```

**3. Try different SD card:**
- Class 10 minimum
- Known working card
- 16GB+ capacity
- Brand name (SanDisk, Samsung, Kingston)

**4. Check HDMI cable:**
- Firmly connected both ends
- Try different cable
- Try different TV/monitor input
- Ensure mini-HDMI (not micro-HDMI)

**5. Test with another monitor:**
- Different TV or monitor
- Different HDMI input
- Verify monitor works with other device

---

### Issue: Pi Boots but Hangs

**Symptoms:**
- Boot starts (green LED flashes)
- Hangs at rainbow screen or command line
- Never reaches login prompt
- Partial boot

#### Diagnosis

**1. Connect keyboard:**
- Attach USB keyboard
- Watch boot messages
- Note where it hangs

**2. Check SD card:**
```bash
# On laptop, run fsck
# Mac/Linux:
sudo fsck /dev/sdX

# Windows: use chkdsk
```

#### Solutions

**1. Boot in safe mode:**
```bash
# Add to /boot/cmdline.txt on SD card
# Remove: quiet splash
# Add: init=/bin/bash

# This gives emergency shell
```

**2. Check /boot/config.txt:**
```bash
# Remove recent changes
# Verify no typos
# Use known working config
```

**3. Reinstall OS:**
- Backup /home/pi/beacon-display
- Reflash SD card
- Restore BEACON files

---

## Memory Issues

### Issue: High Memory Usage

**Symptoms:**
- Memory usage >400MB (Pi Zero 2 W)
- System slowness
- Frequent restarts
- Out of memory errors

#### Diagnosis

**1. Check current usage:**
```bash
free -h

# Output shows:
# total: 427MB (Pi Zero 2 W)
# used: Should be <400MB
# available: Should have >50MB
```

**2. Check processes:**
```bash
# Top memory consumers
ps aux --sort=-%mem | head -10

# Chromium specifically
ps aux | grep chromium | awk '{sum+=$6} END {print sum/1024 " MB"}'
```

**3. Check watchdog:**
```bash
# Watchdog should restart at 85% (435MB)
sudo systemctl status beacon-display
```

**4. Check for memory leaks:**
```bash
# Monitor over time
watch -n 5 free -h
```

#### Solutions

**1. Simplify Power BI report:**
- **Reduce visuals:** Limit to 5 visuals (Pi Zero 2 W)
- **Remove maps:** High memory usage
- **Filter data:** Reduce row count
- **Simpler visuals:** Use cards, KPIs, simple charts

**Example - High memory report:**
```
12 visuals:
- 2 maps (150MB)
- 4 bar charts (80MB)
- 3 tables (60MB)
- 3 KPIs (20MB)
Total: ~310MB + OS (150MB) = 460MB ❌
```

**Example - Optimized report:**
```
6 visuals:
- 3 bar charts (60MB)
- 3 KPIs (20MB)
Total: ~80MB + OS (150MB) = 230MB ✅
```

**2. Increase refresh interval:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "refreshIntervalSeconds": 120  # Instead of 60
}

sudo systemctl restart beacon-display
```

**3. Disable unused services:**
```bash
# Free up memory
sudo systemctl disable bluetooth
sudo systemctl disable avahi-daemon
sudo systemctl disable triggerhappy

# Restart
sudo reboot
```

**4. Optimize Chromium flags:**
```bash
# Edit start-display.sh
nano ~/beacon-display/raspberry-pi/start-display.sh

# Add memory-saving flags:
--disable-dev-shm-usage
--disable-software-rasterizer
--disable-background-networking
--media-cache-size=1
--disk-cache-size=1
```

**5. Verify watchdog is working:**
```bash
# Check MemoryMax
sudo systemctl show beacon-display | grep MemoryMax
# Should be: MemoryMax=412M (Pi Zero 2 W)

# Watchdog restarts at 435MB (85%)
# Check it's running
ps aux | grep watchdog
```

**6. Upgrade hardware:**
- Pi 4 (2GB): $80 total, 4× more RAM
- Handles complex reports easily
- Better long-term investment

---

## Thermal Issues

### Issue: Pi Running Hot

**Symptoms:**
- Temperature >60°C
- Laggy display
- Throttling warnings
- System slowness

#### Diagnosis

**1. Check temperature:**
```bash
vcgencmd measure_temp
# Output: temp=52.3'C

# Normal: 45-55°C
# Warning: 55-60°C
# Critical: 60-70°C
# Throttling: >70°C
```

**2. Check throttling:**
```bash
vcgencmd get_throttled
# 0x0 = OK
# Other values = Throttling occurred
```

**3. Check ambient temperature:**
- Room temperature
- Airflow around Pi
- Sunlight on device

**4. Monitor over time:**
```bash
# Log temperature
while true; do
    echo "$(date): $(vcgencmd measure_temp)" >> /tmp/temp.log
    sleep 60
done
```

#### Solutions

**1. Add heatsink:**
- **Passive heatsink:** $2-5 (5-10°C reduction)
- **Case with heatsink:** $7-15 (10-15°C reduction)
- **Active cooling (fan):** $15-20 (15-20°C reduction)

**Installation:**
1. Clean CPU with isopropyl alcohol
2. Apply thermal pad or paste
3. Attach heatsink firmly
4. Ensure good contact

**2. Improve ventilation:**
- Don't enclose in tight space
- Ensure airflow
- Keep away from heat sources
- Use case with ventilation holes

**3. Avoid sunlight:**
- Direct sunlight adds 10-20°C
- Move to shaded location
- Use opaque case

**4. Reduce CPU load:**
```bash
# Simplify report
# Increase refresh interval
# Check for runaway processes
top
```

**5. Check power supply:**
```bash
# Under-voltage causes higher temperatures
# Use official power supply
# Check voltage in logs
dmesg | grep voltage
```

---

## HDMI Problems

### Issue: No HDMI Output

**Symptoms:**
- TV shows "No Signal"
- Blank screen
- Display not detected

#### Diagnosis

**1. Check HDMI status:**
```bash
tvservice -s
# Should show: [HDMI CEA (16) RGB lim 16:9], 1920x1080 @ 60.00Hz
```

**2. Check cable:**
- Mini-HDMI (not micro-HDMI)
- Firmly connected both ends
- Known working cable

**3. Try different input:**
- Different HDMI port on TV
- Different TV/monitor

#### Solutions

**1. Force HDMI output:**
```bash
sudo nano /boot/config.txt

# Add/uncomment these lines:
hdmi_force_hotplug=1
hdmi_drive=2
hdmi_group=2
hdmi_mode=82  # 1080p60

# Save and reboot
sudo reboot
```

**2. Disable overscan:**
```bash
sudo nano /boot/config.txt

# Add:
disable_overscan=1

# Save and reboot
```

**3. Test HDMI manually:**
```bash
# Turn on HDMI
tvservice -p

# Set resolution
tvservice -e "CEA 16"  # 1080p60

# Refresh framebuffer
fbset -depth 8
fbset -depth 16
```

**4. Try safe HDMI mode:**
```bash
# Add to /boot/config.txt
hdmi_safe=1

# Forces basic HDMI settings
# Reboot and test
```

---

## Auto-Start Failures

### Issue: Service Doesn't Start on Boot

**Symptoms:**
- Pi boots but display doesn't start
- Manual start works
- Service not enabled
- No automatic startup

#### Diagnosis

**1. Check service status:**
```bash
sudo systemctl status beacon-display
# Should show: enabled, active (running)
```

**2. Check if enabled:**
```bash
sudo systemctl is-enabled beacon-display
# Should output: enabled
```

**3. Check service file:**
```bash
cat /etc/systemd/system/beacon-display.service
# Verify ExecStart path correct
```

**4. Check for errors:**
```bash
sudo journalctl -u beacon-display -n 100
# Look for startup errors
```

#### Solutions

**1. Enable service:**
```bash
sudo systemctl enable beacon-display
sudo systemctl start beacon-display
```

**2. Verify service file:**
```bash
# Should be created by install.sh
# If missing, run install again
cd ~/beacon-display
sudo raspberry-pi/install.sh
```

**3. Check permissions:**
```bash
# Ensure scripts executable
chmod +x ~/beacon-display/raspberry-pi/*.sh

# Check service file permissions
sudo chmod 644 /etc/systemd/system/beacon-display.service
```

**4. Reload systemd:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable beacon-display
sudo systemctl start beacon-display
```

**5. Test manual start:**
```bash
# Stop service
sudo systemctl stop beacon-display

# Run manually
cd ~/beacon-display/raspberry-pi
./start-display.sh

# Watch for errors
```

---

## Performance Problems

### Issue: Slow/Laggy Display

**Symptoms:**
- Report loads slowly
- Visuals render slowly
- Interactions laggy
- Refresh takes long time

#### Diagnosis

**1. Check memory:**
```bash
free -h
# Should have available memory
```

**2. Check CPU:**
```bash
top
# Check CPU usage of chromium
```

**3. Check temperature:**
```bash
vcgencmd measure_temp
# High temp causes throttling
```

**4. Check network:**
```bash
ping -c 10 api.powerbi.com
# Check latency and packet loss
```

#### Solutions

**1. Optimize report:**
- Fewer visuals
- Simpler chart types
- Apply filters
- Pre-aggregate data

**2. Increase refresh interval:**
```json
{
  "refreshIntervalSeconds": 120
}
```

**3. Use Ethernet:**
```bash
# More stable than WiFi
# Lower latency
# For Pi 4/5: built-in
# For Pi Zero 2 W: USB adapter
```

**4. Optimize GPU memory:**
```bash
sudo nano /boot/config.txt

# Set GPU memory
gpu_mem=128

# Reboot
sudo reboot
```

**5. Upgrade hardware:**
- Pi 4 (2GB): 3× faster CPU, 4× RAM
- Pi 5 (4GB): 4× faster CPU, 8× RAM
- Better for complex reports

---

## WiFi Issues

### Issue: WiFi Disconnects

**Symptoms:**
- Intermittent connectivity
- Display goes blank
- Network timeouts
- Frequent reconnects

#### Diagnosis

**1. Check signal strength:**
```bash
iwconfig wlan0 | grep "Signal level"
# Good: -30 to -50 dBm
# Fair: -50 to -70 dBm
# Poor: -70 to -80 dBm
```

**2. Check connection:**
```bash
iwconfig wlan0
# Look for: Link Quality, Signal level
```

**3. Monitor connection:**
```bash
# Continuous ping
ping -c 300 8.8.8.8
# Check packet loss %
```

#### Solutions

**1. Improve signal:**
- Move Pi closer to router
- Use WiFi extender
- Remove obstacles

**2. Change WiFi channel:**
```bash
# Router admin panel
# Try channels 1, 6, or 11 (2.4GHz)
# Less interference
```

**3. Disable power management:**
```bash
sudo iwconfig wlan0 power off

# Make permanent:
sudo nano /etc/network/interfaces
# Add: wireless-power off
```

**4. Use Ethernet (recommended):**
- More reliable
- No signal issues
- Better for production

**See:** [Network Issues → WiFi](network.md#wifi) for more details.

---

## SD Card Issues

### Issue: SD Card Corruption

**Symptoms:**
- Read/write errors
- Boot failures
- File system errors
- "Read-only file system"

#### Diagnosis

**1. Check for errors:**
```bash
# Look for I/O errors in logs
dmesg | grep -i "mmc\|sd"
```

**2. Check file system:**
```bash
# On laptop
sudo fsck /dev/sdX
```

**3. Check SD card health:**
- Try different SD card
- Use SD card tester tool
- Check SMART data (if supported)

#### Solutions

**1. Backup and reflash:**
```bash
# Backup critical files
scp -r pi@PI-IP:~/beacon-display ~/beacon-backup

# Reflash SD card
# Use Raspberry Pi Imager
# Restore BEACON files
```

**2. Use quality SD card:**
- Class 10 or UHS-I
- Brand name (SanDisk, Samsung, Kingston)
- Buy from reputable seller (avoid counterfeits)

**3. Minimize writes:**
```bash
# Reduce logging
sudo nano /etc/systemd/journald.conf
# Set: SystemMaxUse=50M

# Disable swap (if not needed)
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
```

**4. Consider upgrading to eMMC or SSD:**
- ODROID with eMMC
- Pi with USB SSD boot
- More reliable than SD card

---

## Related Documentation

- **[Troubleshooting Overview](README.md)** - Diagnostic approach
- **[Hardware Guide](../hardware/raspberry-pi.md)** - Pi specifications
- **[Optimization Guide](../hardware/optimization.md)** - Performance tuning
- **[Display Client Issues](display-client.md)** - Browser problems
- **[Network Issues](network.md)** - Connectivity problems

---

**Last Updated:** 2025-11-30
