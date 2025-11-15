# BEACON Security Pre-Commit Checklist

**Use this checklist before every commit to prevent security vulnerabilities.**

---

## 🚨 CRITICAL - Never Commit These

**Stop and verify IMMEDIATELY before committing:**

- [ ] **No `.env` files** - Only commit `.env.example` templates
- [ ] **No `config.json` files** - Only commit `config.json.example` templates
- [ ] **No hardcoded secrets** - No API keys, passwords, tokens, or credentials in code
- [ ] **No Azure credentials** - No TENANT_ID, CLIENT_ID, CLIENT_SECRET values
- [ ] **No Power BI IDs** - No actual workspace IDs or report IDs (use placeholders)
- [ ] **No IP addresses** - No production IP addresses or domain names
- [ ] **No private keys** - No SSH keys, SSL certificates, or encryption keys
- [ ] **No test accounts** - No real usernames, emails, or passwords

### Quick Security Scan

Run these commands before committing:

```bash
# Check for common secrets in staged files
git diff --cached | grep -iE "(password|secret|api[_-]?key|token|tenant[_-]?id|client[_-]?id)" && echo "⚠️  WARNING: Possible secret detected!"

# Check for .env files
git status | grep "\.env$" && echo "❌ STOP: Do not commit .env files!"

# Check for config.json files
git status | grep "config\.json$" && echo "❌ STOP: Do not commit config.json files!"
```

---

## 📋 Code Quality Checks

### Token Service (Node.js)

**Before committing changes to `token-service/`:**

- [ ] Environment variables validated at startup
- [ ] Error messages don't leak sensitive info (stack traces, credentials)
- [ ] Logging doesn't include secrets (redact CLIENT_SECRET, tokens)
- [ ] No hardcoded URLs or endpoints
- [ ] Dependencies up to date (`npm audit` shows no critical issues)
- [ ] Security headers configured (CSP, X-Frame-Options, etc.)
- [ ] CORS properly configured (not `*` in production)
- [ ] HTTPS enforced in production (HSTS header)
- [ ] Input validation on all POST endpoints
- [ ] Rate limiting considered for production

**Test token service locally:**

```bash
cd token-service/laptop-version
npm audit                                    # Check for vulnerabilities
npm run health-check                         # Verify service runs
curl -X POST http://localhost:3000/api/fake  # Test 404 handler
curl http://localhost:3000/health            # Test health endpoint
```

### Display Client (HTML/JavaScript)

**Before committing changes to `display-client/`:**

- [ ] No inline secrets in HTML/JavaScript
- [ ] External scripts loaded from trusted CDNs only
- [ ] Error messages user-friendly (no technical details)
- [ ] Config loaded from `config.json` (not hardcoded)
- [ ] Token refresh logic works correctly
- [ ] Network errors handled gracefully
- [ ] No console.log() with sensitive data in production code
- [ ] Subresource Integrity (SRI) hashes for CDN scripts (optional but recommended)

**Test display client locally:**

```bash
cd display-client
# Open index.html in browser
# Check browser console for errors
# Test with invalid config to verify error handling
```

### Raspberry Pi Scripts

**Before committing changes to `raspberry-pi/`:**

- [ ] No hardcoded WiFi passwords or credentials
- [ ] Scripts use relative paths (not absolute `/home/pi/...`)
- [ ] Error handling for network failures
- [ ] Logging doesn't include secrets
- [ ] Scripts tested on actual Raspberry Pi OS
- [ ] File permissions correct (install.sh should be executable)
- [ ] Watchdog thresholds documented and reasonable

**Test Pi scripts locally:**

```bash
cd raspberry-pi
shellcheck install.sh           # Check for shell script issues
shellcheck start-display.sh
shellcheck watchdog.sh
bash -n install.sh              # Check syntax without executing
```

---

## 🔒 File-Specific Checks

### .gitignore

**Verify `.gitignore` blocks sensitive files:**

```bash
# Test that .env is ignored
touch .env && git status | grep "\.env" && echo "❌ .env is NOT ignored!"

# Test that config.json is ignored (display-client)
touch display-client/config.json && git status | grep "config\.json" && echo "❌ config.json is NOT ignored!"

# Clean up test files
rm -f .env display-client/config.json
```

**Required `.gitignore` entries:**

```
# Secrets and configuration
.env
*.env
config.json
!config.json.example
!config-public-sample.json

# Node.js
node_modules/
npm-debug.log
package-lock.json

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/
```

### .env.example files

**Verify example files have no real secrets:**

- [ ] `token-service/laptop-version/.env.example` - All values are placeholders
- [ ] `token-service/cloud-version/.env.example` - All values are placeholders
- [ ] No actual TENANT_ID, CLIENT_ID, CLIENT_SECRET values
- [ ] Instructions clear for how to get real values
- [ ] Warnings about secret rotation and expiration

### config.json.example files

**Verify example files have no real data:**

- [ ] `display-client/config.json.example` - All IDs are placeholders
- [ ] No actual workspace IDs or report IDs
- [ ] No production IP addresses or domain names
- [ ] Instructions reference GETTING-STARTED.md
- [ ] Public sample (config-public-sample.json) uses public Power BI report

---

## 🌐 Network Security

**For POC/Development (Laptop Version):**

- [ ] HTTP acceptable for local network only
- [ ] Token service runs on localhost or local network IP
- [ ] CORS allows Pi IPs (not wildcard in production)
- [ ] No external access to token service

**For Production (Cloud Version):**

- [ ] HTTPS required (enforce with HSTS header)
- [ ] Valid SSL/TLS certificate configured
- [ ] CORS restricted to specific display IPs/domains
- [ ] Firewall rules documented
- [ ] Network segmentation (IoT VLAN) recommended
- [ ] Secrets in Key Vault or Secrets Manager (not .env)
- [ ] Monitoring and alerting configured

---

## 📦 Dependencies Security

**Check for vulnerable dependencies:**

```bash
# Token service
cd token-service/laptop-version && npm audit
cd token-service/cloud-version && npm audit

# If vulnerabilities found:
npm audit fix              # Auto-fix if possible
npm audit fix --force      # Force update breaking changes (test thoroughly!)
npm outdated               # Check for outdated packages
```

**Update dependencies regularly:**

- [ ] Review `npm audit` output before committing
- [ ] No critical or high severity vulnerabilities
- [ ] Test after updating dependencies
- [ ] Document breaking changes in commit message

---

## 🧪 Testing Checklist

**Before committing, verify:**

- [ ] Code runs without errors locally
- [ ] Token service starts and responds to health check
- [ ] Display client loads without console errors
- [ ] Error handling works (test with invalid config)
- [ ] Changes don't break existing functionality
- [ ] Documentation updated for new features
- [ ] Comments explain "why" not "what"

**Test commands:**

```bash
# Token service
cd token-service/laptop-version
npm install && npm start
# In another terminal:
curl http://localhost:3000/health

# Display client
cd display-client
# Open index.html in browser, check console

# Raspberry Pi scripts (if applicable)
cd raspberry-pi
bash -n *.sh  # Syntax check
```

---

## 📝 Documentation Checks

**Update documentation when code changes:**

- [ ] README.md reflects current setup steps
- [ ] ARCHITECTURE.md updated if system design changed
- [ ] TROUBLESHOOTING.md includes new error scenarios
- [ ] DEPLOYMENT.md updated for production changes
- [ ] Code comments explain complex logic
- [ ] API endpoints documented (if new endpoints added)
- [ ] Environment variables documented in .env.example

---

## 🚀 Pre-Commit Commands

**Run this checklist script before every commit:**

```bash
#!/bin/bash
# Save as: scripts/pre-commit-check.sh

echo "🔍 BEACON Security Pre-Commit Check"
echo "======================================"

# Check for .env files
if git status --porcelain | grep -q "\.env$"; then
    echo "❌ FAIL: .env file detected in commit!"
    echo "   Remove .env from staging: git reset HEAD .env"
    exit 1
fi

# Check for config.json (not examples)
if git status --porcelain | grep -q "config\.json$" | grep -v "example"; then
    echo "❌ FAIL: config.json file detected in commit!"
    echo "   Remove config.json from staging"
    exit 1
fi

# Check for common secrets in staged files
if git diff --cached | grep -iE "(password|secret|api[_-]?key|token).*[:=].*['\"][a-zA-Z0-9]{20,}"; then
    echo "⚠️  WARNING: Possible secret detected in staged files!"
    echo "   Review changes carefully before committing"
    exit 1
fi

# Run npm audit on token services
echo "📦 Checking dependencies..."
cd token-service/laptop-version
if npm audit --audit-level=high | grep -q "high"; then
    echo "⚠️  WARNING: High severity vulnerabilities found!"
    echo "   Run: npm audit fix"
fi

echo "✅ Pre-commit checks passed!"
echo ""
echo "Remember to:"
echo "  - Review all changes in git diff"
echo "  - Test locally before pushing"
echo "  - Update documentation if needed"
```

**To use:**

```bash
chmod +x scripts/pre-commit-check.sh
./scripts/pre-commit-check.sh
```

---

## 🔐 Security Best Practices

### POC/Development Phase

**Acceptable for testing:**

- ✅ HTTP for local token service
- ✅ Secrets in .env file (NEVER commit)
- ✅ CORS wildcard (*) for development
- ✅ Password-based SSH to Pi (initial setup)
- ✅ Detailed error messages for debugging

### Production Deployment

**Required for production:**

- ✅ HTTPS with valid certificate
- ✅ Secrets in Azure Key Vault or AWS Secrets Manager
- ✅ CORS restricted to specific origins
- ✅ Key-based SSH only
- ✅ Generic error messages (no stack traces)
- ✅ Network segmentation (IoT VLAN)
- ✅ Monitoring and alerting
- ✅ Regular secret rotation (every 3-6 months)
- ✅ Audit logging enabled
- ✅ Rate limiting on API endpoints

---

## 🐛 Common Security Mistakes

**Avoid these common pitfalls:**

❌ **Committing .env file**
```bash
# Wrong:
git add .env

# Right:
git add .env.example
```

❌ **Hardcoding secrets in code**
```javascript
// Wrong:
const clientSecret = "abc123secret456";

// Right:
const clientSecret = process.env.CLIENT_SECRET;
```

❌ **Exposing stack traces in production**
```javascript
// Wrong:
res.status(500).json({ error: err.stack });

// Right:
res.status(500).json({
    error: process.env.NODE_ENV === 'production'
        ? 'Internal server error'
        : err.message
});
```

❌ **Using wildcard CORS in production**
```javascript
// Wrong (production):
app.use(cors({ origin: '*' }));

// Right (production):
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS.split(',')
}));
```

❌ **Logging secrets**
```javascript
// Wrong:
console.log('Token:', accessToken);

// Right:
console.log('Token acquired successfully');
```

---

## 📞 Security Incident Response

**If you accidentally commit a secret:**

1. **Immediately rotate the secret:**
   - Azure: Create new client secret, delete old one
   - Power BI: Update service principal credentials
   - SSH: Generate new key pair

2. **Remove from git history:**
   ```bash
   # If not yet pushed:
   git reset HEAD~1                    # Undo commit
   git add .gitignore .env.example     # Stage correct files
   git commit -m "Add env template"    # Recommit

   # If already pushed (DANGEROUS - rewrites history):
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   git push --force --all
   ```

3. **Notify team:**
   - Inform stakeholders
   - Document incident
   - Update security procedures

4. **Verify rotation:**
   - Test with new credentials
   - Confirm old credentials revoked
   - Update all deployments

---

## ✅ Final Checklist

**Before running `git commit`, confirm:**

- [ ] I have reviewed all changes in `git diff`
- [ ] I have run the pre-commit security checks
- [ ] No secrets, credentials, or sensitive data in commit
- [ ] All tests pass locally
- [ ] Dependencies have no critical vulnerabilities
- [ ] Documentation is updated
- [ ] Commit message is clear and descriptive
- [ ] I understand the security implications of these changes

**If all boxes are checked, proceed with:**

```bash
git add <files>
git commit -m "Descriptive commit message"
git push
```

---

**Last Updated:** Auto-updated on git commit
**Maintainer:** BEACON Security Team

**Questions or concerns?** Review SECURITY.md or contact your security team.
