# GitHub Repository Setup Checklist

This checklist guides you through the manual GitHub repository settings to complete the open-source setup. All files have been created automatically, but these settings require manual configuration through the GitHub web interface.

**Repository**: https://github.com/londonperry/beacon-display

---

## 📋 Repository Settings

### General Settings
Navigate: **Settings → General**

- [ ] **Repository name**: `beacon-display` ✓ (already set)
- [ ] **Description**: Update to:
  ```
  Open-source, low-cost Power BI dashboard display system using Raspberry Pi
  ```
- [ ] **Website**: Leave blank or add your project website URL (optional)
- [ ] **Visibility**: Public ✓ (already public)
- [ ] **Default branch**: `main` ✓ (already set)

### Topics (Tags)
Navigate: **Settings → General → Topics**

Click "Add topics" and add these tags (help with discoverability):

- [ ] `power-bi`
- [ ] `raspberry-pi`
- [ ] `azure-ad`
- [ ] `dashboard`
- [ ] `iot`
- [ ] `open-source`
- [ ] `embedded-analytics`
- [ ] `automation`

---

## 🔧 Features to Enable

### Issues
Navigate: **Settings → General → Features**

- [ ] ✓ **Issues** - Keep enabled (for bug tracking)

### Discussions
Navigate: **Settings → General → Features**

- [ ] Enable **Discussions** (for community Q&A)
  - Recommended: Yes - helps reduce duplicate issues

### Projects
Navigate: **Settings → General → Features**

- [ ] Consider enabling **Projects** (optional)
  - Useful for: Roadmap tracking, milestone visualization
  - Not critical for POC, but helpful for larger roadmaps

### Wiki
Navigate: **Settings → General → Features**

- [ ] Keep **Wiki** disabled (your markdown docs in repo are sufficient)

---

## 🔐 Branch Protection Rules

Navigate: **Settings → Branches → Branch protection rules → Add rule**

Recommended: Add protection for `main` branch

- **Branch name pattern**: `main`
- [ ] ✓ Require pull request reviews before merging
  - Required approving reviews: `1`
  - [ ] Dismiss stale pull request approvals when new commits are pushed
  - [ ] Require review from code owners
- [ ] ✓ Require status checks to pass before merging
  - Required status checks: Select `CI / lint-and-test` and `CI / documentation`
- [ ] ✓ Include administrators (when fully ready)

**Note**: Don't enforce this immediately - enable once you have active contributors.

---

## 👥 Collaborators & Permissions

Navigate: **Settings → Collaborators and teams**

- [ ] **Add collaborators** (if you have team members)
  - Recommended roles:
    - Maintainers: `Maintain` or `Admin`
    - Contributors: `Push` or `Triage`

---

## 🔔 Notifications

Navigate: **Settings → Notifications**

Optional customizations:

- [ ] Set default branch notification settings
- [ ] Configure team notifications (if applicable)

---

## 📋 Code Owner Files

Create a `.github/CODEOWNERS` file (optional but recommended):

**Location**: `.github/CODEOWNERS`

```
# BEACON Display - Code Owners

# Token Service
/token-service/          @londonperry

# Display Client
/display-client/         @londonperry

# Raspberry Pi
/raspberry-pi/           @londonperry

# Documentation
*.md                     @londonperry

# GitHub configuration
.github/                 @londonperry
```

This file can be created later when you add more maintainers.

---

## 🔐 Security Settings

Navigate: **Settings → Security**

### Dependency Alerts & Updates

- [ ] ✓ Enable **Dependabot alerts** (automatic security alerts)
  - Usually enabled by default
  - Helps catch vulnerable dependencies early

- [ ] ✓ Consider enabling **Dependabot security updates**
  - Auto-creates PRs to fix vulnerable dependencies
  - Useful for POC/production projects

### Secret Scanning

- [ ] ✓ Enable **Secret scanning**
  - Detects hardcoded secrets (API keys, tokens, etc.)
  - Prevents accidental credential leaks

---

## 📊 GitHub Pages (Optional)

Navigate: **Settings → Pages**

You can create a project website:

- [ ] **Source**: GitHub Actions (not critical for now)
- This can be set up later if you want a custom website

---

## 🏷️ GitHub Labels

Navigate: **Issues → Labels** (or **Settings → Labels**)

Default labels are usually sufficient, but consider adding:

- [ ] `good first issue` - For onboarding contributors
- [ ] `help wanted` - For areas needing community help
- [ ] `documentation` - For doc improvements
- [ ] `beginner-friendly` - For easy starter tasks
- [ ] `pi-zero-2w` - For Pi-specific issues
- [ ] `security` - For security-related issues

---

## 📝 GitHub Wikis or Website

Not required - your excellent markdown documentation is better than Wiki.

**Skip this section** - Your docs in the root directory are superior to Wiki.

---

## 🚀 Ready to Publish?

Before you go public with issue discussions and community engagement:

### Pre-Launch Checklist

- [ ] ✓ **LICENSE file** created and present
- [ ] ✓ **CONTRIBUTING.md** created with guidelines
- [ ] ✓ **.github/ISSUE_TEMPLATE/** with bug and feature templates
- [ ] ✓ **.github/PULL_REQUEST_TEMPLATE.md** with PR guidelines
- [ ] ✓ **.github/workflows/ci.yml** with basic CI/CD
- [ ] ✓ **README.md** updated with badges and contribution info
- [ ] ✓ **Documentation** comprehensive and well-organized
- [ ] Description updated on GitHub
- [ ] Topics/tags added
- [ ] Discussions enabled (optional but recommended)
- [ ] Branch protection set up for `main` (optional, can do later)

### Going Live

Once you complete this checklist:

1. **Push all changes to main branch**
   ```bash
   git add .
   git commit -m "Add open source infrastructure (LICENSE, CONTRIBUTING, templates, CI)"
   git push origin main
   ```

2. **Announce on GitHub** (optional)
   - Create a GitHub release
   - Share in relevant communities (Power BI, Raspberry Pi forums)

3. **Monitor and respond to**
   - GitHub Issues (bug reports, features)
   - Pull Requests (community contributions)
   - Discussions (questions and ideas)

---

## ✅ Completion Tracking

Use this table to track your progress:

| Task | Status | Notes |
|------|--------|-------|
| Update repository description | [ ] | |
| Add GitHub topics | [ ] | |
| Enable Discussions | [ ] | |
| Set up branch protection | [ ] | |
| Configure Dependabot | [ ] | |
| Enable secret scanning | [ ] | |
| Push all files to GitHub | [ ] | |
| Test CI/CD pipeline | [ ] | |
| Create first release | [ ] | Optional |

---

## 📞 Questions?

If you need help with any of these settings:

1. **GitHub Help**: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features
2. **CONTRIBUTING.md**: Review for contributor guidelines
3. **GitHub Community**: https://github.com/orgs/community/discussions

---

**Estimated time**: 15-20 minutes to complete all manual settings

**Next step**: Push your changes and watch the CI pipeline run! 🚀
