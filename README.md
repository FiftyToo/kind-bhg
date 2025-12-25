# kind-bhg - Kind Cluster Infrastructure

This repository contains all the infrastructure-as-code needed to rebuild the BHG Kind cluster from scratch.

## Overview

The cluster includes:
- **Cloudflare Tunnel Ingress Controller** - Expose services via Cloudflare tunnels
- **ArgoCD** - GitOps continuous deployment
- **KAgent** - AI agent framework for Kubernetes
- **cert-manager** - TLS certificate management
- **NGINX Ingress Controller** - Alternative ingress option

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- Docker Desktop or Docker Engine

## Required Secrets

### Setup Secrets (needed before installation)

Create these as GitHub repository secrets:

1. `CLOUDFLARE_API_TOKEN` - Cloudflare API token with permissions:
   - `Zone:Zone:Read`
   - `Zone:DNS:Edit`
   - `Account:Cloudflare Tunnel:Edit`
   
   Create token: https://dash.cloudflare.com/profile/api-tokens

2. `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare account ID
   
   Find it: https://developers.cloudflare.com/fundamentals/get-started/basic-tasks/find-account-and-zone-ids/

3. `OPENAI_API_KEY` - OpenAI API key for KAgent agents
   
   Get key: https://platform.openai.com/account/api-keys

### Runtime Secrets (needed for operation)

4. `CLOUDFLARE_TUNNEL_NAME` - Name for your Cloudflare tunnel (e.g., "bhg-tunnel")
5. `GITHUB_TOKEN` (optional) - For KAgent GitHub operations

## Secrets Management Recommendations

### Option 1: Sealed Secrets (Recommended for GitOps)

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Install kubeseal CLI
brew install kubeseal

# Create sealed secret
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
```

**Pros**: Secrets encrypted and stored in Git, fully GitOps compatible
**Cons**: Requires kubeseal CLI for creating secrets

### Option 2: External Secrets Operator

```bash
# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace
```

**Pros**: Integrates with external secret stores (AWS Secrets Manager, Azure Key Vault, etc.)
**Cons**: Requires external secret management system

## Quick Start

### 1. Create Kind Cluster

```bash
./scripts/create-cluster.sh
```

This creates a Kind cluster with the configuration defined in `kind-config.yaml`.

### 2. Install Core Components

```bash
./scripts/install-all.sh
```

This script installs all components in the correct order:
1. cert-manager
2. Cloudflare Tunnel Ingress Controller
3. NGINX Ingress Controller
4. ArgoCD
5. KAgent

### 3. Access Services

**ArgoCD:**
```bash
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at: https://localhost:8080
# Username: admin
```

**KAgent Dashboard:**
```bash
# Port forward to access UI
kubectl port-forward svc/kagent-ui -n kagent 8082:8080

# Access at: http://localhost:8082
```

## Manual Installation Steps

If you prefer to install components manually:

### cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```

### Cloudflare Tunnel Ingress Controller
```bash
helm repo add strrl.dev https://helm.strrl.dev
helm repo update

helm upgrade --install --wait \
  -n cloudflare-tunnel-ingress-controller --create-namespace \
  cloudflare-tunnel-ingress-controller \
  strrl.dev/cloudflare-tunnel-ingress-controller \
  --set cloudflare.apiToken="${CLOUDFLARE_API_TOKEN}" \
  --set cloudflare.accountId="${CLOUDFLARE_ACCOUNT_ID}" \
  --set cloudflare.tunnelName="${CLOUDFLARE_TUNNEL_NAME}"
```

### ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### KAgent
```bash
export OPENAI_API_KEY="your-api-key"
kagent install --profile demo
```

### NGINX Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml
```

## Directory Structure

```
.
├── README.md                    # This file
├── kind-config.yaml            # Kind cluster configuration
├── manifests/                  # Kubernetes manifests
│   ├── cert-manager/          # cert-manager resources
│   ├── cloudflare-tunnel/     # Cloudflare tunnel config
│   ├── argocd/                # ArgoCD applications
│   ├── kagent/                # KAgent base resources
│   └── ingress-nginx/         # NGINX ingress resources
├── scripts/                    # Installation scripts
│   ├── create-cluster.sh      # Create Kind cluster
│   ├── install-all.sh         # Install all components
│   ├── install-cert-manager.sh
│   ├── install-cloudflare.sh
│   ├── install-argocd.sh
│   ├── install-kagent.sh
│   └── install-nginx.sh
└── .github/
    └── workflows/
        └── cluster-sync.yaml  # GitHub Actions for cluster sync
```

## GitHub Actions

The repository includes a GitHub Actions workflow that can sync cluster configuration when changes are pushed to main.

## Troubleshooting

### Cluster not starting
```bash
# Check Docker is running
docker ps

# Delete and recreate cluster
kind delete cluster --name bhg
./scripts/create-cluster.sh
```

### Cloudflare Tunnel not working
```bash
# Check controller logs
kubectl logs -n cloudflare-tunnel-ingress-controller -l app.kubernetes.io/name=cloudflare-tunnel-ingress-controller

# Verify secret exists
kubectl get secret -n cloudflare-tunnel-ingress-controller cloudflare-api
```

### ArgoCD not accessible
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Reset admin password
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {"admin.password": "'$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)'","admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'  
```

## Contributing

When adding new infrastructure components:

1. Add manifests to appropriate directory under `manifests/`
2. Create installation script in `scripts/`
3. Update `install-all.sh` to include new component
4. Update this README

## License

MIT
