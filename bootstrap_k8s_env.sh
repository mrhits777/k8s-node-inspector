#!/bin/bash

set -euo pipefail

echo "🔧 Setting up local Kubernetes cluster using Kind..."

# Install Kind if missing
if ! command -v kind &>/dev/null; then
  echo "Installing Kind..."
  curl -Lo kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
  chmod +x kind && sudo mv kind /usr/local/bin/
fi

# Install kubectl if missing
if ! command -v kubectl &>/dev/null; then
  echo "Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl && sudo mv kubectl /usr/local/bin/
fi

# Create cluster
kind create cluster --name node-inspector

# Deploy dummy workload
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox
        args:
        - sleep
        - "3600"
EOF

echo "✅ Cluster ready. You can now run: ./k8s-node-inspector.sh"
