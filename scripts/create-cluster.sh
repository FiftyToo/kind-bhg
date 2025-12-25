#!/bin/bash
set -e

echo "================================================"
echo "Creating Kind cluster: bhg"
echo "================================================"

# Check if cluster already exists
if kind get clusters | grep -q "^bhg$"; then
    echo "Cluster 'bhg' already exists."
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing cluster..."
        kind delete cluster --name bhg
    else
        echo "Using existing cluster."
        exit 0
    fi
fi

echo "Creating Kind cluster with config from kind-config.yaml..."
kind create cluster --config kind-config.yaml

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo ""
echo "================================================"
echo "Kind cluster 'bhg' created successfully!"
echo "================================================"
echo ""
echo "Cluster info:"
kubectl cluster-info
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/install-all.sh to install all components"
echo "  2. Or install components individually:"
echo "     - ./scripts/install-cert-manager.sh"
echo "     - ./scripts/install-cloudflare.sh"
echo "     - ./scripts/install-argocd.sh"
echo "     - ./scripts/install-kagent.sh"
echo "     - ./scripts/install-nginx.sh"
