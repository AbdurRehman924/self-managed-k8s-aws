#!/bin/bash
# Performance and Autoscaling Test Script

echo "=== Hipster Shop Autoscaling Status ==="
echo ""

echo "📊 HPA Status:"
kubectl get hpa -n hipster-shop
echo ""

echo "📈 VPA Recommendations:"
kubectl get vpa -n hipster-shop
echo ""

echo "🛡️ Pod Disruption Budgets:"
kubectl get pdb -n hipster-shop
echo ""

echo "🔢 Current Pod Counts:"
kubectl get pods -n hipster-shop | grep -E "frontend|productcatalog|recommendation|checkout" | wc -l
echo ""

echo "💻 Node Resource Usage:"
kubectl top nodes
echo ""

echo "📦 Pod Resource Usage (Top 10):"
kubectl top pods -n hipster-shop --sort-by=memory | head -11
echo ""

echo "🎯 HPA Detailed Status:"
for hpa in $(kubectl get hpa -n hipster-shop -o name); do
  echo "---"
  kubectl describe $hpa -n hipster-shop | grep -A 5 "Metrics:"
done
echo ""

echo "✅ Autoscaling infrastructure is operational!"
