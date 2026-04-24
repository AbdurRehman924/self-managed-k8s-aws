# Self-Managed Kubernetes on AWS

> Provisioned and operated a production-grade, self-managed Kubernetes cluster on AWS EC2 — without EKS. Built the full infrastructure from scratch using Terraform, bootstrapped nodes with kubeadm, and deployed a complete cloud-native observability and security stack.

---

## What This Project Demonstrates

- Designing multi-AZ AWS VPC networking (public/private subnets, NAT gateway, IGW)
- Provisioning EC2-based Kubernetes control plane (HA, 3 nodes) and worker nodes behind a Network Load Balancer
- Bootstrapping Kubernetes from scratch using `kubeadm` — containerd runtime, Calico CNI, systemd cgroup driver
- Writing modular Terraform (7 modules: vpc, security-groups, iam, ec2-control-plane, ec2-workers, bastion, load-balancer)
- Securing cluster access via bastion host with SSH ProxyJump
- Deploying production observability: Prometheus + Grafana + Loki + Jaeger
- Implementing service mesh (Istio) with mTLS, canary deployments, circuit breakers, and rate limiting
- GitOps with ArgoCD managing all workloads declaratively
- Runtime security with Falco custom rules and Trivy image scanning
- Backup and disaster recovery with Velero

---

## Architecture

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │     NLB     │  ← Kubernetes API :6443
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │     VPC 10.0.0.0/16     │
              │                         │
              │  Public Subnets         │
              │  ┌─────────────────┐    │
              │  │ Control Plane   │    │
              │  │ 3x t3a.medium   │    │
              │  │ (us-east-1a/b/c)│    │
              │  └─────────────────┘    │
              │  ┌──────────┐           │
              │  │ Bastion  │           │
              │  │ t3a.micro│           │
              │  └──────────┘           │
              │                         │
              │  Private Subnets        │
              │  ┌─────────────────┐    │
              │  │  Worker Nodes   │    │
              │  │  3x t3a.medium  │    │
              │  │ (us-east-1a/b/c)│    │
              │  └─────────────────┘    │
              └─────────────────────────┘
```

**Networking:** 3 public subnets (control plane + bastion) + 3 private subnets (workers) across 3 AZs. Workers reach the internet via NAT gateway. SSH access to all nodes is through the bastion using ProxyJump.

---

## Infrastructure (Terraform)

```
terraform-aws-k8s/
├── main.tf                  # Root module wiring
├── variables.tf
├── outputs.tf
└── modules/
    ├── vpc/                 # VPC, subnets, IGW, NAT, route tables
    ├── security-groups/     # SGs for control-plane, workers, bastion, NLB
    ├── iam/                 # IAM roles + instance profiles for EC2
    ├── ec2-control-plane/   # 3 control plane EC2 instances
    ├── ec2-workers/         # 3 worker EC2 instances
    ├── bastion/             # Bastion host
    └── load-balancer/       # NLB fronting the Kubernetes API
```

```bash
cd terraform-aws-k8s
terraform init
terraform apply -var="key_name=your-key"

# Outputs: bastion IP, control plane IPs, worker IPs, NLB DNS
```

---

## Cluster Bootstrap

After Terraform provisions the EC2 instances, `scripts/bootstrap-nodes.sh` installs the Kubernetes stack on all 6 nodes in parallel over SSH via the bastion:

- Disables swap, loads `overlay` + `br_netfilter` kernel modules
- Configures containerd with systemd cgroup driver
- Installs `kubeadm`, `kubelet`, `kubectl` (v1.29, version-locked)

```bash
./scripts/bootstrap-nodes.sh
# Bootstraps all 6 nodes in parallel, reports per-node status
```

Then initialize the cluster:
```bash
# On first control plane node
kubeadm init --control-plane-endpoint "<NLB_DNS>:6443" \
  --upload-certs --pod-network-cidr=192.168.0.0/16

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Join remaining control plane nodes and workers with kubeadm join
```

---

## Kubernetes Stack

| Layer | Tool | Manifests |
|---|---|---|
| Application | Hipster Shop (11 microservices) | `k8s/applications/` |
| Monitoring | Prometheus + Grafana + Alertmanager | `k8s/monitoring/` |
| Logging | Loki + Promtail | `k8s/logging/` |
| Tracing | Jaeger | `k8s/tracing/` |
| Service Mesh | Istio (mTLS, canary, circuit breaker, rate limit) | `k8s/service-mesh/` |
| Security | Falco (custom rules) + Trivy + Network Policies | `k8s/security/` |
| Autoscaling | HPA + VPA + PDB | `k8s/autoscaling/` |
| Backup | Velero | `k8s/backup/` |
| GitOps | ArgoCD | `k8s/gitops/` + `gitops/applications/` |
| Storage | GP3 StorageClass | `k8s/storage/` |
| Ingress | NGINX Ingress | `k8s/ingress/` |

---

## GitOps with ArgoCD

All workloads are managed declaratively. ArgoCD Application CRDs in `gitops/applications/` point to subdirectories in `k8s/` as their source — any `git push` triggers a sync.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/applications/
```

---

## Cluster Management

```bash
# Start/stop all EC2 instances (cost saving)
./scripts/cluster.sh start
./scripts/cluster.sh stop

# SSH to bastion
ssh -i ~/.ssh/<key>.pem ubuntu@<bastion-ip>

# SSH to control plane via bastion (ProxyJump)
ssh -i ~/.ssh/<key>.pem -J ubuntu@<bastion-ip> ubuntu@<control-plane-private-ip>
```

---

## Key Design Decisions

- **Self-managed over EKS** — full control over the control plane, etcd, and Kubernetes version; deeper understanding of cluster internals
- **HA control plane** — 3 control plane nodes across 3 AZs behind an NLB; etcd quorum survives single-node failure
- **Private workers** — worker nodes have no public IPs; all access is through the bastion or NLB
- **Calico CNI** — BGP-based pod networking with IPIP encapsulation; security groups configured for BGP (port 179) and IPIP (protocol 4)
- **Modular Terraform** — each infrastructure concern is an isolated module with its own variables and outputs
