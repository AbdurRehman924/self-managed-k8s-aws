# Self-Managed Kubernetes on AWS

A self-managed Kubernetes cluster on AWS EC2 — built without EKS. Infrastructure provisioned with Terraform, nodes bootstrapped with kubeadm, and a full cloud-native stack deployed on top.

---

## Project Structure

```
self-managed-k8s-aws/
├── terraform-aws-k8s/
│   ├── main.tf                  # Root module wiring
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── vpc/                 # VPC, subnets, IGW, NAT, route tables
│       ├── security-groups/     # SGs for control-plane, workers, bastion, NLB
│       ├── iam/                 # IAM roles + instance profiles
│       ├── ec2-control-plane/   # 3 control plane EC2 instances
│       ├── ec2-workers/         # 3 worker EC2 instances
│       ├── bastion/             # Bastion host (SSH jump server)
│       └── load-balancer/       # NLB fronting the Kubernetes API
├── k8s/
│   ├── applications/hipster-shop/ # 11 microservice manifests
│   ├── monitoring/              # Prometheus + Alertmanager
│   ├── logging/                 # Loki + Promtail
│   ├── service-mesh/            # Istio + traffic management
│   ├── security/                # Falco, Trivy, Network Policies
│   ├── autoscaling/             # HPA, VPA, PDB
│   ├── backup/                  # Velero
│   ├── tracing/                 # Jaeger
│   ├── storage/                 # GP3 StorageClass
│   ├── ingress/                 # NGINX Ingress
│   └── gitops/                  # ArgoCD app manifest
├── gitops/applications/         # ArgoCD Application CRDs
├── scripts/
│   ├── bootstrap-nodes.sh       # Install kubeadm/kubelet/kubectl on all nodes
│   └── cluster.sh               # Start/stop EC2 instances
└── docs/
    ├── PROGRESS.md
    └── Traffic-flow.md
```

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

3 public subnets (control plane + bastion) + 3 private subnets (workers) across 3 AZs. Workers reach the internet via NAT gateway. All SSH access goes through the bastion using ProxyJump.

---

## Infrastructure

```bash
cd terraform-aws-k8s
terraform init
terraform apply -var="key_name=your-key"
```

Outputs: bastion public IP, control plane private IPs, worker private IPs, NLB DNS name.

---

## Cluster Bootstrap

`scripts/bootstrap-nodes.sh` SSHs into all 6 nodes in parallel via the bastion and installs the full Kubernetes stack:

- Disables swap, loads `overlay` + `br_netfilter` kernel modules
- Configures containerd with systemd cgroup driver
- Installs `kubeadm`, `kubelet`, `kubectl` v1.29 (version-locked)

```bash
./scripts/bootstrap-nodes.sh
```

Then initialize the cluster on the first control plane node:

```bash
kubeadm init --control-plane-endpoint "<NLB_DNS>:6443" \
  --upload-certs --pod-network-cidr=192.168.0.0/16

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Join remaining control plane nodes and workers
kubeadm join ...
```

---

## Application

The hipster-shop app consists of 11 microservices deployed to the `hipster-shop` namespace:

| Service | Language |
|---|---|
| frontend | Go |
| cartservice | C# |
| productcatalogservice | Go |
| currencyservice | Node.js |
| paymentservice | Node.js |
| shippingservice | Go |
| emailservice | Python |
| checkoutservice | Go |
| recommendationservice | Python |
| adservice | Java |
| loadgenerator | Python/Locust |

---

## Phases

| Phase | Topic | K8s Area |
|---|---|---|
| 1 | Foundation & Infrastructure | Cluster setup, namespaces |
| 2 | Observability & Monitoring | Prometheus, Grafana |
| 3 | Security & Compliance | Falco, Trivy, Network Policies |
| 4 | Service Mesh & Networking | Istio, mTLS, traffic management |
| 5 | GitOps & Automation | ArgoCD |
| 6 | Centralized Logging | Loki, Promtail |
| 7 | Autoscaling & Performance | HPA, VPA, PDB |
| 8 | Advanced Traffic Management | Canary, A/B, circuit breaker |
| 9 | Backup & Disaster Recovery | Velero |
| 10 | Chaos Engineering | Chaos Mesh |
| 11 | Cost Optimization | Kubecost |
| 12 | Advanced Security | OPA, Pod Security Standards |
| 13 | Multi-Environment Setup | Kustomize overlays |
| 14 | Distributed Tracing | Jaeger |
| 15 | CI/CD Integration | GitHub Actions |

---

## Kubernetes Stack

| Layer | Tool | Manifests |
|---|---|---|
| Application | Hipster Shop (11 microservices) | `k8s/applications/` |
| Monitoring | Prometheus + Grafana + Alertmanager | `k8s/monitoring/` |
| Logging | Loki + Promtail | `k8s/logging/` |
| Tracing | Jaeger | `k8s/tracing/` |
| Service Mesh | Istio (mTLS, canary, circuit breaker, rate limit) | `k8s/service-mesh/` |
| Security | Falco + Trivy + Network Policies | `k8s/security/` |
| Autoscaling | HPA + VPA + PDB | `k8s/autoscaling/` |
| Backup | Velero | `k8s/backup/` |
| GitOps | ArgoCD | `k8s/gitops/` + `gitops/applications/` |
| Storage | GP3 StorageClass | `k8s/storage/` |
| Ingress | NGINX Ingress | `k8s/ingress/` |

---

## Quick Commands

```bash
# Start/stop all EC2 instances (cost saving)
./scripts/cluster.sh start
./scripts/cluster.sh stop

# SSH to bastion
ssh -i ~/.ssh/<key>.pem ubuntu@<bastion-ip>

# SSH to control plane via bastion
ssh -i ~/.ssh/<key>.pem -J ubuntu@<bastion-ip> ubuntu@<control-plane-private-ip>

# Apply a specific layer
kubectl apply -R -f k8s/monitoring/
kubectl apply -R -f k8s/service-mesh/
kubectl apply -R -f k8s/security/
```

---

## GitOps (ArgoCD)

ArgoCD Application CRDs in `gitops/applications/` point to subdirectories in `k8s/` as their source:

- `hipster-shop.yaml` → `k8s/applications/hipster-shop`
- `monitoring.yaml` → `k8s/monitoring`
- `logging.yaml` → `k8s/logging`
- `service-mesh.yaml` → `k8s/service-mesh`
- `security.yaml` → `k8s/security`
- `autoscaling.yaml` → `k8s/autoscaling`
- `tracing.yaml` → `k8s/tracing`

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/applications/
```
