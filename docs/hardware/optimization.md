# BEACON Hardware Optimization

**Audience:** For system administrators optimizing BEACON performance

This document covers memory optimization, browser tuning, network performance, and thermal management.

---

## Memory Optimization

### Understanding Memory Constraints

**Raspberry Pi Zero 2 W (512MB total):**
```
System overhead:    ~150MB (OS, X server, systemd)
Chromium browser:   ~200MB (base browser process)
Power BI rendering: ~100-150MB (report and visuals)
Buffer/cache:       ~50-100MB (file system cache)
Target usage:       <400MB (80% of total)
Critical threshold: 435MB (85% - triggers watchdog restart)
```

**Why 400MB target?**
- Leaves headroom for memory spikes
- Prevents swap usage (slow on SD card)
- Avoids OOM (Out of Memory) killer
- Maintains system responsiveness

### Memory Monitoring

**Check current usage:**
```bash
# Human-readable format
free -h

# Output:
#               total        used        free      shared  buff/cache   available
# Mem:          427Mi       285Mi        45Mi       8.0Mi        96Mi       107Mi
```

**Monitor over time:**
```bash
# Update every 5 seconds
watch -n 5 free -h

# Log to file
while true; do
    echo "$(date): $(free -m | grep Mem | awk '{print $3}')" >> /tmp/memory.log
    sleep 60
done
```

**Memory by process:**
```bash
# Top memory consumers
ps aux --sort=-%mem | head -10

# Chromium memory specifically
ps aux | grep chromium | awk '{sum+=$6} END {print sum/1024 " MB"}'
```

### Memory Reduction Strategies

#### 1. Disable Unnecessary Services

**Find services using memory:**
```bash
systemctl list-units --type=service --state=running
```

**Disable unnecessary services:**
```bash
# Examples (verify you don't need these)
sudo systemctl disable bluetooth
sudo systemctl disable avahi-daemon
sudo systemctl disable triggerhappy
sudo systemctl disable dphys-swapfile  # If not using swap

# Apply changes
sudo systemctl daemon-reload
```

#### 2. Optimize Chromium Flags

**Current flags in start-display.sh:**
```bash
chromium-browser \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --no-first-run \
  --disable-features=TranslateUI \
  --check-for-update-interval=31536000
```

**Additional memory-saving flags:**
```bash
--disable-software-rasterizer  # Use GPU for rendering
--disable-dev-shm-usage       # Don't use /dev/shm (saves RAM)
--disable-background-networking  # No background sync
--disable-sync                # No Chrome sync
--disable-extensions          # No extensions
--no-default-browser-check    # Skip browser check
--no-pings                    # No analytics pings
--media-cache-size=1          # Minimal media cache
--disk-cache-size=1           # Minimal disk cache
```

**Apply changes:**
```bash
# Edit start-display.sh
nano ~/beacon-display/raspberry-pi/start-display.sh

# Add flags, then restart
sudo systemctl restart beacon-display
```

#### 3. Configure Swap (Use Sparingly)

**Note:** SD card swap is slow and wears out card faster. Use only if necessary.

**Check current swap:**
```bash
swapon --show
free -h
```

**Disable swap (if not needed):**
```bash
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo systemctl disable dphys-swapfile
```

**Reduce swap size (if keeping):**
```bash
# Edit config
sudo nano /etc/dphys-swapfile

# Change to:
CONF_SWAPSIZE=100  # 100MB instead of 512MB

# Apply
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

#### 4. Optimize Power BI Report

**Report complexity directly impacts memory:**

**Reduce visuals:**
- Limit to 5 visuals per page (Pi Zero 2 W)
- Combine related metrics into single visuals
- Remove decorative/non-essential visuals

**Simplify data:**
- Apply filters to reduce row count
- Use aggregated datasets
- Pre-calculate metrics in Power BI

**Visual types (memory usage):**
- Low: Card, KPI, Gauge
- Medium: Bar chart, Line chart, Table
- High: Map, Scatter plot, Complex custom visual

**Example - before:**
```
Dashboard with 12 visuals:
- 2 maps (high memory)
- 4 bar charts (medium)
- 3 tables (medium)
- 3 KPIs (low)
Memory: ~350-400MB
```

**Example - after:**
```
Dashboard with 6 visuals:
- 3 bar charts (medium)
- 3 KPIs (low)
Memory: ~250-300MB
```

---

## Browser Optimization

### Chromium Performance Tuning

#### GPU Acceleration

**Enable GPU memory split:**
```bash
# Edit /boot/config.txt
sudo nano /boot/config.txt

# Add or modify:
gpu_mem=128  # Allocate 128MB to GPU

# Reboot
sudo reboot
```

**Verify GPU acceleration:**
```bash
# Check GPU memory allocation
vcgencmd get_mem gpu
# Should show: gpu=128M

# Check if GPU is being used
vcgencmd measure_clock core
vcgencmd measure_clock h264
```

#### Cache Configuration

**Browser cache location:**
```bash
# Default: ~/.cache/chromium
# Uses SD card (slow)

# Option: Use tmpfs (RAM disk) for cache
mkdir -p /tmp/chromium-cache
```

**Configure in start-display.sh:**
```bash
--disk-cache-dir=/tmp/chromium-cache
--disk-cache-size=10485760  # 10MB cache
```

**Trade-off:** Uses RAM but faster than SD card

### Display Configuration

#### Resolution Optimization

**Force specific resolution:**
```bash
# Edit /boot/config.txt
sudo nano /boot/config.txt

# For 1080p:
hdmi_group=2
hdmi_mode=82
hdmi_drive=2

# For 720p (lower resource usage):
hdmi_group=2
hdmi_mode=85
```

**HDMI modes:**
- Mode 82: 1920×1080 @ 60Hz (1080p)
- Mode 85: 1280×720 @ 60Hz (720p)
- Mode 16: 1024×768 @ 60Hz

**Lower resolution = less memory for frame buffer**

#### Overscan (Black Borders)

**Disable overscan for maximum screen usage:**
```bash
# /boot/config.txt
disable_overscan=1
```

**Or adjust overscan:**
```bash
overscan_left=16
overscan_right=16
overscan_top=16
overscan_bottom=16
```

---

## Network Optimization

### WiFi Performance

#### Signal Strength

**Check current signal:**
```bash
iwconfig wlan0

# Look for:
# Signal level=-45 dBm  (excellent: -30 to -50 dBm)
# Signal level=-65 dBm  (good: -50 to -70 dBm)
# Signal level=-75 dBm  (poor: -70 to -80 dBm)
```

**Improve signal:**
- Move Pi closer to router
- Use WiFi extender/repeater
- Change router channel (less interference)
- Upgrade to external antenna (if supported)
- Use 2.4GHz (better range than 5GHz)

#### WiFi Power Management

**Disable power saving:**
```bash
# Check current setting
iwconfig wlan0 | grep "Power Management"

# Disable power management
sudo iwconfig wlan0 power off

# Make permanent
echo "wireless-power off" | sudo tee -a /etc/network/interfaces
```

**Why:** Prevents WiFi from sleeping and causing disconnects

#### Connection Monitoring

**Log WiFi reliability:**
```bash
# Create monitoring script
cat > ~/check-wifi.sh << 'EOF'
#!/bin/bash
while true; do
    ping -c 1 8.8.8.8 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$(date): WiFi down" >> /tmp/wifi-log.txt
        sudo systemctl restart networking
    fi
    sleep 60
done
EOF

chmod +x ~/check-wifi.sh
```

### Ethernet Optimization (Recommended)

**Why Ethernet is better:**
- Consistent latency (WiFi varies)
- No signal interference
- More reliable for 24/7 operation
- Higher bandwidth

**For Pi Zero 2 W:**
```bash
# Requires USB Ethernet adapter
# Micro-USB OTG adapter + USB Ethernet adapter
# Cost: $10-15
# Performance: Up to 100Mbps
```

**For Pi 4/5:**
- Built-in Gigabit Ethernet
- Up to 1000Mbps
- Most reliable option

### Network Bandwidth Optimization

**Reduce refresh frequency:**
```json
{
  "refreshIntervalSeconds": 120  // Instead of 60
}
```

**Bandwidth savings:**
- 60s refresh: ~144MB/day
- 120s refresh: ~72MB/day (50% reduction)

**Impact:** Older data but less network usage

---

## Thermal Management

### Temperature Monitoring

**Check current temperature:**
```bash
vcgencmd measure_temp

# Output: temp=52.3'C
```

**Monitor continuously:**
```bash
watch -n 5 vcgencmd measure_temp
```

**Log temperatures:**
```bash
while true; do
    echo "$(date): $(vcgencmd measure_temp)" >> /tmp/temp-log.txt
    sleep 300  # Every 5 minutes
done
```

### Temperature Thresholds

| Temperature | Status | Action |
|------------|--------|--------|
| **<50°C** | Excellent | Normal operation |
| **50-60°C** | Good | Normal for active display |
| **60-70°C** | Warning | Check cooling, ambient temp |
| **70-80°C** | Critical | Throttling begins, performance reduced |
| **>80°C** | Danger | System may shut down |

### Cooling Solutions

#### Passive Cooling

**Heatsinks:**
- Aluminum: $2-5 (basic cooling)
- Copper: $5-10 (better thermal conductivity)
- Passive case with heatsink: $7-15

**Installation:**
1. Clean CPU with isopropyl alcohol
2. Apply thermal pad or paste
3. Attach heatsink firmly
4. Ensure good contact

**Effectiveness:**
- Reduces temperature by 5-10°C
- Sufficient for Pi Zero 2 W in normal environments

#### Active Cooling

**Small fan (Pi 4/5):**
- 30mm fan: $5-8
- 5V powered from GPIO or USB
- Reduces temperature by 15-20°C
- Noise: 20-30 dB (quiet)

**Installation:**
```bash
# GPIO-powered fan
# Connect to GPIO pins:
# Red wire:   Pin 4 (5V)
# Black wire: Pin 6 (GND)
```

**Fan case:**
- Case with integrated fan: $15-20
- Usually includes heatsinks
- Maintains 40-45°C under load

### Environmental Factors

**Ambient temperature:**
- Normal: 20-25°C (68-77°F)
- Warm: 25-30°C (77-86°F) - add cooling
- Hot: >30°C (>86°F) - active cooling required

**Airflow:**
- Don't enclose Pi in tight space
- Ensure ventilation holes if using case
- Keep away from heat sources (monitors, speakers)

**Sunlight:**
- Avoid direct sunlight on device
- Sunlight can raise temperature 10-20°C

### Thermal Throttling Detection

**Check throttling status:**
```bash
vcgencmd get_throttled

# Output meanings:
# 0x0 = OK (no throttling)
# 0x50000 = Throttled in past
# 0x50005 = Currently throttled + under-voltage
```

**Decode throttle bits:**
```
Bit 0: Under-voltage detected
Bit 1: ARM frequency capped
Bit 2: Currently throttled
Bit 16: Under-voltage has occurred
Bit 17: ARM frequency capping has occurred
Bit 18: Throttling has occurred
```

**If throttling occurs:**
1. Check temperature (vcgencmd measure_temp)
2. Add cooling (heatsink or fan)
3. Improve ventilation
4. Check power supply (may be under-voltage)

---

## Boot Time Optimization

### Current Boot Sequence

```
Power on:           T+0s
Bootloader:         T+5s
Linux kernel:       T+15s
System services:    T+30s
Network ready:      T+45s
X server:           T+60s
Chromium launch:    T+75s
Fetch token:        T+85s
Load report:        T+90s
Fully rendered:     T+105s
```

### Optimization Strategies

#### 1. Disable Unused Services

**Check boot time:**
```bash
systemd-analyze
systemd-analyze blame  # Shows services by startup time
```

**Disable slow services:**
```bash
# Example: Disable Bluetooth (if not needed)
sudo systemctl disable bluetooth
sudo systemctl disable hciuart

# Disable ModemManager (if no cellular)
sudo systemctl disable ModemManager
```

#### 2. Reduce Network Timeout

**Edit dhcpcd service:**
```bash
sudo nano /etc/dhcpcd.conf

# Add:
timeout 10  # Instead of default 30 seconds
```

#### 3. Optimize X Server

**Minimal X configuration:**
```bash
# Use lightweight window manager
# Current: Openbox (already lightweight)

# Disable screen blanking (in start-display.sh)
xset s off
xset -dpms
xset s noblank
```

#### 4. Auto-Login Speed

**Already optimized in install.sh:**
```bash
# Autologin configured for pi user
# Starts X immediately on boot
```

**Expected improvement:** 90-105s → 70-90s

---

## Power Optimization

### Power Consumption Measurement

**Measure power draw:**
```bash
# Requires USB power meter (hardware)
# Typical readings:

# Pi Zero 2 W:
#   Idle: 0.4-0.6W
#   Active: 2-3W
#   Peak: 3.5W

# Pi 4 (2GB):
#   Idle: 2-3W
#   Active: 4-6W
#   Peak: 8W
```

### Power Saving Strategies

#### Disable Unused Hardware

**HDMI (not recommended for BEACON):**
```bash
# Turn off HDMI (saves ~25-30mA)
/usr/bin/tvservice -o

# Turn back on
/usr/bin/tvservice -p
```

**LEDs:**
```bash
# Disable activity LED
echo 0 | sudo tee /sys/class/leds/led0/brightness

# Disable power LED (Pi Zero only)
echo 0 | sudo tee /sys/class/leds/led1/brightness
```

**USB ports (Pi 4):**
```bash
# Turn off USB (not recommended for BEACON)
echo '1-1' | sudo tee /sys/bus/usb/devices/usb1/1-1/remove
```

#### CPU Frequency Scaling

**Check current frequency:**
```bash
vcgencmd measure_clock arm
# Shows frequency in Hz
```

**Governor settings:**
```bash
# Check current governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Available governors:
# - ondemand (default, scales with load)
# - performance (always max frequency)
# - powersave (always min frequency)
```

**For BEACON, use default "ondemand"** - balances performance and power.

---

## SD Card Optimization

### SD Card Performance

**Test read/write speed:**
```bash
# Write test (creates 1GB file)
dd if=/dev/zero of=/tmp/test.img bs=1M count=1024 conv=fdatasync

# Read test
dd if=/tmp/test.img of=/dev/null bs=1M

# Clean up
rm /tmp/test.img
```

**Expected speeds:**
- Class 10 SD: 10-20 MB/s write
- UHS-I (U1): 40-90 MB/s write
- UHS-I (U3): 90-300 MB/s write

### Reduce SD Card Writes

**Minimize logging:**
```bash
# Reduce systemd journal size
sudo nano /etc/systemd/journald.conf

# Set:
SystemMaxUse=50M
MaxRetentionSec=1week
```

**Use tmpfs for temp files:**
```bash
# Add to /etc/fstab
tmpfs /tmp tmpfs defaults,noatime,nosuid,size=100m 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,size=30m 0 0
```

**Disable swap (if not needed):**
```bash
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo systemctl disable dphys-swapfile
```

### SD Card Backup

**Create backup image:**
```bash
# On laptop/PC (Linux/Mac)
sudo dd if=/dev/sdX of=beacon-backup-$(date +%F).img bs=4M status=progress

# Compress to save space
gzip beacon-backup-2025-11-30.img
```

**Restore from backup:**
```bash
gunzip beacon-backup-2025-11-30.img.gz
sudo dd if=beacon-backup-2025-11-30.img of=/dev/sdX bs=4M status=progress
```

---

## Monitoring and Metrics

### System Dashboard

**Create monitoring script:**
```bash
cat > ~/beacon-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    clear
    echo "BEACON System Monitor"
    echo "===================="
    echo ""
    echo "Time: $(date)"
    echo "Uptime: $(uptime -p)"
    echo ""
    echo "Memory:"
    free -h
    echo ""
    echo "Temperature: $(vcgencmd measure_temp)"
    echo "Throttle: $(vcgencmd get_throttled)"
    echo ""
    echo "CPU Frequency: $(vcgencmd measure_clock arm | awk -F'=' '{printf "%.0f MHz\n", $2/1000000}')"
    echo ""
    echo "Network:"
    ifconfig wlan0 | grep "inet " || echo "WiFi not connected"
    echo ""
    echo "Disk Usage:"
    df -h / | tail -1
    echo ""
    sleep 5
done
EOF

chmod +x ~/beacon-monitor.sh
./beacon-monitor.sh
```

### Performance Logging

**Create comprehensive log:**
```bash
cat > ~/log-performance.sh << 'EOF'
#!/bin/bash
LOG="/tmp/beacon-performance.log"
while true; do
    TIMESTAMP=$(date +%s)
    MEMORY=$(free -m | grep Mem | awk '{print $3}')
    TEMP=$(vcgencmd measure_temp | grep -o '[0-9.]*')
    CPU=$(vcgencmd measure_clock arm | awk -F'=' '{print $2}')

    echo "$TIMESTAMP,$MEMORY,$TEMP,$CPU" >> $LOG
    sleep 60
done
EOF

chmod +x ~/log-performance.sh
```

**Run in background:**
```bash
nohup ~/log-performance.sh &
```

**Analyze logs:**
```bash
# Average memory usage
awk -F',' '{sum+=$2} END {print sum/NR " MB"}' /tmp/beacon-performance.log

# Max temperature
awk -F',' '{if($3>max) max=$3} END {print max "°C"}' /tmp/beacon-performance.log
```

---

## Related Documentation

- **[Hardware Overview](README.md)** - Device selection
- **[Raspberry Pi Details](raspberry-pi.md)** - Pi specifications
- **[Troubleshooting Performance](../troubleshooting/raspberry-pi.md)** - Performance issues
- **[Architecture](../architecture/README.md)** - System design

---

**Last Updated:** 2025-11-30
