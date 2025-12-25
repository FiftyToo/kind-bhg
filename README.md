# kind-bhg - Kind Cluster Infrastructure

This repository contains all the infrastructure-as-code needed to rebuild the BHG Kind cluster from scratch.

## Overview

The cluster includes:
- **cert-manager** - TLS certificate management
- **Sealed Secrets** - Encrypt secrets for safe Git storage
- **Cloudflare Tunnel Ingress Controller** - Expose services via Cloudflare tunnels
- **NGINX Ingress Controller** - Alternative ingress option
- **ArgoCD** - GitOps continuous deployment
- **KAgent** - AI agent framework for Kubernetes

## Prerequisites

- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets#installation) (for Sealed Secrets)
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

## Secrets Management with Sealed Secrets

This cluster uses **Sealed Secrets** for secure secret management in GitOps workflows.

### Quick Start with Sealed Secrets

```bash
# Install kubeseal CLI
brew install kubeseal  # macOS
# or download from: https://github.com/bitnami-labs/sealed-secrets/releases

# Create and seal a secret
kubectl create secret generic my-secret \
  --dry-run=client \
  --from-literal=password=mypassword \
  -n default \
  -o yaml | kubeseal --format yaml > my-sealed-secret.yaml

# Apply and commit (safe to commit!)
kubectl apply -f my-sealed-secret.yaml
git add my-sealed-secret.yaml
git commit -m "Add sealed secret"
```

See [manifests/sealed-secrets/README.md](manifests/sealed-secrets/README.md) for complete documentation.

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
2. Sealed Secrets
3. Cloudflare Tunnel Ingress Controller
4. NGINX Ingress Controller
5. ArgoCD
6. KAgent

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

### Sealed Secrets
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
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

### NGINX Ingress Controller
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/kind/deploy.yaml
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

## Directory Structure

```
.
├── README.md                    # This file
├── kind-config.yaml            # Kind cluster configuration
├── manifests/                  # Kubernetes manifests
│   ├── cert-manager/          # cert-manager resources
│   ├── sealed-secrets/        # Sealed Secrets examples
│   ├── cloudflare-tunnel/     # Cloudflare tunnel config
│   ├── ingress-nginx/         # NGINX ingress resources
│   ├── argocd/                # ArgoCD applications
│   └── kagent/                # KAgent base resources
├── scripts/                    # Installation scripts
│   ├── create-cluster.sh      # Create Kind cluster
│   ├── install-all.sh         # Install all components
│   ├── install-cert-manager.sh
│   ├── install-sealed-secrets.sh
│   ├── install-cloudflare.sh
│   ├── install-nginx.sh
│   ├── install-argocd.sh
│   └── install-kagent.sh
└── .github/
    └── workflows/
        └── cluster-sync.yaml  # GitHub Actions for cluster sync
```

## Component Documentation

### cert-manager
TLS certificate management for Kubernetes. See [manifests/cert-manager/README.md](manifests/cert-manager/README.md)

### Sealed Secrets
Encrypt secrets for safe storage in Git. See [manifests/sealed-secrets/README.md](manifests/sealed-secrets/README.md)

**Key Features:**
- Encrypt secrets before committing to Git
- GitOps-friendly secret management
- Namespace-scoped encryption
- Automatic decryption by cluster controller

### Cloudflare Tunnel
Expose Kubernetes services to the internet via Cloudflare. See [manifests/cloudflare-tunnel/README.md](manifests/cloudflare-tunnel/README.md)

### NGINX Ingress
Alternative ingress controller for local development. See [manifests/ingress-nginx/README.md](manifests/ingress-nginx/README.md)

### ArgoCD
GitOps continuous deployment. See [manifests/argocd/README.md](manifests/argocd/README.md)

### KAgent
AI agent framework for Kubernetes. See [manifests/kagent/README.md](manifests/kagent/README.md)

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

### Sealed Secrets not working
```bash
# Check controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=sealed-secrets

# Verify controller is running
kubectl get pods -n kube-system -l app.kubernetes.io/name=sealed-secrets

# Fetch the sealing certificate
kubeseal --fetch-cert
```

## Contributing

When adding new infrastructure components:

1. Add manifests to appropriate directory under `manifests/`
2. Create installation script in `scripts/`
3. Update `install-all.sh` to include new component
4. Update this README

## License

MIT
