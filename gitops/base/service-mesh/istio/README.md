# Istio Service Mesh Configuration

## Version
- **Istio**: 1.28.3
- **Profile**: demo
- **Installation Date**: February 14, 2026

## Installation

### 1. Download Istio
```bash
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.28.3 sh -
cd istio-1.28.3
export PATH=$PWD/bin:$PATH
```

### 2. Install Control Plane
```bash
istioctl install --set profile=demo -y
```

### 3. Enable Sidecar Injection
```bash
kubectl label namespace hipster-shop istio-injection=enabled
```

### 4. Adjust Pod Security (Required for Istio)
```bash
kubectl label namespace hipster-shop pod-security.kubernetes.io/enforce=privileged --overwrite
```

### 5. Restart Deployments
```bash
kubectl rollout restart deployment -n hipster-shop
```

## Verification

### Check Control Plane
```bash
kubectl get pods -n istio-system
```

Expected output:
- istiod (control plane)
- istio-ingressgateway
- istio-egressgateway

### Check Proxy Status
```bash
istioctl proxy-status
```

Should show all pods with sidecars connected to istiod.

### Verify mTLS
```bash
istioctl x describe pod <pod-name> -n hipster-shop | grep -i tls
```

Should show: `Workload mTLS mode: STRICT`

## Configuration Files

- `peer-authentication.yaml` - mTLS configuration (STRICT for all services, PERMISSIVE for frontend)

## Network Policies

Istio requires adjusted network policies to allow:
- DNS resolution (UDP 53 to kube-system)
- Control plane communication (TCP 15012, 15017, 443 to istio-system)
- Pod-to-pod communication within namespace

See: `../security/policies/allow-all-istio-mesh.yaml`

## Troubleshooting

### Sidecars not injecting
```bash
kubectl get namespace hipster-shop --show-labels
```
Verify `istio-injection=enabled` label exists.

### Pods stuck in Init
Check network policies allow Istio traffic:
```bash
kubectl get networkpolicies -n hipster-shop
```

### Connection timeouts
Verify mTLS configuration:
```bash
kubectl get peerauthentication -n hipster-shop
```

## Resources

- [Istio Documentation](https://istio.io/latest/docs/)
- [Istio Security Best Practices](https://istio.io/latest/docs/ops/best-practices/security/)
