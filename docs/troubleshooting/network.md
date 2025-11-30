# Network Troubleshooting

**Audience:** For diagnosing network connectivity and firewall issues

This document covers connectivity problems, firewall configuration, DNS issues, VLAN setup, and WiFi range problems.

---

## Connectivity Problems

### Issue: Cannot Reach Token Service

**Symptoms:**
- Display shows "Loading..." forever
- "Network Error" message
- curl fails to token service
- Timeout errors

#### Diagnosis

**1. Test basic connectivity:**
```bash
# From Pi, ping laptop
ping -c 3 YOUR-LAPTOP-IP

# Expected: 0% packet loss, <10ms latency
```

**2. Test token service port:**
```bash
# From Pi
curl http://YOUR-LAPTOP-IP:3000/health

# Expected: {"status":"healthy"}
```

**3. Check if service is running:**
```bash
# On laptop
lsof -i :3000
# Should show node process listening on port 3000
```

**4. Check route to laptop:**
```bash
# From Pi
traceroute YOUR-LAPTOP-IP
# Should show direct route (1-2 hops)
```

#### Solutions

**1. Verify IP addresses:**
```bash
# Find laptop IP
# Mac/Linux:
ifconfig | grep "inet " | grep -v 127.0.0.1
# Windows:
ipconfig | findstr IPv4

# Verify Pi has correct IP in config.json
cat ~/beacon-display/display-client/config.json | grep tokenServiceUrl
```

**2. Start token service:**
```bash
# On laptop
cd token-service/laptop-version
npm start

# Verify it's running
curl http://localhost:3000/health
```

**3. Check same subnet:**
```bash
# Pi and laptop must be on same network
# Pi: 192.168.1.150
# Laptop: 192.168.1.100
# ✅ Same network (192.168.1.x)

# Pi: 192.168.1.150
# Laptop: 192.168.0.100
# ❌ Different networks
```

**4. Update config.json:**
```bash
nano ~/beacon-display/display-client/config.json

{
  "tokenServiceUrl": "http://CORRECT-LAPTOP-IP:3000/api/embed-token"
}

sudo systemctl restart beacon-display
```

---

## Firewall Issues

### Issue: Firewall Blocking Connections

**Symptoms:**
- Token service running but unreachable
- Connection refused errors
- Timeout from remote hosts
- Works locally but not from Pi

#### Diagnosis

**1. Test locally (on laptop):**
```bash
curl http://localhost:3000/health
# Should work
```

**2. Test remotely (from Pi):**
```bash
curl http://LAPTOP-IP:3000/health
# Fails = firewall issue
```

**3. Check firewall status:**
```bash
# Mac
# System Preferences → Security & Privacy → Firewall

# Linux
sudo ufw status

# Windows
# Windows Defender Firewall → Advanced settings
```

#### Solutions

**Mac Firewall:**
```bash
# System Preferences → Security & Privacy → Firewall
# Click lock to make changes
# Firewall Options
# Add Node.js application
# Allow incoming connections
# OK
```

**Linux (UFW):**
```bash
# Allow port 3000
sudo ufw allow 3000

# Check status
sudo ufw status

# Should show:
# 3000        ALLOW       Anywhere
```

**Windows Firewall:**
```bash
# Windows Defender Firewall
# Advanced settings
# Inbound Rules → New Rule
# Port → TCP → Specific local ports: 3000
# Allow the connection
# Apply to all profiles
# Name: BEACON Token Service
```

**Corporate Firewall:**
```bash
# Contact IT team
# Provide required endpoints:
# - login.microsoftonline.com:443
# - api.powerbi.com:443
# - app.powerbi.com:443
# - cdn.jsdelivr.net:443
```

---

## DNS Problems

### Issue: Cannot Resolve Hostnames

**Symptoms:**
- "Could not resolve host" errors
- Ping by IP works, ping by name fails
- DNS lookup failures

#### Diagnosis

**1. Test DNS resolution:**
```bash
# From Pi
nslookup api.powerbi.com
# Should return IP addresses

# If fails:
ping 8.8.8.8  # Google DNS by IP
# Works = DNS issue, not network issue
```

**2. Check DNS servers:**
```bash
cat /etc/resolv.conf
# Should list DNS servers (e.g., 8.8.8.8, 1.1.1.1)
```

**3. Test specific DNS server:**
```bash
nslookup api.powerbi.com 8.8.8.8
# Test with Google DNS
```

#### Solutions

**1. Configure DNS servers:**
```bash
# Edit dhcpcd.conf
sudo nano /etc/dhcpcd.conf

# Add at end:
static domain_name_servers=8.8.8.8 8.8.4.4

# Save and restart
sudo systemctl restart dhcpcd
```

**2. Use Google DNS:**
```bash
# Temporary (until reboot)
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Permanent - use dhcpcd.conf method above
```

**3. Flush DNS cache:**
```bash
sudo systemd-resolve --flush-caches
# or
sudo service nscd restart
```

---

## WiFi Range Problems

### Issue: Weak WiFi Signal

**Symptoms:**
- Intermittent disconnects
- Slow performance
- High packet loss
- Poor signal strength

#### Diagnosis

**1. Check signal strength:**
```bash
iwconfig wlan0 | grep "Signal level"

# Excellent: -30 to -50 dBm
# Good:      -50 to -60 dBm
# Fair:      -60 to -70 dBm
# Poor:      -70 to -80 dBm
# Very poor: -80 to -90 dBm
```

**2. Check link quality:**
```bash
iwconfig wlan0 | grep "Link Quality"
# Should be >40/70
```

**3. Test packet loss:**
```bash
ping -c 100 8.8.8.8
# Check packet loss %
# 0-1%: Excellent
# 1-5%: Acceptable
# >5%: Poor
```

**4. Check WiFi frequency:**
```bash
iwconfig wlan0 | grep "Frequency"
# Pi Zero 2 W: 2.4GHz only
# Pi 4/5: 2.4GHz or 5GHz
```

#### Solutions

**1. Move closer to router:**
- Reduce distance
- Remove obstacles (walls, metal)
- Clear line of sight if possible

**2. Use WiFi extender:**
- Place between router and Pi
- Extends range by 50-100 feet
- Cost: $20-40

**3. Change WiFi channel:**
```bash
# Router admin panel
# 2.4GHz: Use channels 1, 6, or 11
# Avoid auto channel selection
# Use WiFi analyzer app to find best channel
```

**4. Switch to 5GHz (Pi 4/5 only):**
```bash
# Edit wpa_supplicant
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf

network={
    ssid="Your-5GHz-Network"
    psk="password"
    frequency=5  # Prefer 5GHz
}

# Restart WiFi
sudo systemctl restart dhcpcd
```

**5. Use Ethernet (recommended):**
```bash
# Pi Zero 2 W: USB Ethernet adapter ($10-15)
# Pi 4/5: Built-in Gigabit Ethernet
# More reliable than WiFi
# No range issues
```

---

## VLAN / Network Segmentation (Production)

### Issue: Cannot Access Resources on Different VLAN

**Symptoms:**
- Can ping within VLAN but not across VLANs
- Token service on different subnet unreachable
- Firewall rules blocking cross-VLAN traffic

#### Diagnosis

**1. Check IP addressing:**
```bash
# Pi (IoT VLAN)
ip addr show
# Example: 10.100.1.11/24

# Token service (Application VLAN)
# Example: 10.200.1.50/24

# Different VLANs = need routing
```

**2. Test routing:**
```bash
# From Pi, ping token service
ping -c 3 TOKEN-SERVICE-IP

# If fails, check routing
ip route show
```

**3. Check firewall rules:**
```bash
# Need rules allowing:
# 10.100.1.0/24 → 10.200.1.50:3000 (token service)
# 10.100.1.0/24 → Internet (Azure AD, Power BI)
```

#### Solutions

**1. Configure routing:**
```bash
# Add route if needed
sudo ip route add 10.200.1.0/24 via GATEWAY-IP

# Make permanent
sudo nano /etc/dhcpcd.conf
# Add:
static routers=GATEWAY-IP
```

**2. Update firewall rules:**
```bash
# Contact network admin
# Required access:

# From IoT VLAN (10.100.1.0/24):
Allow: → 10.200.1.50:3000 (token service)
Allow: → login.microsoftonline.com:443
Allow: → api.powerbi.com:443
Allow: → app.powerbi.com:443
Allow: → cdn.jsdelivr.net:443
```

**3. Use internal DNS:**
```bash
# Instead of IP address, use hostname
# tokenServiceUrl: "https://beacon-token.internal.company.com/api/embed-token"

# Benefits:
# - IP changes don't break config
# - SSL certificate validation works
# - Easier to manage
```

**4. Document network requirements:**
```bash
# For IT team approval:
Source: IoT VLAN (10.100.1.0/24)
Destinations:
  - Internal token service: :443
  - Azure AD: login.microsoftonline.com:443
  - Power BI API: api.powerbi.com:443
  - Power BI Content: app.powerbi.com:443
  - CDN: cdn.jsdelivr.net:443
Protocol: HTTPS
Justification: BEACON dashboard system
```

---

## Bandwidth / Performance Issues

### Issue: Slow Network Performance

**Symptoms:**
- Long load times
- Laggy display updates
- Timeout errors
- High latency

#### Diagnosis

**1. Test bandwidth:**
```bash
# Install speedtest
sudo apt install speedtest-cli

# Run test
speedtest-cli

# Minimum for BEACON:
# Download: 5 Mbps
# Upload: 1 Mbps
# Latency: <100ms
```

**2. Test latency:**
```bash
ping -c 20 api.powerbi.com
# Check avg latency
# Good: <50ms
# Acceptable: 50-100ms
# Poor: >100ms
```

**3. Check for congestion:**
```bash
# Ping during different times
# Morning, afternoon, evening
# Identify congestion patterns
```

**4. Monitor bandwidth usage:**
```bash
# Install vnstat
sudo apt install vnstat

# Check daily usage
vnstat -d
```

#### Solutions

**1. Use Ethernet:**
- More consistent than WiFi
- Lower latency
- Higher bandwidth
- No interference

**2. Optimize refresh interval:**
```bash
# Reduce bandwidth usage
nano ~/beacon-display/display-client/config.json

{
  "refreshIntervalSeconds": 120  # Instead of 60
}

# 60s: ~144MB/day
# 120s: ~72MB/day (50% reduction)
```

**3. QoS (Quality of Service):**
```bash
# Router admin panel
# Enable QoS
# Prioritize display devices
# Ensure minimum bandwidth allocated
```

**4. Schedule updates during off-peak:**
```bash
# If network congestion is time-based
# Configure refresh to avoid peak hours
# Use token service rate limiting
```

---

## Proxy / Corporate Network Issues

### Issue: Corporate Proxy Blocking Traffic

**Symptoms:**
- Works at home, fails at office
- SSL/TLS errors
- Certificate errors
- Authentication required errors

#### Diagnosis

**1. Check for proxy:**
```bash
echo $http_proxy
echo $https_proxy
# If set, proxy is configured
```

**2. Test without proxy:**
```bash
unset http_proxy
unset https_proxy
curl http://api.powerbi.com
```

**3. Check SSL inspection:**
```bash
# Corporate firewalls may inspect SSL
# Causes certificate errors
curl -v https://api.powerbi.com
# Look for certificate chain
```

#### Solutions

**1. Configure proxy:**
```bash
# Set environment variables
export http_proxy=http://proxy.company.com:8080
export https_proxy=http://proxy.company.com:8080
export no_proxy=localhost,127.0.0.1

# Make permanent
sudo nano /etc/environment
# Add above lines
```

**2. Configure proxy for Node.js:**
```bash
# In token service .env
HTTP_PROXY=http://proxy.company.com:8080
HTTPS_PROXY=http://proxy.company.com:8080
```

**3. Install corporate CA certificate:**
```bash
# Get cert from IT team
# Install on Pi
sudo cp company-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

**4. Work with IT team:**
- Whitelist required URLs
- Disable SSL inspection for BEACON traffic
- Configure proxy authentication
- Document business justification

---

## Internet Connectivity Issues

### Issue: No Internet Access

**Symptoms:**
- Cannot reach Azure AD
- Cannot reach Power BI
- Cannot load CDN resources
- Local network works

#### Diagnosis

**1. Test internet connectivity:**
```bash
ping -c 3 8.8.8.8
# If works: Internet OK, DNS issue
# If fails: No internet
```

**2. Test DNS:**
```bash
ping -c 3 google.com
# If fails after IP ping works: DNS issue
```

**3. Check default gateway:**
```bash
ip route show
# Should show default via GATEWAY-IP
```

**4. Test from laptop:**
```bash
# If laptop has internet but Pi doesn't
# Check Pi-specific settings
```

#### Solutions

**1. Check WiFi connection:**
```bash
iwconfig wlan0
# Should show connected to SSID

# If not connected:
sudo raspi-config
# System Options → Wireless LAN
# Enter SSID and password
```

**2. Restart networking:**
```bash
sudo systemctl restart dhcpcd
# or
sudo systemctl restart networking
```

**3. Check gateway:**
```bash
# If no default route
sudo nano /etc/dhcpcd.conf

# Add:
static routers=GATEWAY-IP
static domain_name_servers=8.8.8.8

# Restart
sudo systemctl restart dhcpcd
```

**4. Check for MAC filtering:**
```bash
# Router may filter by MAC address
# Find Pi MAC address
ip link show wlan0 | grep link

# Add to router's allowed devices
```

---

## Related Documentation

- **[Troubleshooting Overview](README.md)** - Diagnostic approach
- **[Display Client Issues](display-client.md)** - Browser and embed problems
- **[Token Service Issues](token-service.md)** - Authentication problems
- **[Raspberry Pi Issues](raspberry-pi.md)** - Hardware problems
- **[Security Model](../architecture/security-model.md)** - Network security requirements

---

**Last Updated:** 2025-11-30
