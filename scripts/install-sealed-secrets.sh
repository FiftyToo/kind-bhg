#!/bin/bash
set -e

echo "Installing Sealed Secrets..."

# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

echo "Waiting for Sealed Secrets controller to be ready..."
kubectl wait --for=condition=Available --timeout=300s deployment/sealed-secrets-controller -n kube-system

echo "Sealed Secrets installed successfully!"
echo ""
echo "To use Sealed Secrets:"
echo "  1. Install kubeseal CLI:"
echo "     - macOS: brew install kubeseal"
echo "     - Linux: wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz"
echo ""
echo "  2. Create a sealed secret:"
echo "     kubectl create secret generic mysecret --dry-run=client --from-literal=password=mypassword -o yaml | \\"
echo "       kubeseal --format yaml > mysealedsecret.yaml"
echo ""
echo "  3. Apply the sealed secret:"
echo "     kubectl apply -f mysealedsecret.yaml"
echo ""
echo "The sealed secret can be safely committed to Git!"
