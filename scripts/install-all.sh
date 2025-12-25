#!/bin/bash
set -e

echo "================================================"
echo "Installing all components to Kind cluster"
echo "================================================"

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install components in order
echo ""
echo "[1/5] Installing cert-manager..."
bash "$SCRIPT_DIR/install-cert-manager.sh"

echo ""
echo "[2/5] Installing Cloudflare Tunnel Ingress Controller..."
bash "$SCRIPT_DIR/install-cloudflare.sh"

echo ""
echo "[3/5] Installing NGINX Ingress Controller..."
bash "$SCRIPT_DIR/install-nginx.sh"

echo ""
echo "[4/5] Installing ArgoCD..."
bash "$SCRIPT_DIR/install-argocd.sh"

echo ""
echo "[5/5] Installing KAgent..."
bash "$SCRIPT_DIR/install-kagent.sh"

echo ""
echo "================================================"
echo "All components installed successfully!"
echo "================================================"
echo ""
echo "Access services:"
echo ""
echo "ArgoCD:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  URL: https://localhost:8080"
echo "  Username: admin"
echo "  Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "KAgent:"
echo "  kubectl port-forward svc/kagent-ui -n kagent 8082:8080"
echo "  URL: http://localhost:8082"
echo ""
