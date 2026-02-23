# Hipster Shop Advanced Cloud-Native Learning Journey

## 🎯 Project Overview
**Mission**: Master production-grade cloud-native technologies through hands-on implementation of a complete enterprise platform.

- **Cluster**: Azure Kubernetes Service (AKS) cluster
- **Learning Philosophy**: Hands-on execution + Real-world scenarios + Progressive complexity
- **Goal**: Build portfolio-ready skills for DevOps/Platform Engineer roles (Entry to Mid-Senior level)
- **Scope**: 11 phases covering essential production technologies (Core + Intermediate)

## ⚠️ IMPORTANT: LEARNING MODE
**YOU execute all commands yourself - AI provides guidance only**
- AI will NOT run commands automatically (unless explicitly asked)
- AI provides: command explanations, context, troubleshooting help, and executes tasks when requested
- YOU run: every single command to build muscle memory
- This is hands-on learning - no shortcuts!

## 🎭 COMMUNICATION STYLE
**Tone**: Quirky and hyping - make learning exciting and energizing!
- Use enthusiastic language that builds momentum
- Celebrate wins (big and small) with genuine excitement
- Keep explanations fun without sacrificing technical accuracy
- Inject personality while maintaining professionalism

## 📊 LEARNING PROGRESS TRACKER

### ✅ PHASE 1: FOUNDATION & INFRASTRUCTURE (Complete)
**Target Skills**: Infrastructure as Code, Kubernetes fundamentals, Package management
**Platform**: Azure AKS (managed Kubernetes)
- [x] Azure CLI and Terraform setup
- [x] Modular Terraform structure created
- [x] Azure subscription and region selection
- [x] AKS cluster deployment with quota optimization
- [x] ACR integration with AKS
- [x] Kubernetes cluster access verification

**Completed Configuration**: 
- Region: Southeast Asia
- VM Size: Standard_B2as_v2 (2 vCPUs, 8 GB RAM)
- Node Count: 2 (optimized for vCPU quota)
- Kubernetes Version: v1.34.2
- ACR: hipstershopacr.azurecr.io

### ✅ PHASE 2: MICROSERVICES DEPLOYMENT (Complete)
**Target Skills**: Container deployment, Service configuration, Kubernetes workloads
- [x] Microservices architecture review
- [x] Kubernetes manifests deployment (11 microservices)
- [x] Service connectivity verification
- [x] LoadBalancer exposure and external access
- [x] End-to-end application testing

**Completed Configuration**:
- Namespace: hipster-shop
- Deployments: 11 microservices (13 pods)
- Services: 11 ClusterIP + 1 LoadBalancer
- External IP: 20.195.32.156
- Application: Fully functional e-commerce platform

### ✅ PHASE 3: OBSERVABILITY & MONITORING (Complete)
**Target Skills**: Metrics collection, Visualization, Alerting, SRE practices
- [x] Prometheus deployment and configuration
- [x] Grafana dashboards and data sources
- [x] Custom dashboard creation (CPU and Memory panels)
- [x] Prometheus metrics querying (PromQL basics)
- [x] Slack webhook integration setup
- [x] AlertManager alert rules deployment (PrometheusRule CRD)
- [x] Alert testing and verification

**Completed Configuration**:
- Namespace: monitoring
- Prometheus: Deployed with 7-day retention, 10GB storage
- Grafana: Accessible at 20.212.91.193 (LoadBalancer)
- AlertManager: Configured with Slack notifications (#hipster-shop channel)
- Custom Dashboard: "Hipster Shop Monitoring" with CPU and Memory panels
- Targets: All monitoring targets UP (kubelet, node-exporter, kube-state-metrics)
- Alert Rules: HighMemoryUsage and PodRestartingTooOften alerts active
- Slack Integration: Verified working with test alert

### ✅ PHASE 4: SECURITY & COMPLIANCE (Complete)
**Target Skills**: Runtime security, Vulnerability management, Policy enforcement
- [x] Falco runtime security monitoring
- [x] Trivy vulnerability scanning and remediation
- [x] Network policies and micro-segmentation
- [x] Pod Security Standards and admission controllers

**Completed Configuration**:
- Namespace: security
- Falco: DaemonSet with 5 custom rules (crypto mining, reverse shells, sensitive files, package managers, suspicious activity)
- Trivy Operator: Continuous vulnerability scanning (found 9 critical CVEs in emailservice)
- Network Policies: 7 policies implementing zero-trust micro-segmentation
- Pod Security Standards: Baseline enforcement on all namespaces
- Alerts Tested: Shell spawning, sensitive file access, package manager execution verified

### ✅ PHASE 5: SERVICE MESH & NETWORKING (Complete)
**Target Skills**: Traffic management, Security policies, Advanced networking
- [x] Istio control plane and data plane setup
- [x] Envoy proxy configuration and sidecar injection
- [x] mTLS enforcement with STRICT and PERMISSIVE modes
- [x] Network policy adjustments for service mesh compatibility
- [x] Service mesh verification and troubleshooting

**Completed Configuration**:
- Namespace: istio-system
- Istio Version: 1.28.3 (demo profile)
- Control Plane: istiod deployed and healthy
- Gateways: istio-ingressgateway and istio-egressgateway operational
- Sidecar Injection: Enabled for hipster-shop namespace (automatic)
- Proxies: 15 total (13 microservices + 2 gateways) all synced
- mTLS: STRICT mode for all backend services, PERMISSIVE for frontend
- Network Policies: Updated to allow Istio control plane and DNS communication
- Pod Security: Changed to privileged enforcement for Istio init containers
- Verification: All services operational with encrypted service-to-service communication

### ✅ PHASE 6: GITOPS & AUTOMATION (Complete)
**Target Skills**: Declarative deployments, CI/CD integration, Automated workflows
- [x] ArgoCD installation and configuration
- [x] Git-based deployment workflows
- [x] ArgoCD application creation with auto-sync
- [x] GitOps workflow testing and verification

**Completed Configuration**:
- Namespace: argocd
- ArgoCD Version: Latest stable
- Access Method: Port-forward (localhost:8080)
- Repository: https://github.com/AbdurRehman924/hipster-shop.git
- Application: hipster-shop (auto-sync enabled)
- Sync Policy: Automated with prune and self-heal
- GitOps Workflow: Verified (scaled frontend 2→3 replicas via Git commit)
- All 12 microservices now managed declaratively through Git

### ✅ PHASE 7: CENTRALIZED LOGGING (Complete)
**Target Skills**: Log aggregation, Analysis, Correlation with metrics
- [x] Loki deployment and configuration
- [x] Promtail DaemonSet deployment with RBAC
- [x] Grafana datasource integration
- [x] Log dashboard creation
- [x] Centralized logging infrastructure operational

**Completed Configuration**:
- Namespace: logging
- Loki: Deployed with 7-day retention (168h), 10GB PVC, WAL enabled at /loki/wal
- Promtail: DaemonSet running on 2 nodes with ClusterRole RBAC permissions
- Grafana Integration: Loki datasource auto-configured via sidecar
- Dashboard: "Hipster Shop Logs" with 6 panels (Log Volume, Error Rate, Warning Rate, Total Rate, Active Pods, Live Logs)
- Storage: BoltDB index with filesystem-based chunks
- Security: Non-root user (10001) with proper fsGroup permissions
- Log Discovery: Kubernetes pod role with CRI pipeline for containerd logs

### ❌ PHASE 8: AUTOSCALING & PERFORMANCE (Not Started)
**Target Skills**: Dynamic scaling, Resource optimization, Performance tuning
- [ ] Horizontal Pod Autoscaling (HPA) implementation
- [ ] Vertical Pod Autoscaling (VPA) and resource right-sizing
- [ ] Cluster Autoscaling and node management
- [ ] Performance testing and capacity planning

### ❌ PHASE 9: ADVANCED TRAFFIC MANAGEMENT (Not Started)
**Target Skills**: Canary deployments, A/B testing, Advanced routing
- [ ] Istio traffic splitting and canary deployments
- [ ] Circuit breakers and fault tolerance
- [ ] Rate limiting and traffic shaping
- [ ] A/B testing and feature flags integration

### ❌ PHASE 10: BACKUP & DISASTER RECOVERY (Not Started)
**Target Skills**: Business continuity, Data protection, Recovery procedures
- [ ] Velero backup and restore setup
- [ ] Database backup strategies and automation
- [ ] Cross-region disaster recovery testing
- [ ] Recovery time and point objectives (RTO/RPO)

### ❌ PHASE 11: DISTRIBUTED TRACING (Not Started)
**Target Skills**: Request tracing, Performance analysis, Debugging microservices
- [ ] Jaeger deployment and configuration
- [ ] OpenTelemetry instrumentation with Istio
- [ ] Trace analysis and performance optimization
- [ ] Correlating traces with metrics and logs

---

## 🎯 PHASE BREAKDOWN: CORE vs INTERMEDIATE

### **CORE PHASES (1-8)** - Essential Production Skills
These phases build the foundation of a production-ready platform:
- Infrastructure, Microservices, Observability, Security, Service Mesh, GitOps, Logging, Autoscaling

**Portfolio Impact**: ⭐⭐⭐⭐⭐ (Must-have for DevOps/Platform roles)

### **INTERMEDIATE PHASES (9-11)** - Advanced Production Skills  
These phases demonstrate advanced operational capabilities:
- Traffic Management, Disaster Recovery, Distributed Tracing

**Portfolio Impact**: ⭐⭐⭐⭐ (Nice-to-have, shows depth)

### **EXCLUDED PHASES** - Advanced/Specialized Topics
The following phases are excluded as they're too advanced for portfolio focus:
- Chaos Engineering (Phase 11 → removed)
- Cost Optimization (Phase 12 → removed)
- Advanced Security (Phase 13 → removed)
- Multi-Environment Setup (Phase 14 → removed)
- CI/CD Integration (Phase 16 → removed)
- Kubernetes Internals & DIY Cluster (Phase 17 → removed)

**Note**: These can be added later for senior-level roles or specialized positions.

## 🎓 LEARNING METHODOLOGY

#### **Session Structure:**
```
1. Quick Review (2 min) - What we built last time
2. Context Setting (3 min) - What we're building today and why
3. Micro-Tasks (45 min) - Hands-on implementation
4. Validation (5 min) - Confirm everything works
5. Knowledge Consolidation (5 min) - Connect to bigger picture
```

#### **Progress Tracking:**
- ✅ Completed tasks marked clearly
- 🔄 In-progress tasks tracked
- ❌ Failed tasks documented with lessons learned
- 📈 Skill progression measured

#### **Mastery Indicators:**
- **Beginner**: Following commands successfully
- **Intermediate**: Understanding why commands work
- **Advanced**: Troubleshooting issues independently
- **Expert**: Optimizing and improving configurations


Each learning session follows this flow:

**1. Context (5 min)**
- What we're building and why it matters
- How it fits into the bigger picture
- Real-world use cases

**2. Implementation (40-50 min)**
- Deploy and configure components
- Hands-on execution of commands with clear explanations:
  - **Command**: The exact command to run
  - **Purpose**: What this command does
  - **Why**: Why this step is necessary
  - **Problem**: What problem does this solves
  - **Advantages**: What advantages does this gives
  - **Best Practices**: What are the best practices
- Troubleshoot issues as they arise

**3. Validation (5-10 min)**
- Verify everything works correctly
- Test key functionality
- Check integration with existing components

**4. Wrap-up (5 min)**
- What we accomplished
- Key takeaways
- What's next in the journey

### **Learning Principles**

**Learn by Doing**
- Execute every command yourself
- No copy-paste without understanding
- Break things and fix them

**Progressive Complexity**
- Start simple, build to advanced
- Each phase builds on previous knowledge
- Master fundamentals before moving forward

**Production Mindset**
- Every setup mirrors real-world deployments
- Learn operational best practices
- Understand the "why" behind each decision

## 🎯 CURRENT STATUS
**Platform State**: Phase 7 complete - Centralized logging infrastructure deployed
**Current Phase**: Phase 8 - Autoscaling & Performance (Ready to start)
**Next Step**: Deploy HPA and VPA for dynamic resource scaling
**Target**: Complete 11 portfolio-ready phases (Core + Intermediate)
**Progress**: 7 of 11 phases complete (64%)

**Session Date**: February 23, 2026
**Infrastructure**: 
- Cluster: Azure AKS (2 nodes, Southeast Asia)
- Microservices: 12 services running at 20.195.32.156 (managed by ArgoCD)
- Monitoring: Prometheus + Grafana + AlertManager fully operational
- Grafana: http://20.212.91.193
- Alerts: Slack integration verified and working
- Security: Falco + Trivy + Network Policies + Pod Security Standards active
- Service Mesh: Istio 1.28.3 with 15 proxies (13 microservices + 2 gateways)
- mTLS: STRICT mode for backend services, PERMISSIVE for frontend
- Network Policies: Adjusted for Istio compatibility
- GitOps: ArgoCD managing all deployments with auto-sync enabled
- ArgoCD UI: https://localhost:8080 (port-forward)
- Logging: Loki + Promtail infrastructure deployed (Grafana datasource configured)

## 🚀 LEARNING ADVANTAGES

**Hands-On Experience**
- Commands become automatic through repetition
- Build troubleshooting skills through real issues
- Gain confidence in production deployments

**Complete Platform Knowledge**
- Understand how all components integrate
- Learn operational best practices
- Build production-ready systems

**Career Advancement**
- Skills equivalent to Senior DevOps/Platform Engineer
- Preparation for CKA, CKAD, CKS certifications
- Real-world experience with enterprise tools

## 📝 SUCCESS METRICS

**Technical Goals:**
- [ ] 11 technology phases completed (Core + Intermediate)
- [ ] Production-grade platform deployed and operational
- [ ] Complete observability stack (metrics + logs + traces)
- [ ] GitOps automation with ArgoCD
- [ ] Service mesh with traffic management
- [ ] Disaster recovery capabilities

**Learning Goals:**
- [ ] Ability to rebuild platform independently
- [ ] Troubleshoot distributed systems issues
- [ ] Implement security best practices
- [ ] Demonstrate production-ready skills for DevOps/Platform roles

**Portfolio Goals:**
- [ ] Comprehensive README with architecture diagrams
- [ ] Document key learnings and challenges overcome
- [ ] Create demo video showcasing platform capabilities
- [ ] Prepare interview talking points for each phase

## 🎖️ CERTIFICATION READINESS

Upon completion, you'll be ready for:
- Certified Kubernetes Administrator (CKA)
- Certified Kubernetes Application Developer (CKAD)
- Certified Kubernetes Security Specialist (CKS)
- Istio Certified Associate (ICA)
- Azure AKS certifications

## 🔄 LEARNING APPROACH

**Execute** → **Understand** → **Optimize** → **Document**

Build hands-on skills with production-grade technologies, understand the "why" behind each component, optimize for real-world scenarios, and document lessons learned.

---
**Current Phase**: Phase 8 - Autoscaling & Performance (Ready to start)
**Target**: Complete 11 portfolio-ready phases for DevOps/Platform Engineer roles
**Timeline**: ~1 week to completion (4 phases remaining)
**Completed**: 7 of 11 phases (64% complete)
