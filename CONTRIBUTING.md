# Contributing to BEACON Display

Thank you for your interest in contributing to BEACON! This is a research and development project, and we welcome contributions from the community. Whether you're fixing bugs, adding features, improving documentation, or helping with deployment scenarios, your help is appreciated.

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ (for token service)
- Raspberry Pi OS (for testing on actual hardware)
- Azure AD tenant and Power BI workspace (for authentication testing)
- Basic understanding of Azure AD, Power BI, and Raspberry Pi

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/londonperry/beacon-display.git
   cd beacon-display
   ```

2. **Follow docs/setup/README.md**
   - Detailed step-by-step setup instructions
   - Three deployment phases: local testing, token service, full integration
   - Estimated time: 6 hours for complete setup

3. **Review documentation**
   - **docs/architecture/README.md** - Understand the system design
   - **docs/troubleshooting/README.md** - Common issues and solutions
   - **docs/deployment/README.md** - Enterprise deployment patterns

## 📋 How to Contribute

### Reporting Bugs

Found a bug? Please [open an issue](https://github.com/londonperry/beacon-display/issues/new?template=bug_report.md) with:

- **Clear title**: Describe the issue in one sentence
- **Detailed description**: What you expected vs. what happened
- **Reproduction steps**: How to reproduce the issue
- **Environment**:
  - Token service or display client?
  - Hardware (laptop, Raspberry Pi Zero 2 W, Pi 4, etc.)
  - OS and Node.js version
- **Logs**: Relevant error messages or logs
- **Screenshots**: If applicable (especially for display client)

### Suggesting Features

Have an idea? Please [open an issue](https://github.com/londonperry/beacon-display/issues/new?template=feature_request.md) with:

- **Clear title**: What feature do you want to add?
- **Use case**: Why do you need this feature?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches you evaluated
- **Context**: How does this fit with POC vs. Production deployment?

### Submitting Code Changes

#### Before You Start

1. **Check existing issues/PRs** - Avoid duplicate work
2. **Discuss significant changes** - Open an issue first for major features
3. **Respect project constraints**:
   - Raspberry Pi Zero 2 W: 512MB RAM limit (keep usage <400MB)
   - Security model: POC (HTTP, local) vs. Production (HTTPS, Key Vault)
   - Minimal dependencies (especially important for Raspberry Pi downloads)

#### Development Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**
   - Keep commits focused and atomic
   - Write clear commit messages explaining "why" not just "what"
   - Reference issue numbers in commits: `git commit -m "Fix token refresh issue (#123)"`

3. **Test your changes**
   - **Token service**: Run `npm test` (if test suite exists)
   - **Display client**: Test in Chromium and on actual Raspberry Pi if possible
   - **Integration**: Test end-to-end (token service → display client)

4. **Follow code style guidelines**
   - JavaScript: ES6+ (no transpilation needed)
   - Comments: Explain "why" not "what"
   - Error messages: User-friendly (especially for display client)
   - Memory/resource concerns: Note constraints in comments

5. **Security checklist** (See [SECURITY.md](SECURITY.md) for details)
   - [ ] No secrets hardcoded in code
   - [ ] No `.env` or `config.json` files committed
   - [ ] Configuration uses environment variables or example files
   - [ ] Appropriate security model for POC vs. Production

6. **Submit a pull request**
   - Use the [pull request template](.github/PULL_REQUEST_TEMPLATE.md)
   - Link related issues
   - Describe testing you performed
   - Note any breaking changes or security implications

#### PR Review Process

- At least one maintainer review required
- Automated tests must pass
- No unresolved conversations

## 📚 Documentation

Documentation is part of the project. If you're improving code, consider improving docs too:

- **README.md** - Quick start and overview
- **docs/setup/README.md** - Step-by-step setup
- **docs/architecture/README.md** - Technical deep dive
- **docs/troubleshooting/README.md** - Common issues
- **docs/deployment/README.md** - Enterprise deployment
- **docs/project/README.md** - Business context
- **Code comments** - Inline documentation

If you notice documentation gaps, please open an issue or submit a PR!

## 🔍 Code Review Guidelines

When reviewing PRs or receiving feedback, consider:

1. **Does it work?** - Does the code solve the stated problem?
2. **Is it secure?** - No hardcoded secrets, proper auth, no injection vulnerabilities
3. **Does it fit constraints?** - Memory, bandwidth, security model (POC vs. Prod)
4. **Is it maintainable?** - Clear code, good comments, follows existing patterns
5. **Is it tested?** - Works in stated environments (laptop, Pi, etc.)

## 🏗️ Project Structure

```
beacon-display/
├── token-service/
│   ├── laptop-version/    # POC - runs on local machine
│   └── cloud-version/     # Production - container-ready
├── display-client/        # HTML/JS - runs in Chromium on Pi
├── raspberry-pi/          # Pi setup scripts and systemd service
├── scripts/              # Deployment and testing scripts
└── docs/                 # Documentation
```

**Where to contribute:**
- **Token service bugs**: `token-service/`
- **Display issues**: `display-client/`
- **Pi deployment**: `raspberry-pi/` and `scripts/`
- **Documentation**: Markdown files in root

## 🧪 Testing

### Testing Approach

**For token service:**
- Test locally with `npm start`
- Verify health endpoint: `curl http://localhost:3000/health`
- Test token generation with actual Power BI credentials

**For display client:**
- Test with public sample config (no credentials needed)
- Test in Chromium browser
- Test refresh behavior and error handling
- If possible, test on actual Raspberry Pi

**For Pi deployment:**
- Test on Pi Zero 2 W if possible
- Verify memory usage: `free -h`
- Check service logs: `sudo journalctl -u beacon-display -n 50`

### No Automated Tests Yet

This project is in POC phase. We don't have automated test infrastructure yet. As we grow, we'll add:
- Unit tests for token service
- Integration tests for full flow
- GitHub Actions CI/CD

Want to help set up testing infrastructure? Please open an issue!

## 🔒 Security Policy

BEACON handles Azure credentials and Power BI authentication. Security is critical.

For comprehensive security information including:
- Threat models and security architecture
- Secret management and rotation procedures
- Vulnerability reporting process
- Network security requirements
- SSH and access control guidelines
- Dependency security

See **[SECURITY.md](SECURITY.md)** for complete security documentation.

## 💬 Community Guidelines

- **Be respectful** - We welcome people of all backgrounds and experience levels
- **Be clear** - Explain your ideas thoroughly
- **Be helpful** - If you see a question you can answer, please help
- **Report issues** - Found a problem? Open an issue and help solve it

## 📝 Commit Message Guidelines

Write clear commit messages:

```
[Brief description of what changed]

[Longer explanation of why, if needed]

Fixes #[issue number] (if applicable)
```

Examples:
- `Fix token refresh timing issue` (simple fix)
- `Add memory usage monitoring to watchdog` (simple feature)
- `Refactor config loader for clarity and testability` (refactoring)

## 🎯 Contribution Areas Needed

We're particularly interested in:

1. **Bug fixes** - Report issues you find, submit fixes
2. **Documentation** - Improve guides, add examples, clarify concepts
3. **Testing infrastructure** - Help set up automated tests
4. **Performance optimization** - Reduce memory usage, improve refresh speed
5. **Raspberry Pi support** - Test on Pi variants, improve compatibility
6. **Deployment automation** - Improve `deploy-to-pi.sh`, add more automation
7. **Enterprise features** - Multi-device management, monitoring, alerting (see docs/deployment/README.md)

## ❓ Questions?

- **Setup help**: See docs/setup/README.md or open an issue
- **Architecture questions**: See docs/architecture/README.md
- **Troubleshooting**: See docs/troubleshooting/README.md
- **Enterprise deployment**: See docs/deployment/README.md

---

**Thank you for contributing to BEACON!** Your work helps make real-time data visibility more accessible and affordable.

Last Updated: 2025-11-14
