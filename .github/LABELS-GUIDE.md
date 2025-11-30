# BEACON GitHub Labels Guide

This guide explains the labels used in the BEACON Display project to organize and categorize issues and pull requests.

## Quick Setup

To automatically create these labels in your GitHub repository:

```bash
./scripts/setup-github-labels.sh <owner> <repo>

# Example:
./scripts/setup-github-labels.sh londonperry beacon-display
```

**Requirements**:
- GitHub CLI (`gh`) - Install from https://cli.github.com
- Authenticated with GitHub (`gh auth login`)

---

## Label Categories

### 🏷️ Type Labels
Used to classify the nature of the issue or PR.

| Label | Description | Use When |
|-------|-------------|----------|
| `bug` | Something isn't working | Reporting a defect or issue |
| `enhancement` | Feature request | Proposing a new feature |
| `documentation` | Docs improvements | Updating guides, README, etc. |
| `question` | Information requested | Asking for clarification |
| `chore` | Maintenance tasks | Dependency updates, cleanup |
| `refactoring` | Code improvements | Refactoring without new features |

### 🔧 Component Labels
Identify which part of the system is affected.

| Label | Description | Examples |
|-------|-------------|----------|
| `component: token-service` | Authentication service | Azure AD, token generation |
| `component: display-client` | Browser/dashboard | UI, Power BI embed, config |
| `component: raspberry-pi` | Pi deployment | Installation, systemd, scripts |
| `component: azure-ad` | Azure integration | Authentication, credentials |
| `component: power-bi` | Power BI integration | Reports, embeddings, workspace |

### 📊 Deployment Phase Labels
Indicate which deployment phase is affected.

| Label | Description | Use For |
|-------|-------------|---------|
| `phase: poc` | Proof of Concept | Local laptop setup, testing |
| `phase: pilot` | Pilot rollout | 10-50 device deployment |
| `phase: production` | Enterprise deployment | 100+ devices, scaling |

### 🎯 Priority Labels
Indicate urgency and importance.

| Label | Priority | Handling |
|-------|----------|----------|
| `priority: critical` | ⚠️ URGENT | Blocking, security, data loss |
| `priority: high` | 🔴 Important | Should be in next release |
| `priority: medium` | 🟡 Normal | Regular priority |
| `priority: low` | 🟢 Optional | Nice-to-have features |

**Assigning Priority**:
- **Critical**: Blocks deployment, security vulnerability, data loss
- **High**: Feature needed for next phase, important bug
- **Medium**: Standard feature or bug fix
- **Low**: Polish, documentation, future ideas

### 📈 Status Labels
Track the current state of an issue or PR.

| Label | Meaning | Action |
|-------|---------|--------|
| `status: blocked` | Waiting for external dependency | @mention blocker, track progress |
| `status: in-progress` | Currently being worked on | Assign to developer |
| `status: review-needed` | Waiting for code review | Assign reviewer |
| `status: help-needed` | Need community assistance | Ask for specific help |

### 👥 Difficulty Labels (Onboarding)
Help new contributors find good starting points.

| Label | Description | Ideal For |
|--------|-------------|-----------|
| `good-first-issue` | Great for newcomers | First-time contributors |
| `help-wanted` | Extra attention needed | Community involvement |
| `beginner-friendly` | Low barrier to entry | Learning tasks |
| `documentation-only` | Docs improvements | Writers, no coding |

### 🔌 Hardware/Environment Labels
Track hardware-specific issues and constraints.

| Label | Meaning | Use When |
|-------|---------|----------|
| `hardware: pi-zero-2w` | Tested on Pi Zero 2 W | Memory/performance on 512MB |
| `hardware: pi-4` | Tested on Pi 4 | Features needing more resources |
| `hardware: laptop` | Tested on desktop | POC testing, development |
| `environment: wifi-limited` | 2.4GHz WiFi affected | WiFi range/connectivity issue |
| `environment: memory-constrained` | Memory optimization needed | <400MB RAM concerns |

### 🔒 Security Labels
Security-related issues and review needs.

| Label | Meaning | Priority |
|-------|---------|----------|
| `security` | Security-related | High |
| `security-review-needed` | Needs security review | Before merge |

### 🧪 Testing Labels
Track testing status and coverage.

| Label | Meaning | Next Step |
|-------|---------|-----------|
| `test-coverage` | Needs tests | Add unit/integration tests |
| `tested: manual` | Manually verified | Can add automated tests |
| `tested: automated` | Has automated tests | Good to merge |

### 🌐 Community Labels
Manage community feedback and external issues.

| Label | Meaning | Usage |
|-------|---------|-------|
| `bug-confirmed` | Bug is verified | Ready to be worked on |
| `upstream` | From upstream dependency | May need vendor involvement |
| `wontfix` | Not planned | Close and explain why |

---

## Labeling Best Practices

### For Issues

1. **Always add a Type label**: `bug`, `enhancement`, `documentation`, or `question`
2. **Add Component label(s)**: What part of the system? Can have multiple
3. **Add Phase label**: `phase: poc`, `phase: pilot`, or `phase: production`
4. **Set Priority**: For bugs and important features
5. **Add Status**: `status: in-progress` when someone starts working on it
6. **Add Hardware label**: If hardware-specific (Pi Zero vs Pi 4)

**Example**:
- Bug report for Pi Zero 2W: `bug`, `component: display-client`, `hardware: pi-zero-2w`, `priority: high`
- Feature request: `enhancement`, `component: token-service`, `phase: production`, `priority: medium`
- Setup help: `question`, `phase: poc`, `help-wanted`, `beginner-friendly`

### For Pull Requests

1. **Add Type label**: What does this PR do? (`bug`, `enhancement`, `refactoring`)
2. **Add Component label(s)**: Which parts changed?
3. **Add Status**: Update to `status: review-needed` when ready
4. **Add Testing label**: `tested: manual` or `tested: automated`
5. **Security**: Add `security-review-needed` if security-relevant

**Example**:
- Fix for Pi memory issue: `bug`, `component: display-client`, `hardware: pi-zero-2w`, `tested: manual`
- New feature: `enhancement`, `component: token-service`, `tested: automated`

---

## Workflow Examples

### Onboarding a New Contributor
```
1. Find issues with: good-first-issue OR beginner-friendly
2. Assign to contributor
3. Add: component, priority
4. Add: status: in-progress when they start
```

### Triage New Issues
```
1. Add Type: bug, enhancement, question, documentation
2. Add Component: which part affected?
3. Add Priority: critical, high, medium, low
4. Add Phase: poc, pilot, production
5. Assign if ready to start
```

### Track a Bug Fix
```
1. bug label (type)
2. component label (which part)
3. priority label (how urgent)
4. status: in-progress (when assigned)
5. tested: manual/automated (when testing done)
6. Remove status labels when merged
```

### Plan a Feature Release
```
Filter: phase:production + priority:high + type:enhancement
See all high-priority features needed for production rollout
```

---

## Label Maintenance

### Reviewing Labels Periodically
- Visit: https://github.com/{owner}/{repo}/labels
- Remove unused labels
- Update colors/descriptions as needed
- Add new labels as project evolves

### Adding New Labels
```bash
gh label create "my-label" \
  --repo="owner/repo" \
  --description="Description here" \
  --color="hexcolor"
```

### Deleting Unused Labels
```bash
gh label delete "my-label" --repo="owner/repo"
```

---

## Quick Reference

**View issues by label**:
- https://github.com/{owner}/{repo}/issues?labels=good-first-issue
- https://github.com/{owner}/{repo}/issues?labels=phase:production
- https://github.com/{owner}/{repo}/issues?labels=priority:critical

**Filter multiple labels**:
- https://github.com/{owner}/{repo}/issues?labels=bug,component:token-service,priority:high

---

## Label Statistics

Run this to see label usage:
```bash
gh label list --repo=owner/repo --limit=100
```

---

**For questions about specific labels, check**:
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [GETTING-STARTED.md](../docs/setup/README.md) - Setup guide
- GitHub repository > Issues > Labels
