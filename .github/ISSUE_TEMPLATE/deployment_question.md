---
name: Deployment & Scaling Question
about: Questions about deploying to production, scaling, or enterprise scenarios
title: "[DEPLOYMENT] "
labels: deployment, question
assignees: ''

---

## 🚀 Deployment Question

I'm planning to deploy BEACON and have questions about scaling, production setup, or enterprise deployment:

## 📊 Scale & Scope

How many devices are you planning to deploy?

- [ ] Small (1-10 devices)
- [ ] Medium (10-50 devices)
- [ ] Large (50-100+ devices)
- [ ] Enterprise (100+ with centralized management)

## 🏢 Deployment Environment

- [ ] Home / Small office (personal WiFi)
- [ ] Corporate office (company network)
- [ ] Multi-location / Multi-store
- [ ] Hybrid setup (on-prem + cloud)

## ❓ Your Question

Please describe your deployment scenario and question:

### Current Setup
- Token Service deployment: POC (laptop) / Pilot (VPS) / Production (enterprise)
- Estimated device count: ___
- Target rollout timeline: ___

### What I Need to Know

Example questions:
- "How do I scale token service to 100 devices?"
- "What's the total cost for 50 devices?"
- "Should I use cloud or on-prem token service?"
- "How do I manage devices across multiple locations?"
- "What infrastructure do I need?"

**Your specific question:**

```
[Describe your deployment scenario and question]
```

## 🔒 Security & Compliance

Do you have special security or compliance requirements?

- [ ] None - Standard POC/Pilot setup
- [ ] HTTPS required for token service
- [ ] Enterprise authentication (LDAP/AD integration)
- [ ] Network segmentation (IoT VLAN)
- [ ] Data residency requirements
- [ ] Audit logging
- [ ] Other: ___

## 💰 Cost Constraints

What's your budget/cost target?

- [ ] $50/device (minimum viable - Pi Zero 2 W)
- [ ] $75-100/device (balanced - Pi 4)
- [ ] $150+/device (premium features/support)
- [ ] Flexible - optimizing for features/performance

## 📚 Relevant Documentation

Have you reviewed these?

- [ ] [DEPLOYMENT.md](../../docs/deployment/README.md) - Enterprise deployment guide (cost models, scaling strategies)
- [ ] [ARCHITECTURE.md](../../docs/architecture/README.md) - System design and component interaction
- [ ] [GETTING-STARTED.md](../../docs/setup/README.md) - POC setup (foundation for scaling)
- [ ] [TROUBLESHOOTING.md](../../docs/troubleshooting/README.md) - Performance and optimization tips

## 🎯 Your Scenario

Help us understand your use case:

**What are the displays for?**

- [ ] Business metrics / KPIs
- [ ] Real-time data dashboards
- [ ] Operational monitoring
- [ ] Store performance metrics
- [ ] Other: ___

**Who manages the displays?**

- [ ] You (centralized management)
- [ ] Distributed (store managers)
- [ ] Mix of both
- [ ] Fully automated

**What's the critical success factor?**

- [ ] Cost (lowest possible)
- [ ] Reliability (99.9% uptime)
- [ ] Ease of management
- [ ] Feature richness
- [ ] Security/Compliance
- [ ] Other: ___

## 📞 Context

- **Timeline**: When do you need this deployed? ___
- **Team size**: How many people managing this? ___
- **IT support**: What IT support do you have? ___

## ✅ Checklist

- [ ] I've read [DEPLOYMENT.md](../../docs/deployment/README.md)
- [ ] I've reviewed [ARCHITECTURE.md](../../docs/architecture/README.md) to understand the system
- [ ] I understand the cost models and scaling strategies
- [ ] I've provided details about my deployment scenario
- [ ] I've mentioned any special security requirements
