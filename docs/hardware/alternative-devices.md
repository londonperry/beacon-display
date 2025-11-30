# Alternative Devices for BEACON

**Audience:** For exploring non-Raspberry Pi hardware options

This document covers alternative single-board computers and mini PCs that can run BEACON.

---

## Overview

While Raspberry Pi devices are recommended for BEACON, other hardware can work with minimal or no code changes. This document covers:

- Intel NUC and mini PCs
- Orange Pi and similar ARM boards
- ODROID boards
- Other SBC options

---

## Intel NUC (x86_64)

### Why Consider Intel NUC?

**Advantages:**
- Extreme performance (overkill for most dashboards)
- Native x86 architecture (more software compatibility)
- 4K multi-display support
- Existing corporate infrastructure (may already have spares)
- M.2 SSD support (no SD card failures)

**Disadvantages:**
- Higher cost ($200-400)
- Higher power consumption (15-25W)
- Larger form factor
- Requires active cooling (fan noise)
- Overkill for Power BI dashboard display

### Recommended Models

**Intel NUC N100 (Budget):**
```
CPU:          Intel N100 (quad-core, 3.4GHz)
RAM:          8GB DDR4 (upgradeable to 16GB)
Storage:      128GB M.2 SSD
WiFi:         WiFi 6 (802.11ax)
Ethernet:     Gigabit
Video:        HDMI 2.0, DisplayPort (4K60)
Power:        12V @ 3A (15-25W typical)
Cost:         $200-250 complete
Lifespan:     7+ years
```

**Intel NUC 11/12 (Premium):**
```
CPU:          Intel Core i3/i5/i7 (11th/12th gen)
RAM:          8-32GB DDR4
Storage:      256GB-1TB M.2 NVMe SSD
WiFi:         WiFi 6E (802.11ax)
Ethernet:     Gigabit or 2.5GbE
Video:        HDMI 2.0, Thunderbolt 4 (multi-4K)
Power:        19V @ 6A (30-65W typical)
Cost:         $400-800 complete
Lifespan:     10+ years
```

### BEACON Compatibility

**Code changes needed:** None

**Auto-detects:**
- Device type: `intel-nuc` or `generic-x86`
- Temperature monitoring via `/sys/class/thermal/thermal_zone0/temp`
- Chromium binary: Auto-finds `chromium`, `google-chrome`, or `chrome`
- Memory threshold: Calculated based on total RAM (capped at 2GB for display)

### Performance

**Boot time:** 30-45 seconds
**Memory usage:** 600-1200MB (plenty of headroom)
**CPU load:** 10-30%
**Temperature:** 35-45°C (with fan)
**Power consumption:** ~$10-15/year electricity

### Use Cases

**Perfect for:**
- Extremely complex dashboards (25+ visuals)
- 4K displays or dual 4K displays
- Video content in dashboards
- Real-time data (10-15s refresh)
- Environments with existing NUC infrastructure
- Backup/spare NUC devices available

**Not cost-effective for:**
- Simple dashboards (Raspberry Pi cheaper)
- Budget-constrained deployments
- Standard 1080p displays

### OS Recommendations

**Best:**
- Ubuntu Server 22.04 LTS (ARM64 or x86_64)
- Debian 12 "Bookworm"

**Also works:**
- Ubuntu Desktop (if you need desktop environment)
- Pop!_OS
- Linux Mint

**Avoid:**
- Windows (requires different scripts)
- Fedora/RHEL (requires package manager changes)

---

## Orange Pi

### Orange Pi 5 Plus

```
CPU:          Rockchip RK3588 (8-core, up to 2.4GHz)
              4× Cortex-A76 + 4× Cortex-A55
RAM:          4GB/8GB/16GB/32GB LPDDR4X
Storage:      microSD + M.2 NVMe SSD slot
WiFi:         WiFi 5 (802.11ac) optional module
Bluetooth:    5.0 (with WiFi module)
Ethernet:     Gigabit (1000Mbps)
Video:        HDMI 2.1 (8K30 or 4K120), DisplayPort 1.4
GPIO:         40-pin header
Power:        5V @ 4A USB-C (10-15W typical)
Cost:         $80-150 (depending on RAM)
Lifespan:     5+ years
```

### BEACON Compatibility

**Code changes needed:** Minimal to none

**May require:**
- OS: Armbian (Debian-based for Orange Pi)
- Temperature monitoring path adjustment
- Chromium package name verification

**Auto-adapts:**
- Memory thresholds based on RAM
- Device detection
- Chromium binary location

### Performance

**Boot time:** 45-60 seconds
**Memory usage:** 500-1000MB
**CPU load:** 15-25%
**Temperature:** 40-50°C (with heatsink)
**Power consumption:** ~$5/year electricity

### Use Cases

**Consider Orange Pi 5 Plus for:**
- Pi 4/5 alternative with more RAM options
- M.2 SSD support (no SD card issues)
- 8K display capability (future-proofing)
- Budget $80-100 but need performance

**Stick with Raspberry Pi for:**
- Better community support
- More stable OS images
- Easier troubleshooting
- Proven BEACON compatibility

### OS Recommendations

**Best:**
- Armbian (Debian-based, Orange Pi-specific)
- Ubuntu 22.04 for Orange Pi

**Installation:**
```bash
# Deploy BEACON as normal
./scripts/deploy-to-pi.sh orange-pi-ip

# May need to install Chromium manually
ssh user@orange-pi-ip
sudo apt update
sudo apt install -y chromium-browser
```

---

## ODROID

### ODROID-N2+

```
CPU:          Amlogic S922X (6-core, up to 2.2GHz)
              4× Cortex-A73 + 2× Cortex-A53
RAM:          2GB/4GB DDR4
Storage:      microSD + eMMC module slot
Ethernet:     Gigabit
WiFi:         Optional USB module
Video:        HDMI 2.0 (4K60)
GPIO:         40-pin header
Power:        12V @ 2A barrel jack (15-20W)
Cost:         $60-100
Lifespan:     5+ years
```

### BEACON Compatibility

**Code changes needed:** Minimal

**May require:**
- OS: Ubuntu 20.04 for ODROID
- Temperature monitoring adjustment
- Different thermal zone path

**Auto-adapts:**
- Memory thresholds
- Chromium binary detection

### Performance

**Boot time:** 45-60 seconds
**Memory usage:** 400-800MB
**CPU load:** 20-35%
**Temperature:** 40-55°C
**Power consumption:** ~$8/year electricity

### Use Cases

**Consider ODROID for:**
- eMMC storage (faster and more reliable than microSD)
- 12V power (may match existing infrastructure)
- Alternative to Raspberry Pi (stock issues)

**Stick with Raspberry Pi for:**
- Better software support
- Larger community
- More accessories available

---

## Other Single-Board Computers

### ASUS Tinker Board

```
CPU:          Rockchip RK3288 (quad-core, 1.8GHz)
RAM:          2GB DDR3
Video:        HDMI 2.0 (4K30)
Cost:         $55-75
Compatibility: Good (similar to Raspberry Pi)
```

**Status:** Should work with minimal changes

### NVIDIA Jetson Nano

```
CPU:          Quad-core ARM Cortex-A57 @ 1.43GHz
GPU:          128-core NVIDIA Maxwell
RAM:          2GB/4GB LPDDR4
Cost:         $99-149
```

**Status:** Works, but GPU overkill for BEACON
**Better for:** AI/ML workloads, not dashboard display

### Pine64 ROCKPro64

```
CPU:          Rockchip RK3399 (6-core)
RAM:          2GB/4GB LPDDR4
Cost:         $60-80
```

**Status:** Should work with Armbian

---

## Comparison: Raspberry Pi vs Alternatives

| Feature | Pi Zero 2W | Pi 4 (2GB) | Orange Pi 5+ | Intel NUC N100 | ODROID-N2+ |
|---------|-----------|-----------|-------------|---------------|-----------|
| **Cost** | $50 | $80 | $100 | $250 | $80 |
| **Performance** | Basic | Good | Excellent | Extreme | Very Good |
| **Community Support** | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| **OS Maturity** | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★★★ | ★★★★☆ |
| **Power Draw** | 2-3W | 4-8W | 10-15W | 15-25W | 15-20W |
| **Storage** | microSD | microSD | microSD+NVMe | M.2 SSD | microSD+eMMC |
| **BEACON Compatibility** | ★★★★★ | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★☆ |
| **Recommended?** | ✅ Yes | ✅ Yes | ⚠️ Maybe | ⚠️ Overkill | ⚠️ Maybe |

---

## Decision Matrix

### Choose Raspberry Pi Zero 2 W if:
- Budget is primary concern ($50)
- Simple dashboards
- Standard 1080p displays
- Proven compatibility essential

### Choose Raspberry Pi 4 if:
- Complex dashboards
- Dual-band WiFi needed
- Best balance of cost/performance
- Maximum community support

### Choose Raspberry Pi 5 if:
- Very complex dashboards
- Future-proofing for 5+ years
- Latest hardware desired

### Choose Orange Pi 5 Plus if:
- Need M.2 SSD storage
- Want more RAM (16GB/32GB)
- Pi 4 alternative at similar price
- Comfortable with Armbian

### Choose Intel NUC if:
- Extreme performance needed
- Existing NUC infrastructure
- 4K multi-display required
- M.2 SSD essential
- Budget >$200 acceptable

### Choose ODROID if:
- Want eMMC storage
- 12V power infrastructure
- Raspberry Pi out of stock

---

## General Compatibility Guidelines

### Will BEACON work on device X?

**Check these requirements:**

1. ✅ **Linux-based OS** (Debian/Ubuntu preferred)
2. ✅ **512MB+ RAM** (2GB+ recommended)
3. ✅ **Chromium browser** available
4. ✅ **Network connectivity** (WiFi or Ethernet)
5. ✅ **HDMI output** (or DisplayPort)

**If all YES:**
- BEACON will likely work with zero or minimal changes

**Test process:**
1. Deploy BEACON to device
2. Run install script
3. Check for errors
4. Test hardware detection: `source device-detect.sh && get_device_info`
5. Document any issues or modifications needed

### Common Adaptation Steps

**1. Temperature monitoring:**
```bash
# Test thermal zone
cat /sys/class/thermal/thermal_zone0/temp

# If different path, update device-detect.sh
```

**2. Chromium package:**
```bash
# Try installing
sudo apt install chromium-browser
# or
sudo apt install chromium

# Update get_chromium_command() if needed
```

**3. Memory threshold:**
```bash
# Automatic - based on total RAM
free -m  # Check total memory
# watchdog.sh auto-calculates 85% threshold
```

---

## Not Recommended Devices

### ❌ Raspberry Pi 3 (all models)
**Why:** Older CPU, 1GB RAM limit, replaced by Pi Zero 2 W and Pi 4
**Alternative:** Use Pi Zero 2 W (cheaper, smaller) or Pi 4 (faster, more RAM)

### ❌ Raspberry Pi 1/2
**Why:** Too slow, insufficient RAM, outdated
**Alternative:** Pi Zero 2 W minimum

### ❌ Raspberry Pi Pico/Pico W
**Why:** Microcontroller (not computer), no OS, no browser
**Alternative:** Raspberry Pi Zero 2 W

### ❌ Android devices
**Why:** Requires completely different app architecture
**Alternative:** Raspberry Pi or dedicated Android app (not in scope)

### ❌ Amazon Fire Stick / Chromecast
**Why:** Locked-down OS, no SSH access, no control over boot/display
**Alternative:** Raspberry Pi

---

## Cost Analysis (100 devices, 5 years)

| Device | Hardware Cost | Power Cost | Total | Notes |
|--------|--------------|-----------|-------|-------|
| **Pi Zero 2 W** | $5,000 | $1,000 | $6,000 | Best value |
| **Pi 4 (2GB)** | $8,000 | $2,000 | $10,000 | Best performance/$ |
| **Pi 5 (4GB)** | $11,200 | $2,500 | $13,700 | Future-proof |
| **Orange Pi 5+** | $10,000 | $2,500 | $12,500 | Alternative to Pi 4/5 |
| **Intel NUC N100** | $25,000 | $7,500 | $32,500 | 5× Pi cost |
| **ODROID-N2+** | $8,000 | $4,000 | $12,000 | Similar to Pi 4 |

**Recommendation:** Raspberry Pi 4 (2GB) offers best balance for production deployments.

---

## Related Documentation

- **[Hardware Overview](README.md)** - Device selection guide
- **[Raspberry Pi Details](raspberry-pi.md)** - Pi-specific information
- **[Optimization](optimization.md)** - Performance tuning
- **[Architecture](../architecture/README.md)** - System design

---

**Last Updated:** 2025-11-30
