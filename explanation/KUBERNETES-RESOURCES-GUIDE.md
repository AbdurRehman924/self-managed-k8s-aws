# Kubernetes Resources: Complete Guide from Zero to Hero

## Table of Contents
1. [Infrastructure Overview](#1-infrastructure-overview)
2. [Understanding Kubernetes Resources](#2-understanding-kubernetes-resources)
3. [Your Cluster Analysis](#3-your-cluster-analysis)
4. [Resource Allocation Strategy](#4-resource-allocation-strategy)
5. [Optimization Steps](#5-optimization-steps)

---

## 1. Infrastructure Overview

### What is Infrastructure in Kubernetes?

Think of Kubernetes infrastructure like a building:
- **Nodes** = Floors in the building
- **Pods** = Rooms on each floor
- **Containers** = People/furniture in each room
- **Resources (CPU/Memory)** = Electricity and water supply

### The Hierarchy (Top to Bottom)

```
Cloud Provider (Azure)
    ↓
Virtual Machines (Nodes)
    ↓
Kubernetes Cluster
    ↓
Namespaces (Logical grouping)
    ↓
Pods (Smallest deployable unit)
    ↓
Containers (Your applications)
    ↓
Processes (Running code)
```

---

## 2. Understanding Kubernetes Resources

### 2.1 Node-Level Resources

**Command:**
```bash
kubectl get nodes -o wide
```

**Purpose:** Shows all physical/virtual machines in your cluster

**Why:** Nodes are the foundation - they provide the actual CPU and memory

**Problem:** Without knowing your nodes, you can't understand total capacity

**Advantages:** 
- Quick health check of infrastructure
- Identifies node failures immediately
- Shows node versions and IPs

**Best Practices:**
- Always check nodes first during incidents
- Monitor node status regularly
- Keep nodes on same Kubernetes version

**Your Cluster Data:**
```
NAME                              STATUS   AGE   VERSION
aks-default-14849428-vmss000000   Ready    28d   v1.34.2
aks-default-14849428-vmss000001   Ready    28d   v1.34.2
```

**What this means:**
- You have **2 nodes** (2 virtual machines)
- Both are **Ready** (healthy and accepting pods)
- Both running **Kubernetes v1.34.2**
- VM Type: **Standard_B2as_v2** (Azure B-series burstable)

---

### 2.2 Node Capacity vs Allocatable

**Command:**
```bash
kubectl describe nodes | grep -A 5 "Capacity:"
```

**Purpose:** Shows total resources vs what's available for pods

**Why:** Not all node resources are available to your pods - Kubernetes reserves some

**Problem:** Confusion about why you can't use 100% of node resources

**Advantages:**
- Understand true available capacity
- Plan pod placement accurately
- Avoid over-scheduling

**Best Practices:**
- Always use "Allocatable" for capacity planning, not "Capacity"
- Reserve 10-15% for system overhead
- Monitor actual usage vs allocatable

**Your Node Breakdown:**

#### Node 1: aks-default-14849428-vmss000000
```
Capacity (Total Hardware):
  CPU:    2 cores (2000m)
  Memory: 8125708Ki (~7.9 GB)

Allocatable (Available for Pods):
  CPU:    1900m (1.9 cores)
  Memory: 7357708Ki (~7.2 GB)

Reserved by Kubernetes:
  CPU:    100m (5%)
  Memory: ~768Mi (10%)
```

**Why the difference?**
- Kubernetes system pods (kubelet, kube-proxy)
- Operating system overhead
- Container runtime (containerd)
- System daemons

---

### 2.3 Current Resource Usage

**Command:**
```bash
kubectl top nodes
```

**Purpose:** Shows real-time CPU and memory usage on each node

**Why:** Understand how much capacity is actually being used right now

**Problem:** Allocated vs actual usage can be very different

**Advantages:**
- Identify underutilized nodes
- Spot resource exhaustion
- Make scaling decisions

**Best Practices:**
- Check during peak hours
- Compare with allocated resources
- Monitor trends over time

**Your Current Usage:**
```
NODE                              CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
aks-default-14849428-vmss000000   353m         18%      4960Mi          69%
aks-default-14849428-vmss000001   421m         22%      4809Mi          66%
```

**Analysis:**
- **CPU Usage:** Very low (18-22%) - plenty of CPU available
- **Memory Usage:** High (66-69%) - memory is the constraint!
- **Total Memory Used:** ~9.7 GB across both nodes
- **Total Memory Available:** ~14.4 GB (7.2 GB × 2)

**Key Insight:** You're NOT CPU-constrained, you're MEMORY-constrained!

---


## 3. Your Cluster Analysis

### 3.1 Pod Distribution

**Command:**
```bash
kubectl get pods --all-namespaces -o wide | awk '{print $8}' | sort | uniq -c
```

**Purpose:** Count how many pods are on each node

**Why:** Nodes have a maximum pod limit (usually 30-110 depending on VM size)

**Problem:** You can hit pod limit before hitting CPU/memory limits

**Advantages:**
- Identify pod density issues
- Plan for pod limits
- Balance workloads

**Best Practices:**
- Keep pod count below 80% of max
- Distribute pods evenly
- Consider pod limits when sizing nodes

**Your Pod Distribution:**
```
28 pods on aks-default-14849428-vmss000000
28 pods on aks-default-14849428-vmss000001
Total: 56 pods
```

**Critical Issue:** You're at the **pod limit!**

Azure Standard_B2as_v2 nodes have a **maximum of 30 pods per node** (with Azure CNI).
You have **28 pods per node** - only 2 slots left per node!

**This is why pods are Pending!**

---

### 3.2 Resource Requests vs Limits

**What are Requests and Limits?**

```yaml
resources:
  requests:     # Guaranteed minimum
    memory: 64Mi
    cpu: 50m
  limits:       # Maximum allowed
    memory: 128Mi
    cpu: 100m
```

**Requests:**
- **What it is:** Minimum resources guaranteed to the pod
- **Scheduler uses this:** Pod only scheduled if node has enough "requests" available
- **Billing:** You pay for requests, not actual usage (in some clouds)

**Limits:**
- **What it is:** Maximum resources pod can use
- **Enforcement:** Pod killed if exceeds memory limit (OOMKilled)
- **CPU:** Pod throttled if exceeds CPU limit (slowed down)

**Your Current Allocation:**

#### Node 1:
```
Allocated Requests:
  CPU:    1566m / 1900m (82% allocated)
  Memory: 3202Mi / 7357Mi (44% allocated)

Allocated Limits:
  CPU:    20126m / 1900m (1059% - overcommitted!)
  Memory: 23162Mi / 7357Mi (322% - overcommitted!)
```

**What does overcommitted mean?**
- If ALL pods tried to use their limits simultaneously, you'd need 10x more CPU!
- This is normal and safe - pods rarely use their full limits
- Kubernetes allows this to maximize resource utilization

**Key Insight:**
- CPU requests: 82% used (still room)
- Memory requests: 44% used (plenty of room)
- **But actual memory usage is 69%!** (from `kubectl top nodes`)

**The Problem:** Pods are using MORE memory than their requests!

---

### 3.3 Top Memory Consumers

**Command:**
```bash
kubectl top pods --all-namespaces --sort-by=memory | head -20
```

**Purpose:** Identify which pods are using the most memory

**Why:** Find optimization targets

**Problem:** Some pods may be memory hogs

**Advantages:**
- Prioritize optimization efforts
- Identify memory leaks
- Right-size resources

**Best Practices:**
- Check top 10 consumers regularly
- Compare with their requests/limits
- Investigate pods using >500Mi

**Your Top Memory Users:**

| Pod | Namespace | Memory | Notes |
|-----|-----------|--------|-------|
| prometheus-0 | monitoring | 788Mi | Metrics database - expected |
| argocd-controller | argocd | 426Mi | GitOps controller - expected |
| falco (×2) | security | 393Mi + 369Mi | Runtime security - high! |
| grafana | monitoring | 263Mi | Dashboards - reasonable |
| loadgenerator | hipster-shop | 242Mi | **Can be removed!** |
| trivy-operator | security | 228Mi | Vulnerability scanner |

**Optimization Opportunities:**
1. **Remove loadgenerator** (242Mi) - only needed for testing
2. **Reduce Falco memory** - 762Mi total for 2 DaemonSets is high
3. **Trivy continuous scanning** - causing pending scan pods

---

### 3.4 The Pod Limit Problem

**Your Situation:**
```
Max pods per node: 30
Current pods per node: 28
Available slots: 2 per node (4 total)
Pending pods: 10+
```

**Why 30 pods?**
Azure CNI (Container Network Interface) allocates IP addresses from your VNet subnet.
Standard_B2as_v2 with Azure CNI = 30 pod limit.

**Solutions:**
1. **Remove unnecessary pods** (loadgenerator, Trivy scans)
2. **Increase node count** (add a 3rd node)
3. **Use larger VM size** (more pod capacity)
4. **Switch to kubenet** (110 pods/node, but loses some features)

---

## 4. Resource Allocation Strategy

### 4.1 The Problem Statement

**Your Constraints:**
- 2 nodes × 30 pods = 60 pod capacity
- Currently: 56 pods running + 10 pending = 66 pods needed
- Memory: 69% used (high)
- CPU: 18-22% used (plenty available)
- Pod slots: 93% full (critical)

**Root Causes:**
1. **Pod limit reached** - can't schedule more pods
2. **Trivy scan jobs flooding** - creating many pending pods
3. **Memory pressure** - actual usage higher than requests
4. **No resource optimization** - pods have arbitrary requests/limits

---

### 4.2 Recommended Strategy

#### Phase 1: Immediate Cleanup (Do Now)

**Command:**
```bash
# 1. Delete pending Trivy scan jobs
kubectl delete pods -n security --field-selector=status.phase=Pending

# 2. Scale down Trivy operator (stop continuous scanning)
kubectl scale deployment -n security trivy-operator --replicas=0

# 3. Remove load generator (testing only)
kubectl scale deployment -n hipster-shop loadgenerator --replicas=0

# 4. Fix recommendation HPA
kubectl patch hpa -n hipster-shop recommendation-hpa -p '{"spec":{"maxReplicas":2}}'
```

**Purpose:** Free up pod slots and memory immediately

**Why:** You need breathing room before optimizing

**Problem:** Cluster is at capacity, can't make changes

**Advantages:**
- Frees ~10 pod slots
- Saves ~500Mi memory
- Stops scan job spam

**Best Practices:**
- Remove non-production workloads first
- Keep monitoring and core apps
- Document what you removed

**Expected Result:**
- Pods running: 56 → 44
- Available slots: 4 → 16
- Memory freed: ~500Mi

---


#### Phase 2: Resource Right-Sizing (Next 24 Hours)

**Step 1: Collect Actual Usage Data**

**Command:**
```bash
# Monitor for 24 hours, run every hour
kubectl top pods --all-namespaces > usage-$(date +%Y%m%d-%H%M).txt
```

**Purpose:** Understand real resource consumption patterns

**Why:** Set requests based on actual usage, not guesses

**Problem:** Current requests don't match reality

**Advantages:**
- Data-driven decisions
- Avoid over-provisioning
- Prevent OOMKilled

**Best Practices:**
- Collect during peak hours
- Run for at least 24 hours
- Include weekday and weekend data

---

**Step 2: Calculate Optimal Requests**

**Formula:**
```
Request = P95 actual usage × 1.2 (20% buffer)
Limit = Request × 1.5 (50% burst capacity)
```

**Example for frontend pod:**
```
Actual usage: 91Mi memory, 20m CPU
Request: 91Mi × 1.2 = 109Mi → round to 128Mi
Limit: 128Mi × 1.5 = 192Mi → round to 256Mi
```

**Command:**
```bash
# Check current usage
kubectl top pod -n hipster-shop frontend-6777b84c4-hkllt

# Output: 91Mi memory, 20m CPU
```

**Purpose:** Set realistic resource values

**Why:** Prevents OOMKilled while maximizing density

**Problem:** Too low = crashes, too high = waste

**Advantages:**
- Optimal resource utilization
- Stable pod performance
- Cost efficiency

**Best Practices:**
- Use P95, not average (handles spikes)
- Add 20% buffer for safety
- Round to standard values (64Mi, 128Mi, 256Mi)

---

**Step 3: Implement Tiered Resource Allocation**

**Tier 1: Critical Services** (frontend, checkout, payment)
```yaml
resources:
  requests:
    memory: 128Mi
    cpu: 100m
  limits:
    memory: 256Mi
    cpu: 200m
```

**Tier 2: Standard Services** (catalog, cart, recommendation)
```yaml
resources:
  requests:
    memory: 64Mi
    cpu: 50m
  limits:
    memory: 128Mi
    cpu: 100m
```

**Tier 3: Background Services** (monitoring, logging)
```yaml
resources:
  requests:
    memory: 32Mi
    cpu: 25m
  limits:
    memory: 64Mi
    cpu: 50m
```

**Purpose:** Prioritize critical workloads

**Why:** Ensures important services get resources first

**Problem:** All pods treated equally during resource contention

**Advantages:**
- Critical services stay healthy
- Better resource distribution
- Clear priority model

**Best Practices:**
- Define tiers based on business impact
- Document tier assignments
- Review quarterly

---

#### Phase 3: Long-Term Optimization

**Option A: Add a Third Node**

**Command:**
```bash
az aks nodepool scale \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name default \
  --node-count 3
```

**Purpose:** Increase total cluster capacity

**Why:** More room for pods and memory

**Problem:** Current 2-node setup is at capacity

**Advantages:**
- 90 total pod slots (30 × 3)
- ~21 GB total memory
- Better high availability

**Cost:** ~$30-40/month for 3rd node

**Best Practices:**
- Scale before hitting 80% capacity
- Use odd number of nodes (3, 5) for HA
- Monitor cost vs benefit

---

**Option B: Use Larger Nodes**

**Current:** Standard_B2as_v2 (2 vCPU, 8 GB, 30 pods)
**Upgrade to:** Standard_B4as_v2 (4 vCPU, 16 GB, 60 pods)

**Command:**
```bash
# Create new node pool with larger VMs
az aks nodepool add \
  --cluster-name <cluster-name> \
  --resource-group <resource-group> \
  --name largepool \
  --node-count 2 \
  --node-vm-size Standard_B4as_v2

# Drain old nodes
kubectl drain aks-default-14849428-vmss000000 --ignore-daemonsets --delete-emptydir-data

# Delete old node pool
az aks nodepool delete --name default
```

**Purpose:** More capacity per node

**Why:** Better pod density and memory

**Problem:** Current nodes too small for workload

**Advantages:**
- 120 total pod slots (60 × 2)
- ~32 GB total memory
- Same node count

**Cost:** ~$60-80/month (vs ~$40 for B2as_v2)

**Best Practices:**
- Test in staging first
- Migrate during maintenance window
- Keep old nodes until migration complete

---

**Option C: Optimize Without Adding Nodes**

**Strategy:** Reduce pod count through consolidation

1. **Combine monitoring stack** (Prometheus + Grafana in one pod)
2. **Remove redundant services** (loadgenerator, extra Falco)
3. **Use DaemonSets wisely** (Falco, Promtail = 2 pods per node)
4. **Disable continuous scanning** (Trivy on-demand only)

**Target:** Reduce from 56 pods to ~40 pods

**Purpose:** Work within current constraints

**Why:** Avoid additional cost

**Problem:** Limited budget

**Advantages:**
- No additional cost
- Forces optimization discipline
- Simpler architecture

**Best Practices:**
- Remove before adding
- Question every workload
- Measure impact

---

## 5. Optimization Steps (Action Plan)

### Step 1: Immediate Cleanup (Do Right Now)

```bash
# 1. Delete pending Trivy scans
kubectl delete pods -n security --field-selector=status.phase=Pending

# 2. Stop Trivy continuous scanning
kubectl scale deployment -n security trivy-operator --replicas=0

# 3. Remove load generator
kubectl scale deployment -n hipster-shop loadgenerator --replicas=0

# 4. Verify pod count
kubectl get pods --all-namespaces | wc -l
# Should show ~46 pods (down from 56)
```

**Expected Results:**
- ✅ All pending pods cleared
- ✅ 10+ pod slots freed
- ✅ ~500Mi memory freed
- ✅ Cluster stable

---

### Step 2: Monitor for 24 Hours

```bash
# Create monitoring script
cat > monitor-usage.sh << 'EOF'
#!/bin/bash
while true; do
  echo "=== $(date) ===" >> usage-log.txt
  kubectl top nodes >> usage-log.txt
  kubectl top pods --all-namespaces --sort-by=memory | head -20 >> usage-log.txt
  sleep 3600  # Every hour
done
EOF

chmod +x monitor-usage.sh
./monitor-usage.sh &
```

**Purpose:** Collect real usage data

**Why:** Make informed decisions

**Problem:** Don't know actual resource needs

---

### Step 3: Apply Resource Limits (After 24h)

```bash
# Example: Update frontend deployment
kubectl set resources deployment frontend -n hipster-shop \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi

# Repeat for each service based on collected data
```

**Purpose:** Right-size all pods

**Why:** Optimize resource allocation

**Problem:** Current values are arbitrary

---

### Step 4: Enable VPA for Recommendations

```bash
# Install VPA
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-0.14.0/vpa-v0.14.0.yaml

# Create VPA for a service (recommendation mode)
kubectl apply -f - <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: frontend-vpa
  namespace: hipster-shop
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: frontend
  updateMode: "Off"  # Recommendation only
EOF

# Check recommendations after 24h
kubectl describe vpa frontend-vpa -n hipster-shop
```

**Purpose:** Get automated recommendations

**Why:** VPA analyzes usage patterns

**Problem:** Manual calculation is tedious

---

### Step 5: Decide on Scaling

**If memory usage stays >70% after optimization:**
→ Add 3rd node or upgrade to larger VMs

**If memory usage drops to <60%:**
→ Stay with 2 nodes, continue optimizing

**Command to check:**
```bash
kubectl top nodes
```

---

## 6. Key Takeaways

### Your Cluster Summary

**Infrastructure:**
- 2 nodes × Standard_B2as_v2 (2 vCPU, 8 GB each)
- Total capacity: 4 vCPU, 16 GB memory, 60 pod slots
- Current usage: 56 pods, ~10 GB memory, ~800m CPU

**Problems Identified:**
1. ✅ **Pod limit reached** (28/30 per node)
2. ✅ **Trivy scan spam** (10+ pending pods)
3. ✅ **Memory pressure** (69% usage)
4. ✅ **No resource optimization** (arbitrary requests/limits)

**Solutions Applied:**
1. Remove non-essential workloads (loadgenerator, Trivy scans)
2. Monitor actual usage for 24 hours
3. Right-size resource requests/limits
4. Consider adding 3rd node if needed

---

## 7. Commands Reference

### Daily Monitoring
```bash
# Node health
kubectl get nodes

# Resource usage
kubectl top nodes
kubectl top pods --all-namespaces --sort-by=memory

# Pod distribution
kubectl get pods --all-namespaces -o wide | awk '{print $8}' | sort | uniq -c

# Pending pods
kubectl get pods --all-namespaces | grep Pending

# Recent events
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -20
```

### Troubleshooting
```bash
# Why is pod pending?
kubectl describe pod <pod-name> -n <namespace>

# Check OOMKilled
kubectl get events --all-namespaces | grep OOM

# Resource allocation
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### Optimization
```bash
# Set resources
kubectl set resources deployment <name> -n <namespace> \
  --requests=cpu=100m,memory=128Mi \
  --limits=cpu=200m,memory=256Mi

# Scale deployment
kubectl scale deployment <name> -n <namespace> --replicas=<count>

# Check VPA recommendations
kubectl describe vpa <name> -n <namespace>
```

---

## 8. Next Steps

1. ✅ **Run Step 1 cleanup commands** (do now)
2. ⏳ **Start 24-hour monitoring** (run monitor script)
3. ⏳ **Analyze usage data** (after 24 hours)
4. ⏳ **Apply resource limits** (based on data)
5. ⏳ **Decide on scaling** (add node if needed)

---

**Questions? Check the data files in this directory:**
- `data-nodes.txt` - Node information
- `data-nodes-usage.txt` - Current resource usage
- `data-pods-memory.txt` - Memory consumption by pod
- `data-node-capacity.txt` - Detailed capacity breakdown

