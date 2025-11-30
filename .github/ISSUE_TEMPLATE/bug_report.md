---
name: Bug Report
about: Report a bug to help us improve BEACON
title: "[BUG] "
labels: bug
assignees: ''

---

## 🐛 Describe the Bug

A clear and concise description of what the bug is.

## 🔄 Steps to Reproduce

Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## 🤔 Expected Behavior

What you expected to happen.

## 🖼️ Screenshots

If applicable, add screenshots to help explain your problem.

## 📋 Environment

Please provide relevant environment details:

- **Component**: Token Service / Display Client / Raspberry Pi Setup
- **Hardware**: Raspberry Pi Zero 2 W / Pi 4 / Laptop / Other: ___
- **OS**: Raspberry Pi OS / Ubuntu / macOS / Windows / Other: ___
- **Node.js version** (if applicable): ___
- **Browser** (if applicable): Chromium version ___
- **Deployment Phase**: POC / Pilot / Production

## 📝 Error Messages

Paste any relevant error messages or logs:

```
[Paste error here]
```

For Raspberry Pi logs:
```bash
sudo journalctl -u beacon-display -n 50
```

For token service logs:
```
[Paste terminal output]
```

For display client errors (F12 in Chromium):
```
[Paste browser console output]
```

## 🔍 Additional Context

Add any other context about the problem here.

- Have you reviewed the troubleshooting guide?
- Is this blocking your deployment?
- Are you following POC or Production setup?

---

**Checklist before submitting:**
- [ ] I've checked [TROUBLESHOOTING.md](../../docs/troubleshooting/README.md)
- [ ] I've reviewed similar existing issues
- [ ] I've provided relevant logs or error messages
- [ ] I've specified my environment details
