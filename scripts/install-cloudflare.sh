#!/bin/bash
set -e

echo "Installing Cloudflare Tunnel Ingress Controller..."

# Check for required environment variables
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "ERROR: CLOUDFLARE_API_TOKEN environment variable is not set"
    echo "Please set it before running this script:"
    echo "  export CLOUDFLARE_API_TOKEN='your-token'"
    exit 1
fi

if [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "ERROR: CLOUDFLARE_ACCOUNT_ID environment variable is not set"
    echo "Please set it before running this script:"
    echo "  export CLOUDFLARE_ACCOUNT_ID='your-account-id'"
    exit 1
fi

if [ -z "$CLOUDFLARE_TUNNEL_NAME" ]; then
    echo "WARNING: CLOUDFLARE_TUNNEL_NAME not set, using default 'bhg-tunnel'"
    CLOUDFLARE_TUNNEL_NAME="bhg-tunnel"
fi

echo "Tunnel name: $CLOUDFLARE_TUNNEL_NAME"

# Add Helm repository
helm repo add strrl.dev https://helm.strrl.dev
helm repo update

# Install Cloudflare Tunnel Ingress Controller
helm upgrade --install --wait \
  -n cloudflare-tunnel-ingress-controller --create-namespace \
  cloudflare-tunnel-ingress-controller \
  strrl.dev/cloudflare-tunnel-ingress-controller \
  --set cloudflare.apiToken="${CLOUDFLARE_API_TOKEN}" \
  --set cloudflare.accountId="${CLOUDFLARE_ACCOUNT_ID}" \
  --set cloudflare.tunnelName="${CLOUDFLARE_TUNNEL_NAME}"

echo "Waiting for Cloudflare Tunnel controller to be ready..."
kubectl wait --for=condition=Available --timeout=300s deployment/cloudflare-tunnel-ingress-controller -n cloudflare-tunnel-ingress-controller

echo "Cloudflare Tunnel Ingress Controller installed successfully!"
echo ""
echo "Your tunnel '${CLOUDFLARE_TUNNEL_NAME}' is now active."
echo "Create an Ingress resource with ingressClassName: cloudflare-tunnel to expose services."
