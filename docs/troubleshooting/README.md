# BEACON Troubleshooting Guide

**Audience:** For diagnosing and resolving BEACON issues

This document provides a diagnostic approach, quick flowchart, and symptom index for troubleshooting BEACON deployments.

---

## Diagnostic Approach

### 1. Identify the Symptom

**What's the observed problem?**
- Display shows nothing (blank screen)
- "Loading..." message never disappears
- Error message displayed
- Report loads but doesn't refresh
- Service crashes or restarts frequently

### 2. Isolate the Component

**Which component is failing?**
- **Display Client** (Raspberry Pi browser)
- **Token Service** (laptop/server)
- **Network** (connectivity between components)
- **Azure AD** (authentication)
- **Power BI** (report access)

### 3. Gather Information

**Collect diagnostic data:**
- Service logs
- System metrics
- Network connectivity
- Configuration files
- Recent changes

### 4. Apply Solution

**Follow specific troubleshooting guide:**
- [Token Service Issues](token-service.md)
- [Display Client Issues](display-client.md)
- [Raspberry Pi Issues](raspberry-pi.md)
- [Network Issues](network.md)

---

## Quick Diagnostic Flowchart

```
Display not working?
│
├─ Is Pi powered on and booting?
│  │
│  ├─ NO: Check power supply, cables, SD card
│  │       See: Raspberry Pi Issues → Boot Problems
│  │
│  └─ YES: Continue
│
├─ Does display show HDMI signal?
│  │
│  ├─ NO: Check HDMI cable, try different input
│  │       See: Raspberry Pi Issues → HDMI Problems
│  │
│  └─ YES: Continue
│
├─ What does screen show?
│  │
│  ├─ Blank/black screen
│  │  └─ See: Display Client Issues → Blank Screen
│  │
│  ├─ "Loading..." forever
│  │  └─ See: Display Client Issues → Loading Forever
│  │
│  ├─ Error message
│  │  └─ Note error text, see specific issue below
│  │
│  └─ Report shows but doesn't refresh
│     └─ See: Display Client Issues → Refresh Failures
│
├─ Error: "Failed to Generate Embed Token"
│  └─ See: Token Service Issues → Authentication Failures
│
├─ Error: "Network Error"
│  └─ See: Network Issues → Connectivity Problems
│
└─ Error: "Authentication Failed" (after 1 hour)
   └─ See: Display Client Issues → Token Expiry
```

---

## Quick Diagnostic Commands

### On Raspberry Pi

```bash
# Check display service status
sudo systemctl status beacon-display

# View recent logs (last 50 lines)
sudo journalctl -u beacon-display -n 50

# View live logs (follow mode)
sudo journalctl -u beacon-display -f

# Check memory usage (should be <400MB on Pi Zero 2 W)
free -h

# Check CPU temperature (should be <60°C)
vcgencmd measure_temp

# Test network connectivity
ping -c 3 8.8.8.8
ping -c 3 YOUR-LAPTOP-IP

# Test token service reachability
curl http://YOUR-LAPTOP-IP:3000/health
```

### On Your Laptop (Token Service)

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

## Symptom Index

### Display Symptoms

| Symptom | Likely Cause | Quick Fix | Full Guide |
|---------|--------------|-----------|------------|
| **Blank/black screen** | HDMI issue, service not started | Check HDMI cable, restart service | [Display Client](display-client.md#blank-screen) |
| **"Loading..." forever** | Token service unreachable | Check service running, test connectivity | [Display Client](display-client.md#loading-forever) |
| **"Failed to Generate Embed Token"** | Azure auth issue | Check .env credentials, secret expiry | [Token Service](token-service.md#auth-failures) |
| **"Network Error"** | Connectivity issue | Check WiFi, firewall, token service | [Network](network.md#connectivity) |
| **Report not refreshing** | Auto-refresh failed | Check config, restart service | [Display Client](display-client.md#refresh-failures) |
| **Display frozen** | High memory, crash | Check memory usage, restart | [Raspberry Pi](raspberry-pi.md#memory-issues) |

### Service Symptoms

| Symptom | Likely Cause | Quick Fix | Full Guide |
|---------|--------------|-----------|------------|
| **Service won't start** | Config error, missing files | Check logs, verify installation | [Raspberry Pi](raspberry-pi.md#auto-start-failures) |
| **Service keeps restarting** | Memory limit, crash loop | Check memory, simplify report | [Raspberry Pi](raspberry-pi.md#memory-issues) |
| **Token service not responding** | Not running, crashed | Restart token service | [Token Service](token-service.md#service-startup) |

### Performance Symptoms

| Symptom | Likely Cause | Quick Fix | Full Guide |
|---------|--------------|-----------|------------|
| **Slow loading** | Complex report, weak network | Simplify report, check WiFi | [Raspberry Pi](raspberry-pi.md#performance) |
| **High memory usage** | Too many visuals | Reduce report complexity | [Raspberry Pi](raspberry-pi.md#memory-issues) |
| **Pi running hot** | Poor ventilation, no heatsink | Add heatsink, improve airflow | [Raspberry Pi](raspberry-pi.md#thermal) |
| **WiFi dropouts** | Weak signal, interference | Move closer to router, use Ethernet | [Network](network.md#wifi) |

### Authentication Symptoms

| Symptom | Likely Cause | Quick Fix | Full Guide |
|---------|--------------|-----------|------------|
| **"Invalid client secret"** | Wrong/expired secret | Check .env, rotate secret | [Token Service](token-service.md#auth-failures) |
| **"Unauthorized"** | Missing permissions | Check workspace access | [Token Service](token-service.md#azure-problems) |
| **Token expires after 1 hour** | Not refreshing | Check tokenRefreshMinutes <60 | [Display Client](display-client.md#token-expiry) |

---

## Common Issues Quick Reference

### Issue: Display Shows "Loading..." Forever

**Quick Diagnosis:**
```bash
# 1. Check token service (on laptop)
curl http://localhost:3000/health

# 2. Check from Pi
ping YOUR-LAPTOP-IP
curl http://YOUR-LAPTOP-IP:3000/health

# 3. Check config
cat ~/beacon-display/display-client/config.json
```

**Quick Fix:**
```bash
# If token service not running
cd token-service/laptop-version
npm start

# If firewall blocking
# Mac: System Preferences → Security → Firewall → Allow port 3000
# Linux: sudo ufw allow 3000
```

**See:** [Display Client Issues → Loading Forever](display-client.md#loading-forever)

---

### Issue: "Failed to Generate Embed Token"

**Quick Diagnosis:**
```bash
# Check .env file
cd token-service/laptop-version
cat .env | grep -E "TENANT_ID|CLIENT_ID|CLIENT_SECRET"

# Test token service directly
curl http://localhost:3000/health
```

**Quick Fix:**
```bash
# 1. Verify credentials in Azure Portal
# 2. Check secret hasn't expired (12-month validity)
# 3. Verify service principal in Power BI workspace
# 4. Restart token service
```

**See:** [Token Service Issues → Auth Failures](token-service.md#auth-failures)

---

### Issue: High Memory Usage / Pi Crashes

**Quick Diagnosis:**
```bash
# Check memory
free -h

# Check which process using memory
ps aux --sort=-%mem | head -10
```

**Quick Fix:**
```bash
# 1. Simplify Power BI report (reduce visuals)
# 2. Restart service
sudo systemctl restart beacon-display

# 3. Check watchdog is running (auto-restart at 85%)
sudo systemctl status beacon-display
```

**See:** [Raspberry Pi Issues → Memory Issues](raspberry-pi.md#memory-issues)

---

### Issue: Pi Runs Hot / Overheating

**Quick Diagnosis:**
```bash
# Check temperature
vcgencmd measure_temp
# Normal: 45-55°C, Warning: 60-70°C, Critical: >70°C

# Check throttling
vcgencmd get_throttled
# 0x0 = OK, other values indicate throttling
```

**Quick Fix:**
```bash
# 1. Add heatsink ($7 passive cooling case)
# 2. Improve ventilation
# 3. Reduce CPU load (simplify report, increase refresh interval)
```

**See:** [Raspberry Pi Issues → Thermal](raspberry-pi.md#thermal)

---

### Issue: WiFi Connection Drops

**Quick Diagnosis:**
```bash
# Check WiFi status
iwconfig wlan0

# Check signal strength
iwconfig wlan0 | grep "Signal level"
```

**Quick Fix:**
```bash
# 1. Move Pi closer to router
# 2. Use WiFi extender
# 3. Switch to Ethernet (recommended for production)
```

**See:** [Network Issues → WiFi](network.md#wifi)

---

## Escalation Path

### Level 1: Self-Service (This Documentation)
- Review troubleshooting guides
- Check quick fixes
- Review configuration
- Test basic connectivity

### Level 2: Detailed Diagnostics
- Gather full diagnostic data
- Review service logs
- Check Azure Portal
- Verify Power BI workspace

### Level 3: Advanced Troubleshooting
- Reproduce issue in isolated environment
- Test with public Power BI sample
- Compare working vs non-working configurations
- Review recent code/config changes

### Level 4: Community Support
- Search GitHub Issues
- Post detailed issue report
- Include diagnostic information
- Attach relevant logs

---

## Diagnostic Data Collection

### When Reporting Issues

**Always include:**

1. **Environment:**
   ```bash
   # OS version
   cat /etc/os-release
   uname -a

   # BEACON version
   git log -1 --oneline

   # Hardware
   cat /proc/cpuinfo | grep Model
   ```

2. **System metrics:**
   ```bash
   # Memory
   free -h

   # Temperature
   vcgencmd measure_temp

   # Disk space
   df -h
   ```

3. **Service logs:**
   ```bash
   # Last 200 lines
   sudo journalctl -u beacon-display -n 200 > ~/beacon-logs.txt
   ```

4. **Configuration (redact secrets):**
   ```bash
   # Config (remove sensitive IDs)
   cat ~/beacon-display/display-client/config.json
   ```

5. **Network:**
   ```bash
   # IP address
   ip addr show

   # Connectivity
   ping -c 3 8.8.8.8
   curl http://TOKEN-SERVICE-URL/health
   ```

---

## Detailed Troubleshooting Guides

- **[Token Service Issues](token-service.md)** - Service startup, auth failures, token issues, Azure problems
- **[Display Client Issues](display-client.md)** - Blank screen, embed errors, not loading, browser errors, refresh failures
- **[Raspberry Pi Issues](raspberry-pi.md)** - Boot problems, memory, WiFi, HDMI, auto-start failures
- **[Network Issues](network.md)** - Connectivity, firewall, DNS, VLAN, WiFi range

---

## Related Documentation

- **[Architecture](../architecture/README.md)** - System design and components
- **[Hardware Guide](../hardware/README.md)** - Device specifications
- **[Getting Started](../../GETTING-STARTED.md)** - Setup and installation
- **[Deployment Guide](../../DEPLOYMENT.md)** - Production deployment

---

**Last Updated:** 2025-11-30
