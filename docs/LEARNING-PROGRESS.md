# Self-Managed Kubernetes on AWS - Learning Journey

## 🎯 Project Overview
**Mission**: Master production-grade Kubernetes by building a complete cluster from scratch on AWS EC2.

- **Cluster**: Self-managed Kubernetes on AWS EC2 (built with kubeadm)
- **Learning Philosophy**: Build it yourself → Understand deeply → Deploy production workloads
- **Goal**: Land a high-paying DevOps/Platform Engineer role
- **Scope**: 12 phases covering infrastructure + Kubernetes + production technologies

## ⚠️ IMPORTANT: LEARNING MODE
**YOU execute all commands yourself - AI provides guidance only**
- AI will NOT run commands automatically (unless explicitly asked)
- AI provides: command explanations, context, troubleshooting help
- YOU run: every single command to build muscle memory
- This is hands-on learning - no shortcuts!

## 🎭 COMMUNICATION STYLE
**Tone**: Energizing and supportive - make complex topics feel achievable!
- Break down intimidating concepts into bite-sized pieces
- Celebrate every milestone
- Use analogies to explain complex topics
- Keep you motivated through challenging sections

---

## 📊 LEARNING PROGRESS TRACKER

### ✅ PHASE 0: AWS FUNDAMENTALS & SETUP (Complete)
**Target Skills**: AWS CLI, IAM, Billing alerts, Terraform basics
- [x] Install and configure AWS CLI v2
- [x] Set up IAM user with appropriate permissions
- [x] Create billing alerts and budget ($50/month threshold)
- [x] Install Terraform and verify installation
- [x] Understand AWS free tier limits and cost structure

**Completed Configuration**:
- AWS CLI Version: 2.32.9
- AWS Account: 450328359140 (with free credits)
- Region: us-east-1
- Billing Alert: $50/month threshold configured
- Terraform Version: 1.14.1 

---

### ✅ PHASE 1: AWS INFRASTRUCTURE FOUNDATION (Complete)
**Target Skills**: VPC networking, Security groups, EC2 management, Load balancers, IAM roles, Terraform modules
- [x] Create VPC with CIDR 10.0.0.0/16
- [x] Create 3 public subnets across 3 AZs
- [x] Create 3 private subnets across 3 AZs
- [x] Configure Internet Gateway and NAT Gateway
- [x] Create security groups (control plane, workers, bastion, NLB)
- [x] Create IAM roles and instance profiles
- [x] Deploy 3 control plane EC2 instances (t3a.medium)
- [x] Deploy 3 worker EC2 instances (t3a.medium)
- [x] Deploy bastion host (t3a.medium)
- [x] Create Network Load Balancer for Kubernetes API
- [x] Generate SSH key pair for cluster access

**Completed Configuration**:
- Region: us-east-1
- VPC ID: vpc-074d6257e6a881eaf
- Control Plane IPs: 10.0.0.127, 10.0.1.250, 10.0.2.9
- Control Plane Public IPs: 54.160.47.159, 54.210.68.226, 18.212.228.150
- Worker Node IPs: 10.0.10.239, 10.0.11.47, 10.0.12.33
- Bastion IP: 98.80.205.104
- NLB DNS: k8s-self-managed-api-nlb-ce50269e5ea0d11c.elb.us-east-1.amazonaws.com
- Total Resources Created: 43

---

### ✅ PHASE 2: KUBERNETES CLUSTER BOOTSTRAP (Complete)
**Target Skills**: kubeadm, etcd clustering, Certificate management, Container runtime (containerd), CNI plugins (Calico), Cloud provider integration
- [x] Install containerd on all nodes
- [x] Install kubeadm, kubelet, kubectl on all nodes
- [x] Initialize first control plane node with kubeadm
- [x] Install Calico CNI plugin
- [x] Join additional control plane nodes (HA setup)
- [x] Join worker nodes to cluster
- [x] Verify etcd cluster health (3 members)
- [x] Install AWS Cloud Controller Manager
- [x] Install AWS EBS CSI Driver
- [x] Configure kubectl on local machine
- [x] Create default StorageClass (gp3)

**Completed Configuration**:
- Kubernetes Version: v1.29.15
- Control Plane Nodes: ip-10-0-0-127, ip-10-0-1-250, ip-10-0-2-9
- Worker Nodes: ip-10-0-10-239, ip-10-0-11-47, ip-10-0-12-33
- CNI Plugin: Calico v3.27.0 (BGP mode)
- etcd Members: 3 (healthy)
- Cloud Provider: AWS CCM (aws-cloud-controller-manager)
- StorageClass: gp3 (default, encrypted, WaitForFirstConsumer)

**Problems Faced & Solved**:
- ❌ **CCM manifest flag placement**: Added `--cloud-provider=external` before the binary name in kube-apiserver.yaml on node 2 → caused CrashLoopBackOff. Fixed by moving the flag after the binary name.
- ❌ **kubelet config path**: Expected `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` but actual path was `/etc/default/kubelet` on Ubuntu 22.04.
- ❌ **Nodes had no ProviderID**: Adding `--cloud-provider=external` after cluster was already running means existing nodes never got their AWS ProviderID set. Fixed by manually patching all 6 nodes with `kubectl patch node`.
- ❌ **Port 10250 missing from worker SG**: Terraform defined the rule but it wasn't applied in AWS. EBS CSI controller couldn't reach kubelet. Fixed by adding the rule via AWS CLI.
- ❌ **EBS CSI IAM permissions**: Worker role was missing `CreateVolume`, `DeleteVolume`, `CreateTags` and other permissions. Fixed by updating the inline policy.

---

### ✅ PHASE 3: MICROSERVICES DEPLOYMENT (Complete)
**Target Skills**: Kubernetes Deployments, Services, ConfigMaps, Namespaces, Resource quotas
- [x] Create hipster-shop namespace
- [x] Deploy Redis for cart service
- [x] Deploy all 12 microservices
- [x] Create ClusterIP Services for internal communication
- [x] Configure environment variables and service discovery
- [x] Set resource requests and limits
- [x] Verify all pods are running
- [x] Test service-to-service communication

**Completed Configuration**:
- Namespace: hipster-shop
- Microservices Deployed: 12
- Total Pods: 14 (frontend runs 3 replicas)
- Services Created: 13
- Application Status: All Running

---

### ✅ PHASE 4: INGRESS & EXTERNAL ACCESS (Complete)
**Target Skills**: Ingress controllers (NGINX), AWS Cloud Controller Manager, DNS (Route53), TLS certificates (cert-manager)
- [x] Install NGINX Ingress Controller
- [x] Install AWS Cloud Controller Manager (CCM)
- [x] Configure --cloud-provider=external on all 6 nodes
- [x] Patch ProviderIDs on all nodes
- [x] Create Ingress resource for frontend
- [x] Verify NLB creation and healthy targets
- [ ] Configure Route53 DNS (optional)
- [ ] Install cert-manager
- [ ] Configure Let's Encrypt ClusterIssuer
- [ ] Enable TLS for frontend

**Completed Configuration**:
- Ingress Controller: NGINX (ingress-nginx namespace)
- NLB DNS: ab71167c1690e4132be7cec1779c70ee-adc760f004e3f2a9.elb.us-east-1.amazonaws.com
- CCM: aws-cloud-controller-manager (3 pods on control plane nodes)
- Domain Name: -
- TLS Certificate: -
- External Access: ✅ http://ab71167c1690e4132be7cec1779c70ee-adc760f004e3f2a9.elb.us-east-1.amazonaws.com

**Problems Faced & Solved**:
- ❌ **NLB stuck at `<pending>`**: No CCM installed — Kubernetes had no way to call AWS APIs to provision the NLB. Fixed by installing AWS CCM and adding `--cloud-provider=external` to all control plane components and kubelet.
- ❌ **NLB had no targets**: Nodes had no ProviderID so CCM couldn't map K8s nodes to EC2 instances. Fixed by manually patching all 6 nodes with their AWS ProviderID.
- ❌ **App returned 500 / DNS i/o timeout**: After kubelet restarts, Calico BGP routes between nodes broke. Frontend pods on workers couldn't reach CoreDNS on control plane. Fixed by restarting Calico DaemonSet and CoreDNS.
- ❌ **Admission webhook timeout**: NGINX validation webhook blocked ingress creation. Fixed by deleting the `ingress-nginx-admission` ValidatingWebhookConfiguration.

---

### ✅ PHASE 5: OBSERVABILITY & MONITORING (Complete)
**Target Skills**: Prometheus, Grafana, Metrics collection, AlertManager, Custom dashboards, PromQL
- [x] Deploy Prometheus Operator (kube-prometheus-stack)
- [x] Configure ServiceMonitors for applications
- [x] Deploy Grafana with persistent storage
- [x] Deploy AlertManager with persistent storage
- [x] Configure custom alert rules (HighMemoryUsage, PodRestartingTooOften)
- [x] Verify persistent storage (gp3 EBS volumes)
- [ ] Create custom dashboards (CPU, Memory, Network)
- [ ] Set up Slack/email notifications
- [ ] Test alerting workflow

**Completed Configuration**:
- Namespace: monitoring
- Prometheus: prometheus-prometheus-kube-prometheus-prometheus-0 (10Gi gp3)
- Grafana: prometheus-grafana (5Gi gp3), access via port-forward localhost:3000
- AlertManager: alertmanager-prometheus-kube-prometheus-alertmanager-0 (2Gi gp3)
- Dashboards: Default Kubernetes dashboards (200+)
- Alert Rules: 35 default + 2 custom (HighMemoryUsage, PodRestartingTooOften)
- Notification Channel: -

---

### 🔒 PHASE 6: SECURITY & COMPLIANCE
**Target Skills**: Network Policies, RBAC, Pod Security Standards, Falco (runtime security), Trivy (vulnerability scanning)
- [ ] Implement Network Policies (zero-trust model)
- [ ] Configure RBAC roles and service accounts
- [ ] Enable Pod Security Standards (baseline/restricted)
- [ ] Deploy Falco with custom rules
- [ ] Deploy Trivy Operator
- [ ] Scan images for vulnerabilities
- [ ] Remediate critical CVEs
- [ ] Test security policies

**Completed Configuration**:
- Namespace: 
- Network Policies: 
- RBAC Roles: 
- Pod Security: 
- Falco Rules: 
- Trivy Scans: 
- CVEs Remediated: 

---

### 📝 PHASE 7: CENTRALIZED LOGGING
**Target Skills**: Loki, Promtail, Log aggregation, LogQL, Log-based alerts
- [ ] Deploy Loki with persistent storage
- [ ] Deploy Promtail DaemonSet
- [ ] Configure Grafana Loki datasource
- [ ] Create log dashboard (Log Volume, Error Rate, Live Logs)
- [ ] Set up log-based alerts
- [ ] Test log querying with LogQL

**Completed Configuration**:
- Namespace: 
- Loki: 
- Promtail: 
- Grafana Integration: 
- Dashboard: 
- Storage: 
- Log Retention: 

---

### 📈 PHASE 8: AUTOSCALING & PERFORMANCE
**Target Skills**: HPA (Horizontal Pod Autoscaler), VPA (Vertical Pod Autoscaler), Cluster Autoscaler, Pod Disruption Budgets, Resource optimization
- [ ] Deploy Metrics Server
- [ ] Configure HPA for frontend (CPU/Memory thresholds)
- [ ] Configure HPA for backend services
- [ ] Deploy VPA for resource recommendations
- [ ] Install Cluster Autoscaler (AWS ASG integration)
- [ ] Create Pod Disruption Budgets
- [ ] Load test and verify autoscaling
- [ ] Optimize resource requests/limits

**Completed Configuration**:
- Metrics Server: 
- HPA Configured: 
- VPA Configured: 
- Cluster Autoscaler: 
- PDB Created: 
- Scaling Tested: 

---

### 🔄 PHASE 9: GITOPS & AUTOMATION
**Target Skills**: ArgoCD, Git-based deployments, Declarative configuration, Auto-sync, Self-heal
- [ ] Deploy ArgoCD
- [ ] Configure Git repository connection
- [ ] Create ArgoCD Application for hipster-shop
- [ ] Enable auto-sync and self-heal
- [ ] Test GitOps workflow (commit → auto-deploy)
- [ ] Configure ArgoCD notifications
- [ ] Access ArgoCD UI

**Completed Configuration**:
- Namespace: 
- ArgoCD Version: 
- Repository: 
- Applications: 
- Sync Policy: 
- ArgoCD UI: 

---

### 🕸️ PHASE 10: SERVICE MESH (ISTIO)
**Target Skills**: Istio control plane, Envoy sidecars, mTLS, Traffic management, Canary deployments, Circuit breakers, Rate limiting
- [ ] Install Istio control plane
- [ ] Enable sidecar injection for hipster-shop namespace
- [ ] Configure mTLS (STRICT mode)
- [ ] Create Istio Gateway for external traffic
- [ ] Implement canary deployment (90/10 split)
- [ ] Configure circuit breakers
- [ ] Set up rate limiting
- [ ] Test A/B testing with header routing

**Completed Configuration**:
- Namespace: 
- Istio Version: 
- Control Plane: 
- Sidecars Injected: 
- mTLS Mode: 
- Gateway: 
- Traffic Management: 

---

### 🔍 PHASE 11: DISTRIBUTED TRACING
**Target Skills**: Jaeger, OpenTelemetry, Request tracing, Performance analysis, Trace correlation
- [ ] Deploy Jaeger
- [ ] Configure Istio tracing integration
- [ ] Enable trace sampling (100% for learning)
- [ ] Generate test traffic
- [ ] Analyze request traces
- [ ] Correlate traces with metrics and logs
- [ ] Identify performance bottlenecks

**Completed Configuration**:
- Namespace: 
- Jaeger Version: 
- Istio Integration: 
- Sampling Rate: 
- Services Traced: 
- Jaeger UI: 

---

### 💾 PHASE 12: BACKUP & DISASTER RECOVERY
**Target Skills**: Velero, S3 backups, Disaster recovery procedures, RTO/RPO metrics, etcd backup
- [ ] Create S3 bucket for backups
- [ ] Deploy Velero with AWS plugin
- [ ] Configure backup storage location
- [ ] Create manual backup of hipster-shop namespace
- [ ] Schedule automated daily backups
- [ ] Test disaster recovery (delete + restore namespace)
- [ ] Backup etcd cluster separately
- [ ] Document RTO/RPO metrics

**Completed Configuration**:
- Namespace: 
- Velero Version: 
- S3 Bucket: 
- Backup Location: 
- Manual Backup: 
- Scheduled Backup: 
- DR Test: 
- RTO/RPO: 

---

## 🎯 CURRENT STATUS
**Platform State**: Full observability stack running with persistent storage
**Current Phase**: Phase 6 - Security & Compliance
**Next Step**: Implement Network Policies
**Progress**: 5 of 12 phases complete (42%)

**Estimated Time to Complete**: 60-75 hours (8-12 weeks at 2-3 hours/day)

---

## 🚀 LEARNING PATH SUMMARY

**Phase Progression**:
```
Phase 0-2: Build the Cluster (Foundation)
  ↓
Phase 3-4: Deploy Applications (Core Functionality)
  ↓
Phase 5-7: Observability Stack (Production Readiness)
  ↓
Phase 8-9: Automation & Scaling (Operational Excellence)
  ↓
Phase 10-12: Advanced Features (Senior-Level Skills)
```

**Career Readiness**:
- After Phase 4: Junior DevOps Engineer ($80-100k)
- After Phase 7: Mid-Level Platform Engineer ($100-130k)
- After Phase 12: Senior DevOps/Platform Engineer ($130-180k)

**Certifications You'll Be Ready For**:
- ✅ Certified Kubernetes Administrator (CKA)
- ✅ Certified Kubernetes Security Specialist (CKS)
- ✅ AWS Certified Solutions Architect
- ✅ Istio Certified Associate (ICA)

---

## 🎓 WHY SELF-MANAGED KUBERNETES?

**Career Impact**: 🔥🔥🔥🔥🔥
- **Salary Boost**: +$20-40k compared to only knowing managed K8s
- **Deep Understanding**: Know how Kubernetes actually works under the hood
- **Troubleshooting Skills**: Fix issues that stump 90% of engineers
- **Interview Edge**: Stand out from candidates who only used EKS/GKE/AKS
- **Senior-Level Skill**: Most engineers never build K8s from scratch

**What You'll Learn That Others Won't**:
- How control plane components communicate
- etcd cluster management and backup
- Certificate management and PKI
- CNI plugin installation and troubleshooting
- Load balancer integration from scratch
- Cloud provider integration (AWS)

---

## 📝 LEARNING METHODOLOGY

### Session Structure (2-3 hours each):
```
1. Quick Review (5 min) - What we built last time
2. Context Setting (10 min) - What we're building today and why
3. Implementation (90-120 min) - Hands-on execution
4. Validation (15 min) - Test everything works
5. Knowledge Check (10 min) - Solidify understanding
```

### Implementation Approach:
**Deploy and configure components with clear explanations:**
- **Command**: The exact command to run
- **Purpose**: What this command does
- **Why**: Why this step is necessary
- **Problem**: What problem does this solve
- **Advantages**: What advantages does this give
- **Best Practices**: What are the best practices
- Troubleshoot issues as they arise

### Progress Tracking:
- ✅ Completed phases marked clearly
- 🔄 In-progress phases tracked
- ❌ Failed tasks documented with solutions
- 📈 Skill level assessed after each phase

### Mastery Indicators:
- **Beginner**: Following commands successfully
- **Intermediate**: Understanding why commands work
- **Advanced**: Troubleshooting issues independently
- **Expert**: Optimizing and improving configurations

---

## 💰 COST ESTIMATION

**Monthly Cost**: ~$250-300
```
EC2 Instances:
- 3x t3a.medium (control plane): $81/month
- 3x t3a.medium (workers): $81/month
- 1x t3a.micro (bastion): $7/month

Storage (EBS): ~$30/month
Network Load Balancer: ~$16/month
NAT Gateway: ~$32/month
Data Transfer: ~$10/month
```

**Money-Saving Tips**:
- Destroy infrastructure when not learning: `terraform destroy`
- Use Spot instances for worker nodes (50-70% savings)
- Single NAT Gateway instead of 3 (save $64/month)
- Shut down cluster overnight (save ~$6/day)

---

## 📚 RESOURCES

**Official Documentation**:
- Kubernetes: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/
- AWS VPC: https://docs.aws.amazon.com/vpc/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/

**Community**:
- Kubernetes Slack: https://slack.k8s.io/
- r/kubernetes: https://reddit.com/r/kubernetes

---

**Ready to build a production Kubernetes cluster from scratch? Let's start with Phase 0!** 🚀
