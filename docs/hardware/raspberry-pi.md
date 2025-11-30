# Raspberry Pi Hardware Specifications

**Audience:** For hardware selection and Raspberry Pi-specific configuration

This document provides detailed specifications for supported Raspberry Pi models.

---

## Raspberry Pi Zero 2 W (Recommended Entry Tier)

### Specifications

```
CPU:          4× ARM Cortex-A53 @ 1GHz (quad-core)
RAM:          512MB LPDDR2
Storage:      32GB microSD (Class 10 recommended)
WiFi:         2.4GHz 802.11 b/g/n only (no 5GHz)
Bluetooth:    4.2 BLE
Video:        Mini-HDMI 1080p60
GPIO:         40-pin header
Power:        5V @ 2.5A micro-USB (2-3W typical usage)
Size:         65mm × 30mm × 5mm
Weight:       ~10g
Cost:         ~$15
Lifespan:     5+ years
```

### Performance Characteristics

**Boot time:** 90-120 seconds
**Memory usage:** 300-400MB (60-80% of total)
**CPU load:** 30-50% during display
**Temperature:** 45-55°C normal, throttles at 70°C
**Power consumption:** ~$2/year electricity

### Why This Hardware?

✅ **Advantages:**
- Lowest cost option meeting requirements ($50 total with accessories)
- Sufficient for browser-based dashboard display
- Small form factor (hidden behind TV/monitor)
- No battery = truly always-on, no charging infrastructure
- Fanless/silent operation ideal for office environments
- Large community support and extensive documentation

⚠️ **Limitations:**
- 512MB RAM constraint (requires simple dashboards)
- 2.4GHz WiFi only (range may be limited)
- Single-core performance (complex reports may be slow)
- Mini-HDMI connector (requires adapter cable)

### Use Cases

**Perfect for:**
- Simple dashboards (1-5 visuals)
- Budget-constrained deployments
- Proof-of-concept testing
- Small retail stores
- Single-location displays

**Not ideal for:**
- Complex dashboards (10+ visuals)
- Map visualizations
- Real-time data (<60s refresh)
- 4K displays
- Video content

### Required Accessories

- **32GB microSD Card (Class 10):** $10
- **Mini-HDMI to HDMI Cable:** $8
- **Power Supply (5V 2.5A micro-USB):** $10
- **Optional case with heatsink:** $7
- **Total:** $43-50

### Configuration

**GPU Memory Split:**
```
# /boot/config.txt
gpu_mem=128
```

**Memory Limits:**
```
# systemd service
MemoryMax=412M  # 80% of 512MB
```

**Watchdog Threshold:**
```
# watchdog.sh
MEMORY_THRESHOLD=435  # 85% of 512MB
```

---

## Raspberry Pi 4 Model B

### Specifications

```
CPU:          4× ARM Cortex-A72 @ 1.5GHz (quad-core)
RAM:          2GB/4GB/8GB LPDDR4
Storage:      32GB microSD (Class 10, UHS-I recommended)
WiFi:         2.4GHz + 5GHz 802.11ac dual-band
Bluetooth:    5.0 BLE
Video:        2× Micro-HDMI 4K60 (dual display capable)
Ethernet:     Gigabit (1000Mbps)
USB:          2× USB 3.0, 2× USB 2.0
GPIO:         40-pin header
Power:        5V @ 3A USB-C (4-8W typical usage)
Size:         85mm × 56mm × 17mm
Weight:       ~46g
Cost:         $35 (2GB), $55 (4GB), $75 (8GB)
Lifespan:     5+ years
```

### Performance Characteristics

**Boot time:** 60-90 seconds
**Memory usage:** 400-800MB (depending on model)
**CPU load:** 20-40% during display
**Temperature:** 40-50°C normal, throttles at 80°C
**Power consumption:** ~$4/year electricity

### Recommended Model

**2GB Model - $35:**
- Sufficient for most dashboards
- Best value for typical use cases
- 10-15 visuals per report

**4GB Model - $55:**
- Complex dashboards (15-20 visuals)
- Multi-report rotation
- Future-proofing

**8GB Model - $75:**
- Rarely needed for BEACON
- Overkill for single dashboard display
- Consider if running additional services

### Use Cases

**Perfect for:**
- Complex dashboards (10-20 visuals)
- Map visualizations
- Faster refresh rates (30s)
- Multiple locations with varying complexity
- Dual-display setups
- Future-proofing

**Overkill for:**
- Simple dashboards (1-5 visuals)
- Budget-constrained deployments (Pi Zero 2 W cheaper)

### Required Accessories

- **32GB microSD Card (UHS-I):** $12
- **Micro-HDMI to HDMI Cable:** $8
- **Power Supply (5V 3A USB-C):** $10
- **Case with fan (recommended):** $15
- **Total:** $80-100 (2GB model + accessories)

### Configuration

**GPU Memory Split:**
```
# /boot/config.txt
gpu_mem=128
```

**Memory Limits (2GB model):**
```
# systemd service
MemoryMax=1900M  # ~95% of 2GB
```

**Watchdog Threshold (2GB model):**
```
# watchdog.sh
MEMORY_THRESHOLD=1700  # 85% of 2GB
```

### Performance Optimization

**For 2GB model:**
- Disable unnecessary services
- Use lightweight window manager
- Configure swap file (optional)

**For 4GB/8GB models:**
- Standard configuration sufficient
- Can run additional monitoring services

---

## Raspberry Pi 5

### Specifications

```
CPU:          4× ARM Cortex-A76 @ 2.4GHz (quad-core)
RAM:          4GB/8GB LPDDR4X
Storage:      32GB microSD (UHS-I or better)
WiFi:         2.4GHz + 5GHz 802.11ac dual-band
Bluetooth:    5.0 BLE
Video:        2× Micro-HDMI 4K60 @ 60Hz (dual 4K display capable)
Ethernet:     Gigabit (1000Mbps)
USB:          2× USB 3.0, 2× USB 2.0
GPIO:         40-pin header
PCIe:         1× PCIe 2.0 (via ribbon cable)
Power:        5V @ 5A USB-C (8-12W typical usage)
Size:         85mm × 56mm × 17mm
Weight:       ~45g
Cost:         $60 (4GB), $80 (8GB)
Lifespan:     5+ years
```

### Performance Characteristics

**Boot time:** 45-60 seconds
**Memory usage:** 500-1000MB
**CPU load:** 15-30% during display
**Temperature:** 40-50°C normal (with active cooling)
**Power consumption:** ~$5/year electricity

### Use Cases

**Perfect for:**
- Very complex dashboards (20+ visuals)
- Real-time data (15-30s refresh)
- 4K displays
- Multi-report rotation with transitions
- Future-proofing for 5+ years
- Dual 4K display setups

**Overkill for:**
- Simple dashboards
- 1080p displays
- Budget-constrained deployments

### Required Accessories

- **32GB microSD Card (UHS-I):** $12
- **Micro-HDMI to HDMI Cable:** $8
- **Power Supply (5V 5A USB-C - official):** $12
- **Active cooling case (highly recommended):** $20
- **Total:** $112-132 (4GB model + accessories)

### Configuration

**GPU Memory Split:**
```
# /boot/firmware/config.txt (note: different path than Pi 4)
gpu_mem=128
```

**Memory Limits (4GB model):**
```
# systemd service
MemoryMax=3900M  # ~97% of 4GB
```

**Watchdog Threshold (4GB model):**
```
# watchdog.sh
MEMORY_THRESHOLD=3400  # 85% of 4GB
```

### Performance Optimization

**Recommended:**
- Active cooling (official case or compatible)
- High-quality power supply (official 27W recommended)
- Fast microSD card (UHS-I or better)

**Optional:**
- NVMe SSD via PCIe (fastest storage)
- Overclock for extreme performance (not needed for BEACON)

---

## Comparison Matrix

| Feature | Pi Zero 2 W | Pi 4 (2GB) | Pi 4 (4GB) | Pi 5 (4GB) |
|---------|------------|-----------|-----------|-----------|
| **Price (board only)** | $15 | $35 | $55 | $60 |
| **Total Cost (with accessories)** | $50 | $80 | $100 | $112 |
| **CPU Speed** | 1GHz | 1.5GHz | 1.5GHz | 2.4GHz |
| **RAM** | 512MB | 2GB | 4GB | 4GB |
| **WiFi** | 2.4GHz | 2.4/5GHz | 2.4/5GHz | 2.4/5GHz |
| **Ethernet** | USB adapter | Gigabit | Gigabit | Gigabit |
| **Max Resolution** | 1080p60 | 4K60 | 4K60 | 4K60 |
| **Boot Time** | 90-120s | 60-90s | 60-90s | 45-60s |
| **Recommended Dashboard Complexity** | Simple (1-5 visuals) | Medium (10-15) | Complex (15-20) | Very Complex (20+) |
| **Refresh Interval** | 60s | 30-60s | 30s | 15-30s |
| **Cooling** | Passive OK | Fan recommended | Fan recommended | Active required |
| **Power Draw** | 2-3W | 4-6W | 4-8W | 8-12W |
| **Deployment Scale** | POC, 1-10 | Pilot, 10-50 | Production, 50+ | Enterprise, 100+ |

---

## Boot Configuration

### Pi Zero 2 W / Pi 4

**Location:** `/boot/config.txt`

**BEACON-specific settings:**
```
# GPU Memory for Chromium
gpu_mem=128

# Disable unnecessary features
dtparam=audio=off
camera_auto_detect=0

# Performance
arm_boost=1

# HDMI settings (force HDMI on boot)
hdmi_force_hotplug=1
hdmi_drive=2
```

### Pi 5

**Location:** `/boot/firmware/config.txt` (note different path)

**BEACON-specific settings:**
```
# GPU Memory for Chromium
gpu_mem=128

# Disable unnecessary features
dtparam=audio=off

# HDMI settings
hdmi_force_hotplug=1
```

---

## Temperature Management

### Normal Operating Temperatures

| Model | Idle | Active Display | Warning | Throttle |
|-------|------|---------------|---------|----------|
| **Pi Zero 2 W** | 40-45°C | 45-55°C | 60°C | 70°C |
| **Pi 4** | 35-40°C | 40-50°C | 70°C | 80°C |
| **Pi 5** | 35-40°C | 40-50°C | 75°C | 85°C |

### Monitoring Temperature

```bash
# Check current temperature
vcgencmd measure_temp

# Monitor continuously
watch -n 5 vcgencmd measure_temp

# Check throttling status
vcgencmd get_throttled
# 0x0 = OK, other values indicate throttling
```

### Cooling Solutions

**Pi Zero 2 W:**
- Passive heatsink ($2-5)
- Case with passive cooling ($7)
- Natural airflow usually sufficient

**Pi 4:**
- Case with fan ($15-20)
- Active cooling recommended
- Fan case maintains 40-45°C

**Pi 5:**
- Active cooling case ($20-25)
- Official Active Cooler ($5)
- Active cooling required for sustained performance

---

## Power Requirements

### Power Supply Specifications

| Model | Connector | Voltage | Current | Power | Official PSU Cost |
|-------|-----------|---------|---------|-------|------------------|
| **Pi Zero 2 W** | Micro-USB | 5V | 2.5A | 12.5W | $10 |
| **Pi 4** | USB-C | 5V | 3A | 15W | $10 |
| **Pi 5** | USB-C | 5V | 5A | 27W | $12 |

### Actual Power Consumption

**Pi Zero 2 W:**
- Idle: 0.4-0.6W
- Active display: 2-3W
- Peak: 3.5W

**Pi 4 (2GB):**
- Idle: 2-3W
- Active display: 4-6W
- Peak: 8W

**Pi 5 (4GB):**
- Idle: 3-4W
- Active display: 8-10W
- Peak: 12W

### Annual Electricity Cost

Based on $0.12/kWh average US rate:

- **Pi Zero 2 W:** ~$2/year
- **Pi 4:** ~$4/year
- **Pi 5:** ~$5/year

**100 devices over 5 years:**
- Pi Zero 2 W: $1,000 electricity
- Pi 4: $2,000 electricity
- Pi 5: $2,500 electricity

---

## Network Connectivity

### WiFi Specifications

| Model | Bands | Standard | Typical Range |
|-------|-------|----------|---------------|
| **Pi Zero 2 W** | 2.4GHz only | 802.11n | 10-15m indoor |
| **Pi 4** | 2.4/5GHz dual | 802.11ac | 15-20m indoor |
| **Pi 5** | 2.4/5GHz dual | 802.11ac | 15-20m indoor |

### Ethernet Options

**Pi Zero 2 W:**
- USB Ethernet adapter required ($10-15)
- Micro-USB OTG adapter needed
- 100Mbps typical

**Pi 4 / Pi 5:**
- Built-in Gigabit Ethernet
- 1000Mbps (full duplex)
- More reliable than WiFi

### Recommendations

**Use WiFi when:**
- Wired connection not feasible
- Device within 10-15m of router (Pi Zero 2 W)
- Device within 15-20m of router (Pi 4/5)
- Network traffic is light

**Use Ethernet when:**
- Wired connection available
- WiFi signal weak
- Maximum reliability required
- Corporate network requirements

---

## Storage Requirements

### microSD Card Specifications

**Minimum:**
- Capacity: 16GB (OS + BEACON)
- Class: Class 10
- Speed: 10MB/s write

**Recommended:**
- Capacity: 32GB (headroom for logs)
- Class: UHS-I (U1)
- Speed: 40-90MB/s write
- Brand: SanDisk, Samsung, Kingston

**Premium (Pi 4/5):**
- Capacity: 32-64GB
- Class: UHS-I (U3) or UHS-II
- Speed: 90-300MB/s write
- Application Class: A1 or A2

### Storage Usage

**After installation:**
```
OS (Raspberry Pi OS Lite):    ~1.5GB
BEACON files:                  ~5MB
Chromium and dependencies:     ~200MB
Logs (growing):                ~50-100MB
Free space:                    ~14GB (on 16GB card)
```

### Backup and Imaging

**Create image of working SD card:**
```bash
# On laptop (Mac/Linux)
sudo dd if=/dev/diskN of=beacon-backup.img bs=4m

# On Windows
# Use Win32DiskImager or similar
```

**Clone SD card:**
```bash
# On laptop
sudo dd if=/dev/diskN of=/dev/diskM bs=4m
```

---

## GPIO and Expansion

### GPIO Header (All Models)

**40-pin header:**
- 26× GPIO pins
- 2× 5V power pins
- 2× 3.3V power pins
- 8× Ground pins
- I2C, SPI, UART available

**BEACON doesn't use GPIO by default**, but available for:
- Status LEDs
- Reset buttons
- Environmental sensors
- Touch displays
- Custom integrations

### Example GPIO Uses

**Status LED:**
- Green: Display running
- Red: Error state
- Amber: Low memory warning

**Reset Button:**
- Physical button to restart service
- Useful for non-technical users

**Temperature Sensor:**
- Monitor ambient temperature
- Alert if too hot/cold

---

## Related Documentation

- **[Hardware Overview](README.md)** - Device selection guide
- **[Alternative Devices](alternative-devices.md)** - Non-Pi options
- **[Optimization](optimization.md)** - Performance tuning
- **[Architecture](../architecture/README.md)** - System design
- **[Troubleshooting Pi Issues](../troubleshooting/raspberry-pi.md)** - Pi-specific problems

---

**Last Updated:** 2025-11-30
