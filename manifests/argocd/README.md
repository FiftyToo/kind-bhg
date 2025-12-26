# ArgoCD Applications

This directory contains ArgoCD Application manifests for GitOps deployments.

## Example Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/FiftyToo/kagent-bhg
    targetRevision: main
    path: agents
  destination:
    server: https://kubernetes.default.svc
    namespace: kagent
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

## Connecting kagent-bhg Repository

Create an Application that watches the kagent-bhg repository:

```bash
kubectl apply -f kagent-bhg-app.yaml
```

This enables automatic deployment of KAgent agents and MCP servers when changes are pushed to the kagent-bhg repository.

## Exposing ArgoCD Web UI via Cloudflare Tunnel

The ArgoCD web UI is exposed through a Cloudflare Tunnel named `argocd-tunnel`:

```bash
kubectl apply -f argocd-ingress.yaml
```

**Configuration Details:**
- **Tunnel Name**: `argocd-tunnel`
- **Domain**: Replace `argocd.yourdomain.com` in the ingress with your actual domain
- **Backend Protocol**: HTTPS (ArgoCD server uses TLS internally)
- **Service**: `argocd-server` on port 443

**Important Notes:**
- Ensure the cloudflare-tunnel-ingress-controller is installed and running
- The domain must be configured in your Cloudflare account
- DNS records will be automatically created by the controller
- Default ArgoCD credentials: username `admin`, password can be retrieved with:
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```
