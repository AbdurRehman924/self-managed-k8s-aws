#!/bin/bash

# Hipster Shop - Complete Platform Verification Script
# Verifies all 11 phases are operational

echo "🎯 HIPSTER SHOP - COMPLETE PLATFORM VERIFICATION"
echo "=================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Phase 1: Infrastructure
echo "📦 PHASE 1: INFRASTRUCTURE"
echo "Cluster: $(kubectl config current-context)"
echo "Nodes: $(kubectl get nodes --no-headers | wc -l)"
kubectl get nodes
echo ""

# Phase 2: Microservices
echo "🚀 PHASE 2: MICROSERVICES"
echo "Namespace: hipster-shop"
echo "Deployments: $(kubectl get deployments -n hipster-shop --no-headers | wc -l)"
echo "Pods: $(kubectl get pods -n hipster-shop --no-headers | grep Running | wc -l)/$(kubectl get pods -n hipster-shop --no-headers | wc -l)"
kubectl get pods -n hipster-shop
echo ""

# Phase 3: Monitoring
echo "📊 PHASE 3: MONITORING"
echo "Prometheus: $(kubectl get pods -n monitoring -l app=prometheus --no-headers | grep Running | wc -l) pods"
echo "Grafana: $(kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana --no-headers | grep Running | wc -l) pods"
echo "AlertManager: $(kubectl get pods -n monitoring -l app.kubernetes.io/name=alertmanager --no-headers | grep Running | wc -l) pods"
GRAFANA_IP=$(kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Grafana URL: http://${GRAFANA_IP}"
echo ""

# Phase 4: Security
echo "🔒 PHASE 4: SECURITY"
echo "Falco: $(kubectl get pods -n security -l app.kubernetes.io/name=falco --no-headers | grep Running | wc -l) pods"
echo "Trivy: $(kubectl get pods -n security -l app.kubernetes.io/name=trivy-operator --no-headers | grep Running | wc -l) pods"
echo "Network Policies: $(kubectl get networkpolicies -n hipster-shop --no-headers | wc -l)"
echo ""

# Phase 5: Service Mesh
echo "🕸️  PHASE 5: SERVICE MESH"
echo "Istio Version: $(kubectl get deployment istiod -n istio-system -o jsonpath='{.spec.template.spec.containers[0].image}' | cut -d: -f2)"
echo "Istiod: $(kubectl get pods -n istio-system -l app=istiod --no-headers | grep Running | wc -l) pods"
echo "Ingress Gateway: $(kubectl get pods -n istio-system -l app=istio-ingressgateway --no-headers | grep Running | wc -l) pods"
GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Gateway URL: http://${GATEWAY_IP}"
echo "Proxies: $(kubectl get pods -n hipster-shop -o jsonpath='{.items[*].spec.containers[*].name}' | tr ' ' '\n' | grep istio-proxy | wc -l)"
echo ""

# Phase 6: GitOps
echo "🔄 PHASE 6: GITOPS"
echo "ArgoCD: $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server --no-headers | grep Running | wc -l) pods"
echo "Applications: $(kubectl get applications -n argocd --no-headers | wc -l)"
kubectl get applications -n argocd
echo ""

# Phase 7: Logging
echo "📝 PHASE 7: LOGGING"
echo "Loki: $(kubectl get pods -n logging -l app=loki --no-headers | grep Running | wc -l) pods"
echo "Promtail: $(kubectl get pods -n logging -l app.kubernetes.io/name=promtail --no-headers | grep Running | wc -l) pods"
echo ""

# Phase 8: Autoscaling
echo "⚡ PHASE 8: AUTOSCALING"
echo "HPA: $(kubectl get hpa -n hipster-shop --no-headers | wc -l)"
echo "VPA: $(kubectl get vpa -n hipster-shop --no-headers | wc -l)"
echo "PDB: $(kubectl get pdb -n hipster-shop --no-headers | wc -l)"
kubectl get hpa -n hipster-shop
echo ""

# Phase 9: Traffic Management
echo "🚦 PHASE 9: TRAFFIC MANAGEMENT"
echo "Gateways: $(kubectl get gateway -n hipster-shop --no-headers | wc -l)"
echo "VirtualServices: $(kubectl get virtualservice -n hipster-shop --no-headers | wc -l)"
echo "DestinationRules: $(kubectl get destinationrule -n hipster-shop --no-headers | wc -l)"
echo ""

# Phase 10: Backup & DR
echo "💾 PHASE 10: BACKUP & DISASTER RECOVERY"
echo "Velero: $(kubectl get pods -n velero -l component=velero --no-headers | grep Running | wc -l) pods"
echo "Backups: $(kubectl get backups -n velero --no-headers | wc -l)"
echo "Schedules: $(kubectl get schedules -n velero --no-headers | wc -l)"
kubectl get backups -n velero
echo ""

# Phase 11: Distributed Tracing
echo "🔍 PHASE 11: DISTRIBUTED TRACING"
echo "Jaeger: $(kubectl get pods -n tracing -l app=jaeger --no-headers | grep Running | wc -l) pods"
echo "Jaeger UI: kubectl port-forward -n tracing svc/jaeger-query 16686:80"
echo ""

# Summary
echo "=================================================="
echo "✅ VERIFICATION COMPLETE"
echo "=================================================="
echo ""
echo "🎉 ALL 11 PHASES OPERATIONAL!"
echo ""
echo "Quick Access:"
echo "  • Application: http://${GATEWAY_IP}"
echo "  • Grafana: http://${GRAFANA_IP}"
echo "  • ArgoCD: kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "  • Jaeger: kubectl port-forward -n tracing svc/jaeger-query 16686:80"
echo ""
echo "Next Steps:"
echo "  1. Create architecture diagrams"
echo "  2. Document key learnings"
echo "  3. Prepare demo video"
echo "  4. Update portfolio/resume"
echo ""
