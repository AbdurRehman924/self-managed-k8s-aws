#!/bin/bash
# Bootstrap all K8s nodes: install containerd, kubeadm, kubelet, kubectl
# Run from local machine. Requires bastion SSH access.

set -e

KEY="$HOME/.ssh/main-key-ssh-rsa"
BASTION="98.80.205.104"
K8S_VERSION="1.29"

CONTROL_PLANE_IPS=("10.0.0.127" "10.0.1.250" "10.0.2.9")
WORKER_IPS=("10.0.10.239" "10.0.11.47" "10.0.12.33")
ALL_IPS=("${CONTROL_PLANE_IPS[@]}" "${WORKER_IPS[@]}")

SSH_OPTS="-i $KEY -o StrictHostKeyChecking=no -o ProxyJump=ubuntu@$BASTION"

INSTALL_SCRIPT='
set -e

# Disable swap (required by kubelet)
sudo swapoff -a
sudo sed -i "/swap/d" /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Kernel networking params for K8s
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Install containerd
sudo apt-get update -qq
sudo apt-get install -y -qq containerd apt-transport-https ca-certificates curl gpg

# Configure containerd with systemd cgroup driver
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes apt repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v'"$K8S_VERSION"'/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v'"$K8S_VERSION"'/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm, kubelet, kubectl
sudo apt-get update -qq
sudo apt-get install -y -qq kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "✅ Node $(hostname) bootstrap complete"
'

echo "🚀 Bootstrapping ${#ALL_IPS[@]} nodes in parallel..."

PIDS=()
for IP in "${ALL_IPS[@]}"; do
  ssh $SSH_OPTS ubuntu@$IP "$INSTALL_SCRIPT" &
  PIDS+=($!)
  echo "  → Started bootstrap on $IP (pid $!)"
done

# Wait for all and report
FAILED=0
for i in "${!PIDS[@]}"; do
  IP="${ALL_IPS[$i]}"
  if wait "${PIDS[$i]}"; then
    echo "  ✅ $IP done"
  else
    echo "  ❌ $IP FAILED"
    FAILED=1
  fi
done

if [ $FAILED -eq 0 ]; then
  echo ""
  echo "✅ All nodes bootstrapped successfully. Ready for kubeadm init."
else
  echo ""
  echo "❌ Some nodes failed. Check output above."
  exit 1
fi
