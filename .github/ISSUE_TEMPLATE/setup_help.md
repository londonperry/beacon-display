---
name: Setup Help
about: Need help getting BEACON running? Ask here!
title: "[SETUP] "
labels: help wanted, question
assignees: ''

---

## 🆘 Setup Issue

I need help with setting up BEACON and have the following issue:

## 📍 Which Setup Phase?

- [ ] **POC** (Laptop version - testing locally)
- [ ] **Pilot** (Pi setup - 10-50 devices)
- [ ] **Production** (Enterprise deployment)

## 🔧 Which Component?

- [ ] Token Service (authentication)
- [ ] Display Client (browser/dashboard)
- [ ] Raspberry Pi deployment
- [ ] Azure AD configuration
- [ ] Power BI workspace setup
- [ ] Other: ___

## 📖 What I've Done

I've completed these steps:

1. ___
2. ___
3. ___

## 🚫 What's Blocking Me

**What step are you stuck on?**

Example: "Step 3 of GETTING-STARTED.md - can't get Azure credentials"

### Error or Issue

Describe what's happening:

```
[Paste error message or describe behavior]
```

## 📋 Environment

- **Phase**: POC / Pilot / Production
- **Component**: Token Service / Display Client / Pi Setup
- **Hardware**: Laptop / Raspberry Pi Zero 2 W / Pi 4 / Other: ___
- **OS**: Windows / macOS / Raspberry Pi OS / Linux / Other: ___
- **Node.js version** (if applicable): ___
- **Browser** (if applicable): Chromium version ___

## 📚 Relevant Documentation

Have you checked these?

- [ ] [GETTING-STARTED.md](../../docs/setup/README.md) - Step-by-step setup guide
- [ ] [TROUBLESHOOTING.md](../../docs/troubleshooting/README.md) - Common issues
- [ ] [ARCHITECTURE.md](../../docs/architecture/README.md) - How it works
- [ ] [README.md](../../README.md) - Quick overview

## 🔍 Diagnostic Info

To help us help you, please run these commands and paste the output:

**For Token Service issues:**
```bash
# In token-service/laptop-version/
npm list
node --version
```

**For Raspberry Pi issues:**
```bash
uname -a
node --version
free -h
vcgencmd measure_temp
```

**For Display Client issues:**
```
Browser console error (F12 in Chromium):
[Paste error]

Browser version:
[Your Chromium version]
```

## ✅ Checklist

- [ ] I've reviewed the relevant documentation
- [ ] I've checked TROUBLESHOOTING.md for similar issues
- [ ] I've provided my environment details
- [ ] I've included error messages or screenshots
