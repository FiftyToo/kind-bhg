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

## Managing Repository Credentials

ArgoCD needs credentials to access private repositories. These credentials are stored as Kubernetes Secrets.

### Using Sealed Secrets (Recommended)

Since credentials contain sensitive data, use Sealed Secrets to encrypt them before committing to git:

**1. Export existing credentials from the cluster:**
```bash
# List current repository secrets
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# Export a specific secret
kubectl get secret <secret-name> -n argocd -o yaml > temp-repo-secret.yaml
```

**2. Seal the secret:**
```bash
kubeseal -f temp-repo-secret.yaml -w manifests/argocd/repository-credentials-sealed.yaml
```

**3. Commit only the sealed version:**
```bash
git add manifests/argocd/repository-credentials-sealed.yaml
rm temp-repo-secret.yaml  # Delete the unsealed version!
git commit -m "Add sealed repository credentials"
```

**4. Apply the sealed secret:**
```bash
kubectl apply -f manifests/argocd/repository-credentials-sealed.yaml
```

The sealed-secrets controller will decrypt it and create the actual Secret.

### Repository Credential Format

Repository credentials use this label to be recognized by ArgoCD:
```yaml
labels:
  argocd.argoproj.io/secret-type: repository
```

**For GitHub App:**
```yaml
stringData:
  type: git
  url: https://github.com/FiftyToo
  githubAppID: "123456"
  githubAppInstallationID: "789012"
  githubAppPrivateKey: |
    -----BEGIN RSA PRIVATE KEY-----
    ...
    -----END RSA PRIVATE KEY-----
```

**For Personal Access Token:**
```yaml
stringData:
  type: git
  url: https://github.com/FiftyToo
  username: git
  password: ghp_yourTokenHere
```

### Reusing Credentials Across Applications

Once a repository credential Secret exists, all Applications that reference repositories matching the URL pattern will automatically use those credentials. You don't need to specify credentials in each Application.

Example: If you have credentials for `https://github.com/FiftyToo`, all Applications using repos like:
- `https://github.com/FiftyToo/kagent-bhg`
- `https://github.com/FiftyToo/kind-bhg`
- `https://github.com/FiftyToo/genetics-sandbox`

...will automatically use the same credentials.
