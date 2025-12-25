#!/bin/bash
set -e

echo "Installing NGINX Ingress Controller..."

# Install NGINX Ingress Controller (Kind-specific manifest)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml

echo "Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --for=condition=Available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

echo "NGINX Ingress Controller installed successfully!"
echo ""
echo "Create an Ingress resource with ingressClassName: nginx to expose services via NGINX."
